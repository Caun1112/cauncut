// FFmpeg C 函数的 Dart FFI 绑定 (~80 函数)
// 按库分组: libavformat / libavcodec / libavutil / libswscale / libswresample / libavfilter
//
// 所有函数用 DynamicLibrary.lookup 动态加载, 支持多平台路径

// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'dart:io';
import 'ffmpeg_structs.dart';

// C 字符串 (const char*) 类型别名
typedef CString = Int8;

// --- 类型别名 (Dart -> C Native) ---

typedef AvFormatOpenInputNative = Int32 Function(
  Pointer<Pointer<Void>> ps, Pointer<CString> url, Pointer<Void> fmt, Pointer<Pointer<AVDictionary>> options,
);
typedef AvFormatOpenInputDart = int Function(
  Pointer<Pointer<Void>> ps, Pointer<CString> url, Pointer<Void> fmt, Pointer<Pointer<AVDictionary>> options,
);

typedef AvFormatFindStreamInfoNative = Int32 Function(
  Pointer<Void> ic, Pointer<Pointer<AVDictionary>> options,
);
typedef AvFormatFindStreamInfoDart = int Function(
  Pointer<Void> ic, Pointer<Pointer<AVDictionary>> options,
);

typedef AvFormatCloseInputNative = Void Function(Pointer<Pointer<Void>> s);
typedef AvFormatCloseInputDart = void Function(Pointer<Pointer<Void>> s);

typedef AvReadFrameNative = Int32 Function(Pointer<Void> s, Pointer<AVPacket> pkt);
typedef AvReadFrameDart = int Function(Pointer<Void> s, Pointer<AVPacket> pkt);

typedef AvSeekFrameNative = Int32 Function(Pointer<Void> s, Int32 stream_index, Int64 timestamp, Int32 flags);
typedef AvSeekFrameDart = int Function(Pointer<Void> s, int stream_index, int timestamp, int flags);

typedef AvFormatSeekFileNative = Int32 Function(
  Pointer<Void> s, Int32 stream_index, Int64 min_ts, Int64 ts, Int64 max_ts, Int32 flags,
);
typedef AvFormatSeekFileDart = int Function(
  Pointer<Void> s, int stream_index, int min_ts, int ts, int max_ts, int flags,
);

typedef AvFindBestStreamNative = Int32 Function(
  Pointer<Void> ic, Int32 type, Int32 wanted_stream_nb, Int32 related_stream, Pointer<Pointer<Void>> decoder_ret, Int32 flags,
);
typedef AvFindBestStreamDart = int Function(
  Pointer<Void> ic, int type, int wanted_stream_nb, int related_stream, Pointer<Pointer<Void>> decoder_ret, int flags,
);

typedef AvGuessFormatNative = Pointer<Void> Function(Pointer<CString> short_name, Pointer<CString> filename, Pointer<CString> mime_type);
typedef AvGuessFormatDart = Pointer<Void> Function(Pointer<CString> short_name, Pointer<CString> filename, Pointer<CString> mime_type);

typedef AvformatAllocOutputContext2Native = Int32 Function(
  Pointer<Pointer<Void>> ctx, Pointer<Void> oformat, Pointer<CString> format_name, Pointer<CString> filename,
);
typedef AvformatAllocOutputContext2Dart = int Function(
  Pointer<Pointer<Void>> ctx, Pointer<Void> oformat, Pointer<CString> format_name, Pointer<CString> filename,
);

typedef AvformatNewStreamNative = Pointer<Void> Function(Pointer<Void> s, Pointer<Void> c);
typedef AvformatNewStreamDart = Pointer<Void> Function(Pointer<Void> s, Pointer<Void> c);

typedef AvformatWriteHeaderNative = Int32 Function(Pointer<Void> s, Pointer<Pointer<AVDictionary>> options);
typedef AvformatWriteHeaderDart = int Function(Pointer<Void> s, Pointer<Pointer<AVDictionary>> options);

typedef AvInterleavedWriteFrameNative = Int32 Function(Pointer<Void> s, Pointer<AVPacket> pkt);
typedef AvInterleavedWriteFrameDart = int Function(Pointer<Void> s, Pointer<AVPacket> pkt);

