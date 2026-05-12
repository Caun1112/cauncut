// 视频编码器 + 音频编码器 + Muxer 封装
// 支持 NVENC GPU 硬编 和 x264/x265 软件回退

import 'dart:ffi';
import 'dart:typed_data';
import 'ffi/ffmpeg_bindings.dart';
import 'ffi/ffmpeg_structs.dart';
import 'package:ffi/ffi.dart';


/// NVENC 编码器配置
class NvencConfig {
  final String codecName; // "h264_nvenc" or "hevc_nvenc"
  final int width;
  final int height;
  final AVRational frameRate;
  final int targetBitrate; // bps (not kbps)
  final String rateControl; // "cbr" / "vbr" / "vbr_hq"
  final int maxBitrate; // bps, VBR 用
  final int cqLevel; // 0-51, VBR quality
  final String preset; // "p1" (fastest) - "p7" (slowest)
  final AVPixelFormat inputFormat;

  NvencConfig({
    required this.codecName,
    required this.width,
    required this.height,
    required this.frameRate,
    this.targetBitrate = 5000000,
    this.rateControl = 'vbr_hq',
    this.maxBitrate = 10000000,
    this.cqLevel = 23,
    this.preset = 'p5',
    this.inputFormat = AVPixelFormat.yuv420p,
  });
}

/// 视频编码器
class VideoEncoder {
  final FFmpegBindings f;
  Pointer<Void> _codecCtx = nullptr;
  Pointer<AVFrame> _frame = nullptr;
  int _frameCount = 0;
  bool _opened = false;

  VideoEncoder(this.f);

  void open(NvencConfig config) {
    close();

    final codecNamePtr = config.codecName.toNativeUtf8();
    final codec = f.avcodecFindEncoderByName(codecNamePtr);
    calloc.free(codecNamePtr);

    if (codec == nullptr) {
      // 回退到软件编码
      final fallbackName = config.codecName.startsWith('h264') ? 'libx264' : 'libx265';
      final fbPtr = fallbackName.toNativeUtf8();
      final fbCodec = f.avcodecFindEncoderByName(fbPtr);
      calloc.free(fbPtr);
      if (fbCodec == nullptr) throw Exception('编码器不可用: ${config.codecName}');
      _openWithCodec(fbCodec, config);
    } else {
      _openWithCodec(codec, config);
    }
    _opened = true;
  }

  void _openWithCodec(Pointer<Void> codec, NvencConfig config) {
    _codecCtx = f.avcodecAllocContext3(codec);
    if (_codecCtx == nullptr) throw Exception('avcodec_alloc_context3 失败');

    // 设置编码器上下文
    _setIntField(_codecCtx, 0x10, config.width); // width
    _setIntField(_codecCtx, 0x14, config.height); // height
    _setInt64Field(_codecCtx, 0x78, config.targetBitrate); // bit_rate

    // time_base
    final tbPtr = Pointer<AVRational>.fromAddress(_codecCtx.address + 0x20);
    tbPtr.ref.num = config.frameRate.den;
    tbPtr.ref.den = config.frameRate.num;

    // framerate
    final frPtr = Pointer<AVRational>.fromAddress(_codecCtx.address + 0x28);
    frPtr.ref.num = config.frameRate.num;
    frPtr.ref.den = config.frameRate.den;

    // pixel format
    _setIntField(_codecCtx, 0x64, config.inputFormat);

    // 构造 AVDictionary 编码器选项
    final optsPtr = calloc<Pointer<AVDictionary>>();

    void setOpt(String key, String value) {
      final k = key.toNativeUtf8();
      final v = value.toNativeUtf8();
      f.avDictSet(optsPtr, k, v, 0);
      calloc.free(k);
      calloc.free(v);
    }
    setOpt('preset', config.preset);
    setOpt('rc', config.rateControl);
    setOpt('b', '${config.targetBitrate}');
    if (config.rateControl != 'cbr') {
      setOpt('maxrate', '${config.maxBitrate}');
      setOpt('cq', '${config.cqLevel}');
    } else {
      setOpt('minrate', '${config.targetBitrate}');
      setOpt('maxrate', '${config.targetBitrate}');
    }
    setOpt('bufsize', '${config.maxBitrate}');

    final ret = f.avcodecOpen2(_codecCtx, codec, optsPtr);
    calloc.free(optsPtr);
    if (ret < 0) throw Exception('avcodec_open2 失败: $ret');

    _frame = f.avFrameAlloc();
    _frame.ref.format = config.inputFormat;
    _frame.ref.width = config.width;
    _frame.ref.height = config.height;
    _frame.ref.pts = 0;
  }

