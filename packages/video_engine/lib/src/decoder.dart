// 视频解码器: 封装 FFmpeg 解码流程
// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:ffi';
import 'dart:typed_data';
import 'ffi/ffmpeg_bindings.dart';
import 'ffi/ffmpeg_structs.dart';
import 'package:ffi/ffi.dart';


class VideoStreamInfo {
  final int index;
  final int width;
  final int height;
  final double fps;
  final Duration duration;

  VideoStreamInfo({
    required this.index,
    required this.width,
    required this.height,
    required this.fps,
    required this.duration,
  });
}

class VideoDecoder {
  final FFmpegBindings f;
  Pointer<Void> _fmtCtx = Pointer.fromAddress(0);
  Pointer<Void> _codecCtx = Pointer.fromAddress(0);
  int _videoStreamIndex = -1;
  int _timeBaseNum = 1;
  int _timeBaseDen = 1;
  bool _opened = false;

  VideoDecoder(this.f);

  Future<VideoStreamInfo> open(String filePath) async {
    close();

    final pathPtr = filePath.toNativeUtf8();
    final fmtCtxPtr = calloc<Pointer<Void>>();

    try {
      final ret = f.avformatOpenInput(fmtCtxPtr, pathPtr, Pointer.fromAddress(0), Pointer.fromAddress(0));
      if (ret < 0) throw Exception('avformat_open_input 失败: ${_errStr(ret)}');
      _fmtCtx = fmtCtxPtr.value;

      final ret2 = f.avformatFindStreamInfo(_fmtCtx, Pointer.fromAddress(0));
      if (ret2 < 0) throw Exception('avformat_find_stream_info 失败: ${_errStr(ret2)}');

      final decPtr = calloc<Pointer<Void>>();
      final videoIdx = f.avFindBestStream(_fmtCtx, AVMediaType.video, -1, -1, decPtr, 0);
      if (videoIdx < 0) throw Exception('未找到视频流');
      _videoStreamIndex = videoIdx;

      // 获取 codecpar
      final codecParPtr = _getStreamCodecParPtr(_videoStreamIndex);
      final w = codecParPtr.ref.width;
      final h = codecParPtr.ref.height;

      // 创建解码器上下文
      _codecCtx = f.avcodecAllocContext3(decPtr.value);
      if (_codecCtx == Pointer.fromAddress(0)) throw Exception('avcodec_alloc_context3 失败');

      final ret3 = f.avcodecParametersToContext(_codecCtx, codecParPtr);
      if (ret3 < 0) throw Exception('avcodec_parameters_to_context 失败: ${_errStr(ret3)}');

      final ret4 = f.avcodecOpen2(_codecCtx, decPtr.value, Pointer.fromAddress(0));
      if (ret4 < 0) throw Exception('avcodec_open2 失败: ${_errStr(ret4)}');

      // 读取帧率和 time_base
      final stream = _getStream(_videoStreamIndex);
      // AVStream.avg_frame_rate at offset 0x50 (64-bit: after time_base + ...)
      final frNum = Pointer<Int32>.fromAddress(stream.address + 0x50).value;
      final frDen = Pointer<Int32>.fromAddress(stream.address + 0x54).value;
      // AVStream.time_base at offset 0xC0 (may vary, trying...)
      // AVStream.time_base is at offset: 0x120 (heuristic for FFmpeg 7.x/8.x)
      _timeBaseNum = Pointer<Int32>.fromAddress(stream.address + 0x120).value;
      _timeBaseDen = Pointer<Int32>.fromAddress(stream.address + 0x124).value;

      final dur = _streamDuration();

      calloc.free(decPtr);
      _opened = true;

      final fps = frDen > 0 ? frNum / frDen : 30.0;
      return VideoStreamInfo(
        index: _videoStreamIndex,
        width: w,
        height: h,
        fps: fps,
        duration: dur,
      );
    } finally {
      calloc.free(pathPtr);
      calloc.free(fmtCtxPtr);
    }
  }