typedef AvWriteTrailerNative = Int32 Function(Pointer<Void> s);
typedef AvWriteTrailerDart = int Function(Pointer<Void> s);

typedef AvioOpenNative = Int32 Function(Pointer<Pointer<Void>> s, Pointer<CString> url, Int32 flags);
typedef AvioOpenDart = int Function(Pointer<Pointer<Void>> s, Pointer<CString> url, int flags);

typedef AvioClosepNative = Int32 Function(Pointer<Pointer<Void>> s);
typedef AvioClosepDart = int Function(Pointer<Pointer<Void>> s);

typedef AvformatFreeContextNative = Void Function(Pointer<Void> s);
typedef AvformatFreeContextDart = void Function(Pointer<Void> s);

// --- libavcodec ---

typedef AvcodecAllocContext3Native = Pointer<Void> Function(Pointer<Void> codec);
typedef AvcodecAllocContext3Dart = Pointer<Void> Function(Pointer<Void> codec);

typedef AvcodecParametersToContextNative = Int32 Function(Pointer<Void> codec, Pointer<AVCodecParameters> par);
typedef AvcodecParametersToContextDart = int Function(Pointer<Void> codec, Pointer<AVCodecParameters> par);

typedef AvcodecParametersFromContextNative = Int32 Function(Pointer<AVCodecParameters> par, Pointer<Void> codec);
typedef AvcodecParametersFromContextDart = int Function(Pointer<AVCodecParameters> par, Pointer<Void> codec);

typedef AvcodecOpen2Native = Int32 Function(Pointer<Void> avctx, Pointer<Void> codec, Pointer<Pointer<AVDictionary>> options);
typedef AvcodecOpen2Dart = int Function(Pointer<Void> avctx, Pointer<Void> codec, Pointer<Pointer<AVDictionary>> options);

typedef AvcodecSendPacketNative = Int32 Function(Pointer<Void> avctx, Pointer<AVPacket> avpkt);
typedef AvcodecSendPacketDart = int Function(Pointer<Void> avctx, Pointer<AVPacket> avpkt);

typedef AvcodecReceiveFrameNative = Int32 Function(Pointer<Void> avctx, Pointer<AVFrame> frame);
typedef AvcodecReceiveFrameDart = int Function(Pointer<Void> avctx, Pointer<AVFrame> frame);

typedef AvcodecFlushBuffersNative = Void Function(Pointer<Void> avctx);
typedef AvcodecFlushBuffersDart = void Function(Pointer<Void> avctx);

typedef AvcodecFreeContextNative = Void Function(Pointer<Pointer<Void>> avctx);
typedef AvcodecFreeContextDart = void Function(Pointer<Pointer<Void>> avctx);

typedef AvcodecFindDecoderNative = Pointer<Void> Function(Int32 id);
typedef AvcodecFindDecoderDart = Pointer<Void> Function(int id);

typedef AvcodecFindEncoderByNameNative = Pointer<Void> Function(Pointer<CString> name);
typedef AvcodecFindEncoderByNameDart = Pointer<Void> Function(Pointer<CString> name);

typedef AvcodecFindEncoderNative = Pointer<Void> Function(Int32 id);
typedef AvcodecFindEncoderDart = Pointer<Void> Function(int id);

typedef AvcodecSendFrameNative = Int32 Function(Pointer<Void> avctx, Pointer<AVFrame> frame);
typedef AvcodecSendFrameDart = int Function(Pointer<Void> avctx, Pointer<AVFrame> frame);

typedef AvcodecReceivePacketNative = Int32 Function(Pointer<Void> avctx, Pointer<AVPacket> avpkt);
typedef AvcodecReceivePacketDart = int Function(Pointer<Void> avctx, Pointer<AVPacket> avpkt);

typedef AvcodecGetHwConfigNative = Pointer<Void> Function(Pointer<Void> codec, Int32 index);
typedef AvcodecGetHwConfigDart = Pointer<Void> Function(Pointer<Void> codec, int index);

// --- libavutil ---

typedef AvFrameAllocNative = Pointer<AVFrame> Function();
typedef AvFrameAllocDart = Pointer<AVFrame> Function();

typedef AvFrameFreeNative = Void Function(Pointer<Pointer<AVFrame>> frame);
typedef AvFrameFreeDart = void Function(Pointer<Pointer<AVFrame>> frame);

