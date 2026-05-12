// FFmpeg C 结构体的 Dart FFI 映射
// 基于 FFmpeg 8.1.1 头文件 (libavutil/frame.h, libavcodec/packet.h 等)
// Windows FFmpeg 7.1.4 兼容性: 核心字段偏移量相同
//
// 使用说明:
//   - 只映射需要用到的字段, 其余字段用 padding 占位
//   - AVFormatContext / AVCodecContext 等复杂类型走 Opaque, 不直接访问字段

// ignore_for_file: non_constant_identifier_names, unused_field

import 'dart:ffi';

// --- libavutil/rational.h ---

final class AVRational extends Struct {
  @Int32()
  external int num;

  @Int32()
  external int den;
}

// --- libavcodec/packet.h ---

final class AVPacket extends Struct {
  external Pointer<Void> buf; // AVBufferRef*

  @Int64()
  external int pts;

  @Int64()
  external int dts;

  external Pointer<Uint8> data;

  @Int32()
  external int size;

  @Int32()
  external int stream_index;

  @Int32()
  external int flags;

  @Array(12)
  external Array<Uint8> side_data_elems; // AVPacketSideData side_data[6] 的简化占位

  @Int32()
  external int side_data_elems_count;

  @Int64()
  external int duration;

  @Int64()
  external int pos;

  // 以下字段 FFmpeg >= 7.0 存在, 在旧版本中为 padding
  @Int64()
  external int opaque_ref; // AVBufferRef*
}

// --- libavutil/frame.h ---

final class AVFrame extends Struct {
  @Array(8)
  external Array<Pointer<Uint8>> data;

  @Array(8)
  external Array<Int32> linesize;

  external Pointer<Pointer<Uint8>> extended_data;

  @Int32()
  external int width;

  @Int32()
  external int height;

  @Int32()
  external int nb_samples;

  @Int32()
  external int format; // AVPixelFormat for video, AVSampleFormat for audio

  @Int32()
  external int key_frame;

  @Int32()
  external int pict_type; // AVPictureType

  external AVRational sample_aspect_ratio;

  @Int64()
  external int pts;

  // pkt_dts (watch cases: incorrect)
  @Int64()
  external int pkt_dts;

  external AVRational time_base;

  @Int32()
  external int coded_picture_number;

  @Int32()
  external int display_picture_number;

  @Int32()
  external int quality;

  @Int32()
  external int repeat_pict;

  @Int32()
  external int interlaced_frame;
  @Int32()
  external int top_field_first;
  @Int32()
  external int palette_has_changed;

  @Int64()
  external int reordered_opaque;

  @Int32()
  external int sample_rate;

  // buf 数组和扩展占据后续字段, 我们不直接访问
  @Array(16)
  external Array<Uint64> _padding1;
}

// --- libavutil/dict.h ---

final class AVDictionaryEntry extends Struct {
  external Pointer<Int8> key;
  external Pointer<Int8> value;
}

final class AVDictionary extends Struct {
  @Int32()
  external int count;

  external Pointer<AVDictionaryEntry> elems;
}

// --- libavcodec/codec_par.h ---

final class AVCodecParameters extends Struct {
  @Int32()
  external int codec_type; // AVMediaType

  @Int32()
  external int codec_id; // AVCodecID

  @Int32()
  external int codec_tag;

  @Array(8)
  external Array<Uint8> extradata_placeholder; // uint8_t*

  @Int32()
  external int extradata_size;

  @Int32()
  external int format; // AVPixelFormat or AVSampleFormat

  @Int64()
  external int bit_rate;

  @Int32()
  external int bits_per_coded_sample;

  @Int32()
  external int bits_per_raw_sample;

  @Int32()
  external int profile;
  @Int32()
  external int level;

  @Int32()
  external int width;
  @Int32()
  external int height;

  external AVRational sample_aspect_ratio;

  @Int32()
  external int field_order; // AVFieldOrder

  @Int32()
  external int color_range;
  @Int32()
  external int color_primaries;
  @Int32()
  external int color_trc;
  @Int32()
  external int color_space;
  @Int32()
  external int chroma_location;

  @Int32()
  external int video_delay;

  @Int64()
  external int channel_layout;
  @Int32()
  external int channels;
  @Int32()
  external int sample_rate;

  @Int32()
  external int block_align;
  @Int32()
  external int frame_size;

  @Int32()
  external int initial_padding;
  @Int32()
  external int trailing_padding;
  @Int32()
  external int seek_preroll;
}

