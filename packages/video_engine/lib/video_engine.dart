// video_engine - Flutter FFmpeg 视频引擎插件
// 提供: 解码/编码/Mux/缩略图提取 (通过 dart:ffi)
//       D3D11 纹理渲染 (通过 Windows Plugin C++)

library video_engine;

export 'src/ffi/ffmpeg_bindings.dart' show FFmpegBindings;
export 'src/ffi/ffmpeg_structs.dart'
  show
    AVFrame,
    AVPacket,
    AVRational,
    AVDictionary,
    AVCodecParameters,
    AVPixelFormat,
    AVSampleFormat,
    AVMediaType,
    Constants;
export 'src/decoder.dart' show VideoDecoder, VideoStreamInfo, AVSEEK_FLAG;
export 'src/encoder.dart'
  show VideoEncoder, AudioEncoder, Muxer, NvencConfig, AacConfig, AVCodecID;
export 'src/thumbnail_extractor.dart' show ThumbnailExtractor;