  /// 编码一帧, 返回 AVPacket (调用者负责 free)
  Pointer<AVPacket>? encodeFrame(Pointer<AVFrame> frame) {
    if (!_opened) throw StateError('编码器未打开');

    frame.ref.pts = _frameCount;
    final sendRet = f.avcodecSendFrame(_codecCtx, frame);
    if (sendRet < 0) return null;

    final pkt = f.avPacketAlloc();
    final recvRet = f.avcodecReceivePacket(_codecCtx, pkt);
    if (recvRet == 0) {
      _frameCount++;
      return pkt;
    }
    f.avPacketFree(pkt.addressOf);
    return null;
  }

  /// 刷新编码器, 获取剩余 packet
  List<Pointer<AVPacket>> flush() {
    final packets = <Pointer<AVPacket>>[];
    f.avcodecSendFrame(_codecCtx, nullptr); // flush signal

    while (true) {
      final pkt = f.avPacketAlloc();
      final ret = f.avcodecReceivePacket(_codecCtx, pkt);
      if (ret == 0) {
        packets.add(pkt);
      } else {
        f.avPacketFree(pkt.addressOf);
        break;
      }
    }
    return packets;
  }

  void close() {
    if (_frame != nullptr) {
      f.avFrameFree(_frame.addressOf);
      _frame = nullptr;
    }
    if (_codecCtx != nullptr) {
      f.avcodecFreeContext(_codecCtx.addressOf);
      _codecCtx = nullptr;
    }
    _frameCount = 0;
    _opened = false;
  }

  void dispose() => close();

  // 通过偏移量写入字段值 (AVCodecContext 的部分字段)
  void _setIntField(Pointer<Void> ptr, int offset, int value) {
    Pointer<Int32>.fromAddress(ptr.address + offset).value = value;
  }
  void _setInt64Field(Pointer<Void> ptr, int offset, int value) {
    Pointer<Int64>.fromAddress(ptr.address + offset).value = value;
  }
}

/// AAC 音频编码器配置
class AacConfig {
  final int sampleRate;
  final int bitrate; // bps
  final int channels;

  AacConfig({
    this.sampleRate = 48000,
    this.bitrate = 128000,
    this.channels = 2,
  });
}

/// 音频编码器 (AAC)
class AudioEncoder {
  final FFmpegBindings f;
  Pointer<Void> _codecCtx = nullptr;
  bool _opened = false;

  AudioEncoder(this.f);

  void open(AacConfig config) {
    close();
    final codec = f.avcodecFindEncoder(AVCodecID.aac);
    if (codec == nullptr) throw Exception('AAC 编码器不可用');

    _codecCtx = f.avcodecAllocContext3(codec);
    if (_codecCtx == nullptr) throw Exception('avcodec_alloc_context3 失败');

    _setIntField(_codecCtx, 0x6c, config.sampleRate); // sample_rate
    _setInt32Field(_codecCtx, 0x74, config.channels); // channels (approx offset)
    _setInt64Field(_codecCtx, 0x78, config.bitrate); // bit_rate
    _setIntField(_codecCtx, 0x64, AVSampleFormat.fltp); // sample_fmt

    final ret = f.avcodecOpen2(_codecCtx, codec, nullptr);
    if (ret < 0) throw Exception('AAC avcodec_open2 失败: $ret');
    _opened = true;
  }

