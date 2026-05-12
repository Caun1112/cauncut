// 时间轴数据模型 — 扁平单轨道

class TimelineClip {
  final String id;
  final String mediaClipId;
  final String filePath;
  final String fileName;
  final Duration sourceDuration;
  final Duration timelineIn;
  final Duration duration;
  final double trimStart; // 0.0 ~ 1.0
  final double trimEnd; // 0.0 ~ 1.0
  final bool isMuted;
  final int sourceWidth;
  final int sourceHeight;

  const TimelineClip({
    required this.id,
    required this.mediaClipId,
    required this.filePath,
    required this.fileName,
    required this.sourceDuration,
    required this.timelineIn,
    required this.duration,
    this.trimStart = 0.0,
    this.trimEnd = 1.0,
    this.isMuted = false,
    this.sourceWidth = 1920,
    this.sourceHeight = 1080,
  });

  Duration get timelineOut => timelineIn + duration;
  Duration get trimmedDuration =>
      sourceDuration * (trimEnd - trimStart);

  Duration get effectiveDuration => duration;

  TimelineClip copyWith({
    String? id,
    String? mediaClipId,
    String? filePath,
    String? fileName,
    Duration? sourceDuration,
    Duration? timelineIn,
    Duration? duration,
    double? trimStart,
    double? trimEnd,
    bool? isMuted,
    int? sourceWidth,
    int? sourceHeight,
  }) =>
      TimelineClip(
        id: id ?? this.id,
        mediaClipId: mediaClipId ?? this.mediaClipId,
        filePath: filePath ?? this.filePath,
        fileName: fileName ?? this.fileName,
        sourceDuration: sourceDuration ?? this.sourceDuration,
        timelineIn: timelineIn ?? this.timelineIn,
        duration: duration ?? this.duration,
        trimStart: trimStart ?? this.trimStart,
        trimEnd: trimEnd ?? this.trimEnd,
        isMuted: isMuted ?? this.isMuted,
        sourceWidth: sourceWidth ?? this.sourceWidth,
        sourceHeight: sourceHeight ?? this.sourceHeight,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'mediaClipId': mediaClipId,
        'filePath': filePath,
        'fileName': fileName,
        'sourceDuration': sourceDuration.inMicroseconds,
        'timelineIn': timelineIn.inMicroseconds,
        'duration': duration.inMicroseconds,
        'trimStart': trimStart,
        'trimEnd': trimEnd,
        'isMuted': isMuted,
        'sourceWidth': sourceWidth,
        'sourceHeight': sourceHeight,
      };

  factory TimelineClip.fromJson(Map<String, dynamic> json) => TimelineClip(
        id: json['id'] as String,
        mediaClipId: json['mediaClipId'] as String,
        filePath: json['filePath'] as String,
        fileName: json['fileName'] as String,
        sourceDuration: Duration(microseconds: json['sourceDuration'] as int),
        timelineIn: Duration(microseconds: json['timelineIn'] as int),
        duration: Duration(microseconds: json['duration'] as int),
        trimStart: (json['trimStart'] as num).toDouble(),
        trimEnd: (json['trimEnd'] as num).toDouble(),
        isMuted: json['isMuted'] as bool,
        sourceWidth: json['sourceWidth'] as int? ?? 1920,
        sourceHeight: json['sourceHeight'] as int? ?? 1080,
      );
}

class TimelineState {
  final List<TimelineClip> clips;
  final Duration cursorPosition;
  final double zoomLevel; // 像素/秒

  const TimelineState({
    this.clips = const [],
    this.cursorPosition = Duration.zero,
    this.zoomLevel = 50.0, // 默认 50px/s
  });

  Duration get totalDuration {
    if (clips.isEmpty) return Duration.zero;
    return clips.map((c) => c.timelineIn + c.duration).reduce(
          (a, b) => a > b ? a : b,
        );
  }

  TimelineClip? clipAtPosition(Duration pos) {
    for (final clip in clips) {
      if (pos >= clip.timelineIn && pos < clip.timelineOut) return clip;
    }
    return null;
  }

  int? clipIndexAtPosition(Duration pos) {
    for (int i = 0; i < clips.length; i++) {
      final clip = clips[i];
      if (pos >= clip.timelineIn && pos < clip.timelineOut) return i;
    }
    return null;
  }

  TimelineState copyWith({
    List<TimelineClip>? clips,
    Duration? cursorPosition,
    double? zoomLevel,
  }) =>
      TimelineState(
        clips: clips ?? this.clips,
        cursorPosition: cursorPosition ?? this.cursorPosition,
        zoomLevel: zoomLevel ?? this.zoomLevel,
      );
}
