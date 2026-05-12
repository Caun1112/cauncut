// 工程文件模型 — JSON 序列化
import 'dart:convert';
import 'media_clip.dart';
import 'timeline_model.dart';
import 'export_settings.dart';

class ProjectFile {
  final int version;
  final String name;
  final String? lastSavedPath;
  final DateTime createdAt;
  final DateTime lastModified;
  final List<MediaClip> materialLibrary;
  final List<TimelineClip> timeline;
  final ExportSettings exportSettings;
  final List<String> missingFiles; // 上次打开时缺失的文件

  ProjectFile({
    this.version = 1,
    this.name = '新建工程',
    this.lastSavedPath,
    DateTime? createdAt,
    DateTime? lastModified,
    this.materialLibrary = const [],
    this.timeline = const [],
    this.exportSettings = const ExportSettings(),
    this.missingFiles = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now();

  ProjectFile copyWith({
    int? version,
    String? name,
    String? lastSavedPath,
    DateTime? lastModified,
    List<MediaClip>? materialLibrary,
    List<TimelineClip>? timeline,
    ExportSettings? exportSettings,
    List<String>? missingFiles,
  }) =>
      ProjectFile(
        version: version ?? this.version,
        name: name ?? this.name,
        lastSavedPath: lastSavedPath ?? this.lastSavedPath,
        createdAt: createdAt,
        lastModified: lastModified ?? DateTime.now(),
        materialLibrary: materialLibrary ?? this.materialLibrary,
        timeline: timeline ?? this.timeline,
        exportSettings: exportSettings ?? this.exportSettings,
        missingFiles: missingFiles ?? this.missingFiles,
      );

  Map<String, dynamic> toJson() => {
        'version': version,
        'name': name,
        'lastSavedPath': lastSavedPath,
        'createdAt': createdAt.toIso8601String(),
        'lastModified': lastModified.toIso8601String(),
        'materialLibrary': materialLibrary.map((c) => c.toJson()).toList(),
        'timeline': timeline.map((c) => c.toJson()).toList(),
        'exportSettings': exportSettings.toJson(),
        'missingFiles': missingFiles,
      };

  factory ProjectFile.fromJson(Map<String, dynamic> json) {
    return ProjectFile(
      version: json['version'] as int? ?? 1,
      name: json['name'] as String? ?? '未命名工程',
      lastSavedPath: json['lastSavedPath'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'] as String)
          : DateTime.now(),
      materialLibrary: (json['materialLibrary'] as List?)
              ?.map((e) => MediaClip.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timeline: (json['timeline'] as List?)
              ?.map((e) => TimelineClip.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      exportSettings: json['exportSettings'] != null
          ? ExportSettings.fromJson(
              json['exportSettings'] as Map<String, dynamic>)
          : const ExportSettings(),
      missingFiles: (json['missingFiles'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  String toJsonString() =>
      const JsonEncoder.withIndent('  ').convert(toJson());

  factory ProjectFile.fromJsonString(String jsonStr) =>
      ProjectFile.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}
