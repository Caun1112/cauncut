// 素材库中的媒体剪辑

import 'dart:ui';

enum ImportStatus { importing, ready, failed }

class MediaClip {
  final String id;
  final String filePath;
  final String fileName;
  final Duration duration;
  final int width;
  final int height;
  final double frameRate;
  final ImportStatus status;
  final String? errorMessage;

  const MediaClip({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.duration,
    required this.width,
    required this.height,
    required this.frameRate,
    this.status = ImportStatus.ready,
    this.errorMessage,
  });

  MediaClip copyWith({
    String? id,
    String? filePath,
    String? fileName,
    Duration? duration,
    int? width,
    int? height,
    double? frameRate,
    ImportStatus? status,
    String? errorMessage,
  }) =>
      MediaClip(
        id: id ?? this.id,
        filePath: filePath ?? this.filePath,
        fileName: fileName ?? this.fileName,
        duration: duration ?? this.duration,
        width: width ?? this.width,
        height: height ?? this.height,
        frameRate: frameRate ?? this.frameRate,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  double get aspectRatio => height > 0 ? width / height : 16 / 9;

  Map<String, dynamic> toJson() => {
        'id': id,
        'filePath': filePath,
        'fileName': fileName,
        'duration': duration.inMicroseconds,
        'width': width,
        'height': height,
        'frameRate': frameRate,
        'status': status.name,
        'errorMessage': errorMessage,
      };

  factory MediaClip.fromJson(Map<String, dynamic> json) => MediaClip(
        id: json['id'] as String,
        filePath: json['filePath'] as String,
        fileName: json['fileName'] as String,
        duration: Duration(microseconds: json['duration'] as int),
        width: json['width'] as int,
        height: json['height'] as int,
        frameRate: (json['frameRate'] as num).toDouble(),
        status: ImportStatus.values.byName(json['status'] as String),
        errorMessage: json['errorMessage'] as String?,
      );
}