typedef AvPacketAllocNative = Pointer<AVPacket> Function();
typedef AvPacketAllocDart = Pointer<AVPacket> Function();

typedef AvPacketFreeNative = Void Function(Pointer<Pointer<AVPacket>> pkt);
typedef AvPacketFreeDart = void Function(Pointer<Pointer<AVPacket>> pkt);

typedef AvPacketUnrefNative = Void Function(Pointer<AVPacket> pkt);
typedef AvPacketUnrefDart = void Function(Pointer<AVPacket> pkt);

typedef AvDictSetNative = Int32 Function(Pointer<Pointer<AVDictionary>> pm, Pointer<CString> key, Pointer<CString> value, Int32 flags);
typedef AvDictSetDart = int Function(Pointer<Pointer<AVDictionary>> pm, Pointer<CString> key, Pointer<CString> value, int flags);

typedef AvDictSetIntNative = Int32 Function(Pointer<Pointer<AVDictionary>> pm, Pointer<CString> key, Int64 value, Int32 flags);
typedef AvDictSetIntDart = int Function(Pointer<Pointer<AVDictionary>> pm, Pointer<CString> key, int value, int flags);

typedef AvDictGetNative = Pointer<AVDictionaryEntry> Function(Pointer<AVDictionary> m, Pointer<CString> key, Pointer<AVDictionaryEntry> prev, Int32 flags);
typedef AvDictGetDart = Pointer<AVDictionaryEntry> Function(Pointer<AVDictionary> m, Pointer<CString> key, Pointer<AVDictionaryEntry> prev, int flags);

typedef AvDictFreeNative = Void Function(Pointer<Pointer<AVDictionary>> m);
typedef AvDictFreeDart = void Function(Pointer<Pointer<AVDictionary>> m);

typedef AvRescaleQNative = Int64 Function(Int64 a, AVRational bq, AVRational cq);
typedef AvRescaleQDart = int Function(int a, AVRational bq, AVRational cq);

typedef AvRescaleQRndNative = Int64 Function(Int64 a, AVRational bq, AVRational cq, Int32 rounding);
typedef AvRescaleQRndDart = int Function(int a, AVRational bq, AVRational cq, int rounding);

typedef AvHwdeviceCtxCreateNative = Int32 Function(
  Pointer<Pointer<Void>> device_ctx, Int32 type, Pointer<CString> device, Pointer<Void> opts, Int32 flags,
);
typedef AvHwdeviceCtxCreateDart = int Function(
  Pointer<Pointer<Void>> device_ctx, int type, Pointer<CString> device, Pointer<Void> opts, int flags,
);

typedef AvHwframeCtxAllocNative = Pointer<Void> Function(Pointer<Void> device_ctx);
typedef AvHwframeCtxAllocDart = Pointer<Void> Function(Pointer<Void> device_ctx);

typedef AvHwframeCtxInitNative = Int32 Function(Pointer<Void> ref);
typedef AvHwframeCtxInitDart = int Function(Pointer<Void> ref);

typedef AvHwframeGetBufferNative = Int32 Function(Pointer<Void> hwframe_ctx, Pointer<AVFrame> frame, Int32 flags);
typedef AvHwframeGetBufferDart = int Function(Pointer<Void> hwframe_ctx, Pointer<AVFrame> frame, int flags);

typedef AvHwframeTransferDataNative = Int32 Function(Pointer<AVFrame> dst, Pointer<AVFrame> src, Int32 flags);
typedef AvHwframeTransferDataDart = int Function(Pointer<AVFrame> dst, Pointer<AVFrame> src, int flags);

typedef AvLogSetCallbackNative = Void Function(Pointer<Void> callback);
typedef AvLogSetCallbackDart = void Function(Pointer<Void> callback);

typedef AvStrErrorNative = Int32 Function(Int32 errnum, Pointer<CString> errbuf, Size errbuf_size);
typedef AvStrErrorDart = int Function(int errnum, Pointer<CString> errbuf, int errbuf_size);

// --- libswscale ---