  /// 解码下一帧, 返回 AVFrame 指针 (调用者负责 free)
  Pointer<AVFrame>? decodeFrame() {
    if (!_opened) throw StateError('解码器未打开');

    final pkt = f.avPacketAlloc();
    final frame = f.avFrameAlloc();

    while (true) {
      final ret = f.avReadFrame(_fmtCtx, pkt);
      if (ret < 0) {
        f.avPacketFree(pkt.addressOf);
        f.avFrameFree(frame.addressOf);
        return null;
      }

      if (pkt.ref.stream_index != _videoStreamIndex) {
        f.avPacketUnref(pkt);
        continue;
      }

      final sendRet = f.avcodecSendPacket(_codecCtx, pkt);
      f.avPacketUnref(pkt);
      if (sendRet < 0) continue;

      final recvRet = f.avcodecReceiveFrame(_codecCtx, frame);
      if (recvRet == 0) {
        f.avPacketFree(pkt.addressOf);
        return frame;
      }
      if (recvRet == AVError.eagain) continue;
      break;
    }

    f.avPacketFree(pkt.addressOf);
    f.avFrameFree(frame.addressOf);
    return null;
  }

  Future<void> seek(Duration position) async {
    if (!_opened) throw StateError('解码器未打开');
    final ts = _durationToTs(position);
    f.avformatSeekFile(_fmtCtx, _videoStreamIndex, 0, ts, ts, AVSEEK_FLAG_BACKWARD);
    f.avcodecFlushBuffers(_codecCtx);
  }

  void close() {
    if (_codecCtx != Pointer.fromAddress(0)) {
      f.avcodecFreeContext(_codecCtx.addressOf);
      _codecCtx = Pointer.fromAddress(0);
    }
    if (_fmtCtx != Pointer.fromAddress(0)) {
      f.avformatCloseInput(_fmtCtx.addressOf);
      _fmtCtx = Pointer.fromAddress(0);
    }
    _videoStreamIndex = -1;
    _opened = false;
  }

  void dispose() => close();

  // --- 内部辅助 ---

  Pointer<Void> _getStream(int index) {
    // AVFormatContext.streams 在偏移量 0x48
    final streamsPtr = Pointer<Pointer<Void>>.fromAddress(_fmtCtx.address + 0x48);
    return streamsPtr[index];
  }

  Pointer<AVCodecParameters> _getStreamCodecParPtr(int index) {
    // AVStream.codecpar 在偏移量 0x150 (FFmpeg 7.x/8.x)
    final stream = _getStream(index);
    return Pointer<AVCodecParameters>.fromAddress(stream.address + 0x150);
  }

  Duration _streamDuration() {
    // 优先用 stream duration
    final stream = _getStream(_videoStreamIndex);
    // AVStream.duration 在偏移量 0xE0 (int64_t)
    final dur = Pointer<Int64>.fromAddress(stream.address + 0xE0).value;
    if (dur > 0) {
      final secs = dur * _timeBaseNum / _timeBaseDen;
      return Duration(microseconds: (secs * 1000000).round());
    }
    // 回退到 AVFormatContext.duration (offset 0x40, int64_t, AV_TIME_BASE)
    final fmtDur = Pointer<Int64>.fromAddress(_fmtCtx.address + 0x40).value;
    if (fmtDur > 0) return Duration(microseconds: fmtDur);
    return Duration.zero;
  }

  int _durationToTs(Duration d) {
    return (d.inMicroseconds.toDouble() * _timeBaseDen / (_timeBaseNum * 1000000)).round();
  }

  String _errStr(int errnum) {
    final buf = calloc<Int8>(256);
    f.avStrError(errnum, buf, 256);
    final msg = buf.cast<Utf8>().toDartString();
    calloc.free(buf);
    return msg;
  }
}

abstract class AVSEEK_FLAG {
  static const int BACKWARD = 1;
  static const int BYTE = 2;
  static const int ANY = 4;
  static const int FRAME = 8;
}
