// 导出设置模型

class ExportSettings {
  final String title;
  final String outputPath;
  final String format; // "mp4" | "mov"
  final String resolutionPreset; // "1080p" | "4K" | "720p" | "custom"
  final int customWidth;
  final int customHeight;
  final bool lockAspectRatio;
  final double frameRate; // 23.976, 24, 25, 29.97, 30, 50, 60
  final bool useCustomFrameRate;
  final String bitrateMode; // "cbr" | "vbr"
  final int targetBitrateKbps;
  final int maxBitrateKbps;
  final int qualityLevel; // 0-51, VBR CQ
  final String videoCodec; // "h264_nvenc" | "hevc_nvenc"
  final bool includeAudio;
  final int audioBitrateKbps;
  final int audioSampleRate;
  final String fitMode; // "fit" | "fill"
  final String outputAspect; // "16:9" | "4:3" | "3:4" | "1:1"

  const ExportSettings({
    this.title = '',
    this.outputPath = '',
    this.format = 'mp4',
    this.resolutionPreset = '1080p',
    this.customWidth = 1920,
    this.customHeight = 1080,
    this.lockAspectRatio = true,
    this.frameRate = 30,
    this.useCustomFrameRate = false,
    this.bitrateMode = 'vbr',
    this.targetBitrateKbps = 5000,
    this.maxBitrateKbps = 10000,
    this.qualityLevel = 23,
    this.videoCodec = 'h264_nvenc',
    this.includeAudio = true,
    this.audioBitrateKbps = 128,
    this.audioSampleRate = 48000,
    this.fitMode = 'fit',
    this.outputAspect = '16:9',
  });

  static const resolutionPresets = {
    '4K': (3840, 2160),
    '1440p': (2560, 1440),
    '1080p': (1920, 1080),
    '720p': (1280, 720),
    '480p': (854, 480),
  };

  static const aspectRatios = {
    '16:9': 16 / 9,
    '4:3': 4 / 3,
    '3:4': 3 / 4,
    '1:1': 1.0,
  };

  static const frameRatePresets = [23.976, 24, 25, 29.97, 30, 50, 59.94, 60];

  static const audioBitratePresets = [96, 128, 192, 256, 320];

  static const audioSampleRatePresets = [44100, 48000, 96000];

  int get outputWidth {
    final preset = resolutionPresets[resolutionPreset];
    if (preset != null) return preset.$1;
    return customWidth;
  }

  int get outputHeight {
    final preset = resolutionPresets[resolutionPreset];
    if (preset != null) return preset.$2;
    return customHeight;
  }

  ExportSettings copyWith({
    String? title,
    String? outputPath,
    String? format,
    String? resolutionPreset,
    int? customWidth,
    int? customHeight,
    bool? lockAspectRatio,
    double? frameRate,
    bool? useCustomFrameRate,
    String? bitrateMode,
    int? targetBitrateKbps,
    int? maxBitrateKbps,
    int? qualityLevel,
    String? videoCodec,
    bool? includeAudio,
    int? audioBitrateKbps,
    int? audioSampleRate,
    String? fitMode,
    String? outputAspect,
  }) =>
      ExportSettings(
        title: title ?? this.title,
        outputPath: outputPath ?? this.outputPath,
        format: format ?? this.format,
        resolutionPreset: resolutionPreset ?? this.resolutionPreset,
        customWidth: customWidth ?? this.customWidth,
        customHeight: customHeight ?? this.customHeight,
        lockAspectRatio: lockAspectRatio ?? this.lockAspectRatio,
        frameRate: frameRate ?? this.frameRate,
        useCustomFrameRate: useCustomFrameRate ?? this.useCustomFrameRate,
        bitrateMode: bitrateMode ?? this.bitrateMode,
        targetBitrateKbps: targetBitrateKbps ?? this.targetBitrateKbps,
        maxBitrateKbps: maxBitrateKbps ?? this.maxBitrateKbps,
        qualityLevel: qualityLevel ?? this.qualityLevel,
        videoCodec: videoCodec ?? this.videoCodec,
        includeAudio: includeAudio ?? this.includeAudio,
        audioBitrateKbps: audioBitrateKbps ?? this.audioBitrateKbps,
        audioSampleRate: audioSampleRate ?? this.audioSampleRate,
        fitMode: fitMode ?? this.fitMode,
        outputAspect: outputAspect ?? this.outputAspect,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'outputPath': outputPath,
        'format': format,
        'resolutionPreset': resolutionPreset,
        'customWidth': customWidth,
        'customHeight': customHeight,
        'lockAspectRatio': lockAspectRatio,
        'frameRate': frameRate,
        'useCustomFrameRate': useCustomFrameRate,
        'bitrateMode': bitrateMode,
        'targetBitrateKbps': targetBitrateKbps,
        'maxBitrateKbps': maxBitrateKbps,
        'qualityLevel': qualityLevel,
        'videoCodec': videoCodec,
        'includeAudio': includeAudio,
        'audioBitrateKbps': audioBitrateKbps,
        'audioSampleRate': audioSampleRate,
        'fitMode': fitMode,
        'outputAspect': outputAspect,
      };

  factory ExportSettings.fromJson(Map<String, dynamic> json) => ExportSettings(
        title: json['title'] as String? ?? '',
        outputPath: json['outputPath'] as String? ?? '',
        format: json['format'] as String? ?? 'mp4',
        resolutionPreset: json['resolutionPreset'] as String? ?? '1080p',
        customWidth: json['customWidth'] as int? ?? 1920,
        customHeight: json['customHeight'] as int? ?? 1080,
        lockAspectRatio: json['lockAspectRatio'] as bool? ?? true,
        frameRate: (json['frameRate'] as num?)?.toDouble() ?? 30,
        useCustomFrameRate: json['useCustomFrameRate'] as bool? ?? false,
        bitrateMode: json['bitrateMode'] as String? ?? 'vbr',
        targetBitrateKbps: json['targetBitrateKbps'] as int? ?? 5000,
        maxBitrateKbps: json['maxBitrateKbps'] as int? ?? 10000,
        qualityLevel: json['qualityLevel'] as int? ?? 23,
        videoCodec: json['videoCodec'] as String? ?? 'h264_nvenc',
        includeAudio: json['includeAudio'] as bool? ?? true,
        audioBitrateKbps: json['audioBitrateKbps'] as int? ?? 128,
        audioSampleRate: json['audioSampleRate'] as int? ?? 48000,
        fitMode: json['fitMode'] as String? ?? 'fit',
        outputAspect: json['outputAspect'] as String? ?? '16:9',
      );
}