typedef SwsGetContextNative = Pointer<Void> Function(
  Int32 srcW, Int32 srcH, Int32 srcFormat,
  Int32 dstW, Int32 dstH, Int32 dstFormat,
  Int32 flags, Pointer<Void> srcFilter, Pointer<Void> dstFilter, Pointer<Double> param,
);
typedef SwsGetContextDart = Pointer<Void> Function(
  int srcW, int srcH, int srcFormat,
  int dstW, int dstH, int dstFormat,
  int flags, Pointer<Void> srcFilter, Pointer<Void> dstFilter, Pointer<Double> param,
);

typedef SwsScaleNative = Int32 Function(
  Pointer<Void> c,
  Pointer<Pointer<Uint8>> srcSlice, Pointer<Int32> srcStride,
  Int32 srcSliceY, Int32 srcSliceH,
  Pointer<Pointer<Uint8>> dst, Pointer<Int32> dstStride,
);
typedef SwsScaleDart = int Function(
  Pointer<Void> c,
  Pointer<Pointer<Uint8>> srcSlice, Pointer<Int32> srcStride,
  int srcSliceY, int srcSliceH,
  Pointer<Pointer<Uint8>> dst, Pointer<Int32> dstStride,
);

typedef SwsScaleFrameNative = Int32 Function(Pointer<Void> c, Pointer<AVFrame> dst, Pointer<AVFrame> src);
typedef SwsScaleFrameDart = int Function(Pointer<Void> c, Pointer<AVFrame> dst, Pointer<AVFrame> src);

typedef SwsFreeContextNative = Void Function(Pointer<Void> swsContext);
typedef SwsFreeContextDart = void Function(Pointer<Void> swsContext);

typedef SwsIsNoopNative = Int32 Function(Pointer<AVFrame> dst, Pointer<AVFrame> src);
typedef SwsIsNoopDart = int Function(Pointer<AVFrame> dst, Pointer<AVFrame> src);

// --- libswresample ---

typedef SwrAllocSetOpts2Native = Int32 Function(
  Pointer<Pointer<Void>> ps,
  Pointer<Int64> out_ch_layout, Int32 out_sample_fmt, Int32 out_sample_rate,
  Pointer<Int64> in_ch_layout, Int32 in_sample_fmt, Int32 in_sample_rate,
  Int32 log_offset, Pointer<Void> log_ctx,
);
typedef SwrAllocSetOpts2Dart = int Function(
  Pointer<Pointer<Void>> ps,
  Pointer<Int64> out_ch_layout, int out_sample_fmt, int out_sample_rate,
  Pointer<Int64> in_ch_layout, int in_sample_fmt, int in_sample_rate,
  int log_offset, Pointer<Void> log_ctx,
);

typedef SwrInitNative = Int32 Function(Pointer<Void> s);
typedef SwrInitDart = int Function(Pointer<Void> s);

typedef SwrConvertNative = Int32 Function(
  Pointer<Void> s, Pointer<Pointer<Uint8>> out, Int32 out_count,
  Pointer<Pointer<Uint8>> inBuf, Int32 in_count,
);
typedef SwrConvertDart = int Function(
  Pointer<Void> s, Pointer<Pointer<Uint8>> out, int out_count,
  Pointer<Pointer<Uint8>> inBuf, int in_count,
);

typedef SwrConvertFrameNative = Int32 Function(Pointer<Void> swr, Pointer<AVFrame> output, Pointer<AVFrame> input);
typedef SwrConvertFrameDart = int Function(Pointer<Void> swr, Pointer<AVFrame> output, Pointer<AVFrame> input);

typedef SwrFreeNative = Void Function(Pointer<Pointer<Void>> s);
typedef SwrFreeDart = void Function(Pointer<Pointer<Void>> s);

// --- libavfilter ---

typedef AvfilterGraphAllocNative = Pointer<Void> Function();
typedef AvfilterGraphAllocDart = Pointer<Void> Function();

typedef AvfilterGraphCreateFilterNative = Int32 Function(
  Pointer<Pointer<Void>> filt_ctx, Pointer<Void> filt, Pointer<CString> name, Pointer<CString> args, Pointer<Void> opaque, Pointer<Void> graph_ctx,
);
typedef AvfilterGraphCreateFilterDart = int Function(
  Pointer<Pointer<Void>> filt_ctx, Pointer<Void> filt, Pointer<CString> name, Pointer<CString> args, Pointer<Void> opaque, Pointer<Void> graph_ctx,
);