// --- libavutil/pixfmt.h 常用像素格式常量 ---

abstract class AVPixelFormat {
  static const int none = -1;
  static const int yuv420p = 0;
  static const int yuyv422 = 1;
  static const int rgb24 = 2;
  static const int bgr24 = 3;
  static const int yuv422p = 4;
  static const int yuv444p = 5;
  static const int yuv410p = 6;
  static const int yuv411p = 7;
  static const int gray8 = 8;
  static const int monow = 9;
  static const int monob = 10;
  static const int pal8 = 11;
  static const int yuvj420p = 12;
  static const int yuvj422p = 13;
  static const int yuvj444p = 14;
  static const int uyvy422 = 15;
  static const int uyyvyy411 = 16;
  static const int bgr8 = 17;
  static const int bgr4 = 19;
  static const int bgr4Byte = 20;
  static const int rgb8 = 21;
  static const int rgb4 = 23;
  static const int rgb4Byte = 24;
  static const int nv12 = 25;
  static const int nv21 = 26;
  static const int argb = 27;
  static const int rgba = 28;
  static const int abgr = 29;
  static const int bgra = 30;
  static const int gray16be = 31;
  static const int gray16le = 32;
  static const int yuv440p = 33;
  static const int yuvj440p = 34;
  static const int yuva420p = 35;
  static const int rgb48be = 38;
  static const int rgb48le = 39;
  static const int yuv420p10le = 60;
  static const int yuv420p10be = 61;
  static const int yuv420p12le = 69;
  static const int yuv420p12be = 70;
  static const int yuv422p10le = 63;
  static const int yuv422p10be = 64;
  static const int yuv444p10le = 66;
  static const int yuv444p10be = 67;
  static const int yuv420p16le = 117;
  static const int yuv420p16be = 118;
  static const int yuv422p16le = 120;
  static const int yuv422p16be = 121;
  static const int yuv444p16le = 123;
  static const int yuv444p16be = 124;
  static const int yuva420p9be = 46;
  static const int yuva420p9le = 47;
  static const int yuva422p9be = 42;
  static const int yuva422p9le = 43;
  static const int yuva444p9be = 44;
  static const int yuva444p9le = 45;
  static const int yuva420p10be = 49;
  static const int yuva420p10le = 48;
  static const int yuva422p10be = 51;
  static const int yuva422p10le = 50;
  static const int yuva444p10be = 53;
  static const int yuva444p10le = 52;
  static const int yuva420p16be = 57;
  static const int yuva420p16le = 56;
  static const int yuva422p16be = 59;
  static const int yuva422p16le = 58;
  static const int yuva444p16be = 55;
  static const int yuva444p16le = 54;
  static const int rgba64be = 122;
  static const int rgba64le = 121;
  static const int bgra64be = 124;
  static const int bgra64le = 123;
  static const int yuv420p9be = 65;
  static const int yuv420p9le = 62;
  static const int gbrp = 72;
  static const int gbrp9be = 86;
  static const int gbrp9le = 85;
  static const int gbrp10be = 88;
  static const int gbrp10le = 87;
  static const int gbrp16be = 90;
  static const int gbrp16le = 89;
  static const int cuda = 203; // AV_PIX_FMT_CUDA
  static const int d3d11 = 175; // AV_PIX_FMT_D3D11
}

// --- libavutil/samplefmt.h 常用采样格式常量 ---

abstract class AVSampleFormat {
  static const int none = -1;
  static const int u8 = 0;
  static const int s16 = 1;
  static const int s32 = 2;
  static const int flt = 3;
  static const int dbl = 4;
  static const int u8p = 5;
  static const int s16p = 6;
  static const int s32p = 7;
  static const int fltp = 8;
  static const int dblp = 9;
  static const int s64 = 10;
  static const int s64p = 11;
}

// --- libavutil/avutil.h 通用常量 ---

abstract class AVMediaType {
  static const int unknown = -1;
  static const int video = 0;
  static const int audio = 1;
  static const int data = 2;
  static const int subtitle = 3;
  static const int attachment = 4;
  static const int nb = 5;
}

abstract class Constants {
  static const int avTimeBase = 1000000; // AV_TIME_BASE
  static const int avNoptsValue = -((1 << 63) + 1); // AV_NOPTS_VALUE
}

// --- libavutil/error.h ---

abstract class AVError {
  static const int eof = -541478725; // AVERROR_EOF (may vary by platform)
  static const int eagain = -11; // AVERROR(EAGAIN)
}