  Pointer<AVPacket>? encodeFrame(Pointer<AVFrame> frame) {
    if (!_opened) throw StateError('编码器未打开');
    final sendRet = f.avcodecSendFrame(_codecCtx, frame);
    if (sendRet < 0) return null;
    final pkt = f.avPacketAlloc();
    final recvRet = f.avcodecReceivePacket(_codecCtx, pkt);
    if (recvRet == 0) return pkt;
    f.avPacketFree(pkt.addressOf);
    return null;
  }

  void close() {
    if (_codecCtx != nullptr) {
      f.avcodecFreeContext(_codecCtx.addressOf);
      _codecCtx = nullptr;
    }
    _opened = false;
  }

  void dispose() => close();

  void _setIntField(Pointer<Void> ptr, int offset, int value) {
    Pointer<Int32>.fromAddress(ptr.address + offset).value = value;
  }
  void _setInt32Field(Pointer<Void> ptr, int offset, int value) {
    Pointer<Int32>.fromAddress(ptr.address + offset).value = value;
  }
  void _setInt64Field(Pointer<Void> ptr, int offset, int value) {
    Pointer<Int64>.fromAddress(ptr.address + offset).value = value;
  }
}

abstract class AVCodecID {
  static const int aac = 86018;
  static const int h264 = 27;
  static const int hevc = 173;
}

/// 输出文件复用器
class Muxer {
  final FFmpegBindings f;
  Pointer<Void> _fmtCtx = nullptr;
  Pointer<Void> _videoStream = nullptr;
  Pointer<Void> _audioStream = nullptr;
  bool _opened = false;

  Muxer(this.f);

  void open(String outputPath, String formatName) {
    close();
    final fmtPtr = f.avGuessFormat(nullptr, outputPath.toNativeUtf8(), nullptr);
    if (fmtPtr == nullptr) throw Exception('不支持的输出格式: $formatName');

    final ctxPtr = calloc<Pointer<Void>>();
    f.avformatAllocOutputContext2(ctxPtr, fmtPtr, nullptr, nullptr);
    _fmtCtx = ctxPtr.value;
    calloc.free(ctxPtr);
    if (_fmtCtx == nullptr) throw Exception('avformat_alloc_output_context2 失败');

    final urlPtr = outputPath.toNativeUtf8();
    f.avioOpen(
      Pointer<Pointer<Void>>.fromAddress(_fmtCtx.address + 0x30).addressOf,
      urlPtr, 2, // AVIO_FLAG_WRITE
    );
    calloc.free(urlPtr);
    _opened = true;
  }

  /// 添加视频流 (从编码器复制 codecpar)
  void addVideoStream(Pointer<Void> encoderCtx) {
    _videoStream = f.avformatNewStream(_fmtCtx, nullptr);
    f.avcodecParametersFromContext(
      Pointer<AVCodecParameters>.fromAddress(_videoStream.address + 0x88),
      encoderCtx,
    );
  }

  /// 添加音频流
  void addAudioStream(Pointer<Void> encoderCtx) {
    _audioStream = f.avformatNewStream(_fmtCtx, nullptr);
    f.avcodecParametersFromContext(
      Pointer<AVCodecParameters>.fromAddress(_audioStream.address + 0x88),
      encoderCtx,
    );
  }

  void writeHeader() {
    f.avformatWriteHeader(_fmtCtx, nullptr);
  }

  void writePacket(Pointer<AVPacket> pkt) {
    f.avInterleavedWriteFrame(_fmtCtx, pkt);
  }

  void writeTrailer() {
    f.avWriteTrailer(_fmtCtx);
  }

  void close() {
    if (_fmtCtx != nullptr) {
      f.avioClosep(Pointer<Pointer<Void>>.fromAddress(_fmtCtx.address + 0x30).addressOf);
      f.avformatFreeContext(_fmtCtx);
      _fmtCtx = nullptr;
    }
    _opened = false;
  }

  void dispose() => close();
}