typedef AvfilterGetByNameNative = Pointer<Void> Function(Pointer<CString> name);
typedef AvfilterGetByNameDart = Pointer<Void> Function(Pointer<CString> name);

typedef AvfilterGraphParsePtrNative = Int32 Function(
  Pointer<Void> graph, Pointer<CString> filters, Pointer<Pointer<Void>> inputs, Pointer<Pointer<Void>> outputs, Pointer<Void> log_ctx,
);
typedef AvfilterGraphParsePtrDart = int Function(
  Pointer<Void> graph, Pointer<CString> filters, Pointer<Pointer<Void>> inputs, Pointer<Pointer<Void>> outputs, Pointer<Void> log_ctx,
);

typedef AvfilterGraphConfigNative = Int32 Function(Pointer<Void> graphctx, Pointer<Void> log_ctx);
typedef AvfilterGraphConfigDart = int Function(Pointer<Void> graphctx, Pointer<Void> log_ctx);

typedef AvfilterGraphFreeNative = Void Function(Pointer<Pointer<Void>> graph);
typedef AvfilterGraphFreeDart = void Function(Pointer<Pointer<Void>> graph);

typedef AvfilterLinkNative = Int32 Function(
  Pointer<Void> src, Int32 srcpad, Pointer<Void> dst, Int32 dstpad,
);
typedef AvfilterLinkDart = int Function(Pointer<Void> src, int srcpad, Pointer<Void> dst, int dstpad);

typedef AvBuffersrcAddFrameFlagsNative = Int32 Function(Pointer<Void> buffer_src, Pointer<AVFrame> frame, Int32 flags);
typedef AvBuffersrcAddFrameFlagsDart = int Function(Pointer<Void> buffer_src, Pointer<AVFrame> frame, int flags);

typedef AvBuffersinkGetFrameNative = Int32 Function(Pointer<Void> ctx, Pointer<AVFrame> frame);
typedef AvBuffersinkGetFrameDart = int Function(Pointer<Void> ctx, Pointer<AVFrame> frame);

// --- libavutil/avutil.h ---

typedef AvGetMediaTypeStringNative = Pointer<CString> Function(Int32 media_type);
typedef AvGetMediaTypeStringDart = Pointer<CString> Function(int media_type);

typedef AvImageGetBufferSizeNative = Int32 Function(Int32 pix_fmt, Int32 width, Int32 height, Int32 align);
typedef AvImageGetBufferSizeDart = int Function(int pix_fmt, int width, int height, int align);

typedef AvImageFillArraysNative = Int32 Function(
  Pointer<Pointer<Uint8>> dst_data, Pointer<Int32> dst_linesize,
  Pointer<Uint8> src, Int32 pix_fmt, Int32 width, Int32 height, Int32 align,
);
typedef AvImageFillArraysDart = int Function(
  Pointer<Pointer<Uint8>> dst_data, Pointer<Int32> dst_linesize,
  Pointer<Uint8> src, int pix_fmt, int width, int height, int align,
);

typedef AvSamplesGetBufferSizeNative = Int32 Function(
  Pointer<Int32> linesize, Int32 nb_channels, Int32 nb_samples, Int32 sample_fmt, Int32 align,
);
typedef AvSamplesGetBufferSizeDart = int Function(
  Pointer<Int32> linesize, int nb_channels, int nb_samples, int sample_fmt, int align,
);

// --- 平台感知的 DLL 路径 (尝试多个 soname 版本) ---

final _windowsSonameCandidates = {
  'avcodec': ['avcodec-62.dll', 'avcodec-61.dll', 'avcodec-60.dll'],
  'avformat': ['avformat-62.dll', 'avformat-61.dll', 'avformat-60.dll'],
  'avutil': ['avutil-60.dll', 'avutil-59.dll', 'avutil-58.dll'],
  'avfilter': ['avfilter-11.dll', 'avfilter-10.dll', 'avfilter-9.dll'],
  'swscale': ['swscale-9.dll', 'swscale-8.dll', 'swscale-7.dll'],
  'swresample': ['swresample-6.dll', 'swresample-5.dll', 'swresample-4.dll'],
};

