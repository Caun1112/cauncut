// 缩略图提取器: 从视频中提取指定时间点的帧

import 'dart:ffi';
import 'dart:typed_data';
import 'ffi/ffmpeg_bindings.dart';
import 'ffi/ffmpeg_structs.dart';
import 'package:ffi/ffi.dart';


class ThumbnailExtractor {
  final FFmpegBindings f;

  ThumbnailExtractor(this.f);

  /// 提取视频指定时间点的缩略图, 返回 RGBA 像素数据
  /// [thumbWidth] / [thumbHeight] 为缩略图目标尺寸
  Future<Uint8List?> extract({
    required String filePath,
    required Duration position,
    int thumbWidth = 130,
    int thumbHeight = 73,
  }) async {
    final fmtCtxPtr = calloc<Pointer<Void>>();
    final pathPtr = filePath.toNativeUtf8();

    try {
      final ret = f.avformatOpenInput(fmtCtxPtr, pathPtr, nullptr, nullptr);
      if (ret < 0) return null;
      final fmtCtx = fmtCtxPtr.value;

      final ret2 = f.avformatFindStreamInfo(fmtCtx, nullptr);
      if (ret2 < 0) {
        f.avformatCloseInput(fmtCtxPtr);
        return null;
      }

      final decPtr = calloc<Pointer<Void>>();
      final streamIdx = f.avFindBestStream(fmtCtx, AVMediaType.video, -1, -1, decPtr, 0);
      if (streamIdx < 0) {
        f.avformatCloseInput(fmtCtxPtr);
        calloc.free(decPtr);
        return null;
      }

      // 获取 codecpar
      final stream = Pointer<Pointer<Void>>.fromAddress(fmtCtx.address + 0x48)[streamIdx];
      final codecPar = Pointer<AVCodecParameters>.fromAddress(stream.address + 0x88).ref;

      // 创建解码器
      final codecCtx = f.avcodecAllocContext3(decPtr.value);
      f.avcodecParametersToContext(codecCtx, codecPar);
      f.avcodecOpen2(codecCtx, decPtr.value, nullptr);
      calloc.free(decPtr);

      // seek
      final tb = Pointer<AVRational>.fromAddress(stream.address + 0x20).ref;
      final ts = (position.inMicroseconds * tb.den / (tb.num * 1000000)).round();
      f.avformatSeekFile(fmtCtx, streamIdx, 0, ts, ts, AVSEEK_FLAG_BACKWARD);
      f.avcodecFlushBuffers(codecCtx);

      // 解码直到获取到 >= target_ts 的帧
      Pointer<AVFrame>? gotFrame;
      final pkt = f.avPacketAlloc();
      final frame = f.avFrameAlloc();

      try {
        while (true) {
          final readRet = f.avReadFrame(fmtCtx, pkt);
          if (readRet < 0) break;
          if (pkt.ref.stream_index != streamIdx) {
            f.avPacketUnref(pkt);
            continue;
          }
          f.avcodecSendPacket(codecCtx, pkt);
          f.avPacketUnref(pkt);
          final recvRet = f.avcodecReceiveFrame(codecCtx, frame);
          if (recvRet == 0) {
            if (frame.ref.pts >= ts) {
              gotFrame = frame;
              break;
            }
          }
        }
      } finally {
        f.avPacketFree(pkt.addressOf);
      }

      if (gotFrame == null) {
        f.avFrameFree(frame.addressOf);
        f.avcodecFreeContext(codecCtx.addressOf);
        f.avformatCloseInput(fmtCtxPtr);
        return null;
      }

      // 缩放到目标尺寸 (sws_scale)
      final swsCtx = f.swsGetContext(
        gotFrame.ref.width, gotFrame.ref.height, gotFrame.ref.format,
        thumbWidth, thumbHeight, AVPixelFormat.rgba,
        2, nullptr, nullptr, nullptr, // SWS_BILINEAR
      );
      if (swsCtx == nullptr) {
        f.avFrameFree(frame.addressOf);
        f.avcodecFreeContext(codecCtx.addressOf);
        f.avformatCloseInput(fmtCtxPtr);
        return null;
      }

      // 目标帧
      final dstFrame = f.avFrameAlloc();
      dstFrame.ref.format = AVPixelFormat.rgba;
      dstFrame.ref.width = thumbWidth;
      dstFrame.ref.height = thumbHeight;

      final bufferSize = f.avImageGetBufferSize(
        AVPixelFormat.rgba, thumbWidth, thumbHeight, 1,
      );
      final buffer = calloc<Uint8>(bufferSize);

      // fill arrays with our buffer
      final dstData = calloc<Pointer<Uint8>>(4);
      final dstLinesize = calloc<Int32>(4);
      f.avImageFillArrays(dstData, dstLinesize, buffer, AVPixelFormat.rgba, thumbWidth, thumbHeight, 1);

      dstFrame.ref.data[0] = dstData[0];
      dstFrame.ref.data[1] = dstData[1];
      dstFrame.ref.data[2] = dstData[2];
      dstFrame.ref.data[3] = dstData[3];
      dstFrame.ref.linesize[0] = dstLinesize[0];
      dstFrame.ref.linesize[1] = dstLinesize[1];
      dstFrame.ref.linesize[2] = dstLinesize[2];
      dstFrame.ref.linesize[3] = dstLinesize[3];

      f.swsScaleFrame(swsCtx, dstFrame, gotFrame);

      // 提取 RGBA 数据
      final rgbaData = Uint8List.fromList(
        buffer.asTypedList(bufferSize),
      );

      // 清理
      calloc.free(buffer);
      calloc.free(dstData);
      calloc.free(dstLinesize);
      f.swsFreeContext(swsCtx);
      f.avFrameFree(dstFrame.addressOf);
      f.avFrameFree(frame.addressOf);
      f.avcodecFreeContext(codecCtx.addressOf);
      f.avformatCloseInput(fmtCtxPtr);

      return rgbaData;
    } finally {
      calloc.free(pathPtr);
      calloc.free(fmtCtxPtr);
    }
  }
}

abstract class AVSEEK_FLAG {
  static const int BACKWARD = 1;
}