final _macosSonameCandidates = {
  'avcodec': ['libavcodec.62.dylib', 'libavcodec.61.dylib', 'libavcodec.60.dylib'],
  'avformat': ['libavformat.62.dylib', 'libavformat.61.dylib', 'libavformat.60.dylib'],
  'avutil': ['libavutil.60.dylib', 'libavutil.59.dylib', 'libavutil.58.dylib'],
  'avfilter': ['libavfilter.11.dylib', 'libavfilter.10.dylib', 'libavfilter.9.dylib'],
  'swscale': ['libswscale.9.dylib', 'libswscale.8.dylib', 'libswscale.7.dylib'],
  'swresample': ['libswresample.6.dylib', 'libswresample.5.dylib', 'libswresample.4.dylib'],
};

DynamicLibrary _openLibrary(String name) {
  final candidates = Platform.isWindows
      ? _windowsSonameCandidates[name]
      : Platform.isMacOS
          ? _macosSonameCandidates[name]
          : ['lib$name.so'];

  String? lastError;
  for (final candidate in candidates ?? ['lib$name.so']) {
    try {
      return DynamicLibrary.open(candidate);
    } catch (e) {
      lastError = '$candidate: $e';
    }
  }
  throw UnsupportedError('无法加载 FFmpeg 库 $name: $lastError');
}

/// FFmpeg 绑定: 持有所有动态库引用和函数指针
class FFmpegBindings {
  late final DynamicLibrary avcodec;
  late final DynamicLibrary avformat;
  late final DynamicLibrary avutil;
  late final DynamicLibrary avfilter;
  late final DynamicLibrary swscale;
  late final DynamicLibrary swresample;

  FFmpegBindings() {
    avcodec = _openLibrary('avcodec');
    avformat = _openLibrary('avformat');
    avutil = _openLibrary('avutil');
    avfilter = _openLibrary('avfilter');
    swscale = _openLibrary('swscale');
    swresample = _openLibrary('swresample');
  }

  // --- libavformat ---

  late final avformatOpenInput = avformat.lookupFunction<AvFormatOpenInputNative, AvFormatOpenInputDart>('avformat_open_input');
  late final avformatFindStreamInfo = avformat.lookupFunction<AvFormatFindStreamInfoNative, AvFormatFindStreamInfoDart>('avformat_find_stream_info');
  late final avformatCloseInput = avformat.lookupFunction<AvFormatCloseInputNative, AvFormatCloseInputDart>('avformat_close_input');
  late final avReadFrame = avformat.lookupFunction<AvReadFrameNative, AvReadFrameDart>('av_read_frame');
  late final avSeekFrame = avformat.lookupFunction<AvSeekFrameNative, AvSeekFrameDart>('av_seek_frame');
  late final avformatSeekFile = avformat.lookupFunction<AvFormatSeekFileNative, AvFormatSeekFileDart>('avformat_seek_file');
  late final avFindBestStream = avformat.lookupFunction<AvFindBestStreamNative, AvFindBestStreamDart>('av_find_best_stream');
  late final avGuessFormat = avformat.lookupFunction<AvGuessFormatNative, AvGuessFormatDart>('av_guess_format');
  late final avformatAllocOutputContext2 = avformat.lookupFunction<AvformatAllocOutputContext2Native, AvformatAllocOutputContext2Dart>('avformat_alloc_output_context2');
  late final avformatNewStream = avformat.lookupFunction<AvformatNewStreamNative, AvformatNewStreamDart>('avformat_new_stream');
  late final avformatWriteHeader = avformat.lookupFunction<AvformatWriteHeaderNative, AvformatWriteHeaderDart>('avformat_write_header');
  late final avInterleavedWriteFrame = avformat.lookupFunction<AvInterleavedWriteFrameNative, AvInterleavedWriteFrameDart>('av_interleaved_write_frame');
  late final avWriteTrailer = avformat.lookupFunction<AvWriteTrailerNative, AvWriteTrailerDart>('av_write_trailer');
  late final avioOpen = avformat.lookupFunction<AvioOpenNative, AvioOpenDart>('avio_open');
  late final avioClosep = avformat.lookupFunction<AvioClosepNative, AvioClosepDart>('avio_closep');
  late final avformatFreeContext = avformat.lookupFunction<AvformatFreeContextNative, AvformatFreeContextDart>('avformat_free_context');

  // --- libavcodec ---

  late final avcodecAllocContext3 = avcodec.lookupFunction<AvcodecAllocContext3Native, AvcodecAllocContext3Dart>('avcodec_alloc_context3');
  late final avcodecParametersToContext = avcodec.lookupFunction<AvcodecParametersToContextNative, AvcodecParametersToContextDart>('avcodec_parameters_to_context');
  late final avcodecParametersFromContext = avcodec.lookupFunction<AvcodecParametersFromContextNative, AvcodecParametersFromContextDart>('avcodec_parameters_from_context');
  late final avcodecOpen2 = avcodec.lookupFunction<AvcodecOpen2Native, AvcodecOpen2Dart>('avcodec_open2');
  late final avcodecSendPacket = avcodec.lookupFunction<AvcodecSendPacketNative, AvcodecSendPacketDart>('avcodec_send_packet');
  late final avcodecReceiveFrame = avcodec.lookupFunction<AvcodecReceiveFrameNative, AvcodecReceiveFrameDart>('avcodec_receive_frame');
  late final avcodecFlushBuffers = avcodec.lookupFunction<AvcodecFlushBuffersNative, AvcodecFlushBuffersDart>('avcodec_flush_buffers');
  late final avcodecFreeContext = avcodec.lookupFunction<AvcodecFreeContextNative, AvcodecFreeContextDart>('avcodec_free_context');
  late final avcodecFindDecoder = avcodec.lookupFunction<AvcodecFindDecoderNative, AvcodecFindDecoderDart>('avcodec_find_decoder');
  late final avcodecFindEncoderByName = avcodec.lookupFunction<AvcodecFindEncoderByNameNative, AvcodecFindEncoderByNameDart>('avcodec_find_encoder_by_name');
  late final avcodecFindEncoder = avcodec.lookupFunction<AvcodecFindEncoderNative, AvcodecFindEncoderDart>('avcodec_find_encoder');
  late final avcodecSendFrame = avcodec.lookupFunction<AvcodecSendFrameNative, AvcodecSendFrameDart>('avcodec_send_frame');
  late final avcodecReceivePacket = avcodec.lookupFunction<AvcodecReceivePacketNative, AvcodecReceivePacketDart>('avcodec_receive_packet');
  late final avcodecGetHwConfig = avcodec.lookupFunction<AvcodecGetHwConfigNative, AvcodecGetHwConfigDart>('avcodec_get_hw_config');

  // --- libavutil ---

  late final avFrameAlloc = avutil.lookupFunction<AvFrameAllocNative, AvFrameAllocDart>('av_frame_alloc');
  late final avFrameFree = avutil.lookupFunction<AvFrameFreeNative, AvFrameFreeDart>('av_frame_free');
  late final avPacketAlloc = avutil.lookupFunction<AvPacketAllocNative, AvPacketAllocDart>('av_packet_alloc');
  late final avPacketFree = avutil.lookupFunction<AvPacketFreeNative, AvPacketFreeDart>('av_packet_free');
  late final avPacketUnref = avutil.lookupFunction<AvPacketUnrefNative, AvPacketUnrefDart>('av_packet_unref');
  late final avDictSet = avutil.lookupFunction<AvDictSetNative, AvDictSetDart>('av_dict_set');
  late final avDictSetInt = avutil.lookupFunction<AvDictSetIntNative, AvDictSetIntDart>('av_dict_set_int');
  late final avDictGet = avutil.lookupFunction<AvDictGetNative, AvDictGetDart>('av_dict_get');
  late final avDictFree = avutil.lookupFunction<AvDictFreeNative, AvDictFreeDart>('av_dict_free');
  late final avRescaleQ = avutil.lookupFunction<AvRescaleQNative, AvRescaleQDart>('av_rescale_q');
  late final avRescaleQRnd = avutil.lookupFunction<AvRescaleQRndNative, AvRescaleQRndDart>('av_rescale_q_rnd');
  late final avHwdeviceCtxCreate = avutil.lookupFunction<AvHwdeviceCtxCreateNative, AvHwdeviceCtxCreateDart>('av_hwdevice_ctx_create');
  late final avHwframeCtxAlloc = avutil.lookupFunction<AvHwframeCtxAllocNative, AvHwframeCtxAllocDart>('av_hwframe_ctx_alloc');
  late final avHwframeCtxInit = avutil.lookupFunction<AvHwframeCtxInitNative, AvHwframeCtxInitDart>('av_hwframe_ctx_init');
  late final avHwframeGetBuffer = avutil.lookupFunction<AvHwframeGetBufferNative, AvHwframeGetBufferDart>('av_hwframe_get_buffer');
  late final avHwframeTransferData = avutil.lookupFunction<AvHwframeTransferDataNative, AvHwframeTransferDataDart>('av_hwframe_transfer_data');
  late final avStrError = avutil.lookupFunction<AvStrErrorNative, AvStrErrorDart>('av_strerror');
  late final avGetMediaTypeString = avutil.lookupFunction<AvGetMediaTypeStringNative, AvGetMediaTypeStringDart>('av_get_media_type_string');
  late final avImageGetBufferSize = avutil.lookupFunction<AvImageGetBufferSizeNative, AvImageGetBufferSizeDart>('av_image_get_buffer_size');
  late final avImageFillArrays = avutil.lookupFunction<AvImageFillArraysNative, AvImageFillArraysDart>('av_image_fill_arrays');
  late final avSamplesGetBufferSize = avutil.lookupFunction<AvSamplesGetBufferSizeNative, AvSamplesGetBufferSizeDart>('av_samples_get_buffer_size');

  // --- libswscale ---

  late final swsGetContext = swscale.lookupFunction<SwsGetContextNative, SwsGetContextDart>('sws_getContext');
  late final swsScale = swscale.lookupFunction<SwsScaleNative, SwsScaleDart>('sws_scale');
  late final swsScaleFrame = swscale.lookupFunction<SwsScaleFrameNative, SwsScaleFrameDart>('sws_scale_frame');
  late final swsFreeContext = swscale.lookupFunction<SwsFreeContextNative, SwsFreeContextDart>('sws_freeContext');
  late final swsIsNoop = swscale.lookupFunction<SwsIsNoopNative, SwsIsNoopDart>('sws_is_noop');

  // --- libswresample ---

  late final swrAllocSetOpts2 = swresample.lookupFunction<SwrAllocSetOpts2Native, SwrAllocSetOpts2Dart>('swr_alloc_set_opts2');
  late final swrInit = swresample.lookupFunction<SwrInitNative, SwrInitDart>('swr_init');
  late final swrConvert = swresample.lookupFunction<SwrConvertNative, SwrConvertDart>('swr_convert');
  late final swrConvertFrame = swresample.lookupFunction<SwrConvertFrameNative, SwrConvertFrameDart>('swr_convert_frame');
  late final swrFree = swresample.lookupFunction<SwrFreeNative, SwrFreeDart>('swr_free');

  // --- libavfilter ---

  late final avfilterGraphAlloc = avfilter.lookupFunction<AvfilterGraphAllocNative, AvfilterGraphAllocDart>('avfilter_graph_alloc');
  late final avfilterGraphCreateFilter = avfilter.lookupFunction<AvfilterGraphCreateFilterNative, AvfilterGraphCreateFilterDart>('avfilter_graph_create_filter');
  late final avfilterGetByName = avfilter.lookupFunction<AvfilterGetByNameNative, AvfilterGetByNameDart>('avfilter_get_by_name');
  late final avfilterGraphParsePtr = avfilter.lookupFunction<AvfilterGraphParsePtrNative, AvfilterGraphParsePtrDart>('avfilter_graph_parse_ptr');
  late final avfilterGraphConfig = avfilter.lookupFunction<AvfilterGraphConfigNative, AvfilterGraphConfigDart>('avfilter_graph_config');
  late final avfilterGraphFree = avfilter.lookupFunction<AvfilterGraphFreeNative, AvfilterGraphFreeDart>('avfilter_graph_free');
  late final avfilterLink = avfilter.lookupFunction<AvfilterLinkNative, AvfilterLinkDart>('avfilter_link');
  late final avBuffersrcAddFrameFlags = avfilter.lookupFunction<AvBuffersrcAddFrameFlagsNative, AvBuffersrcAddFrameFlagsDart>('av_buffersrc_add_frame_flags');
  late final avBuffersinkGetFrame = avfilter.lookupFunction<AvBuffersinkGetFrameNative, AvBuffersinkGetFrameDart>('av_buffersink_get_frame');
}
