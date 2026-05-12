// 工程文件 I/O 服务 — 保存/加载/自动保存/文件验证
import 'dart:async';
import 'dart:io';
import '../models/project.dart';
import '../models/media_clip.dart';

class ProjectService {
  static const autoSaveSuffix = '.autosave';

  /// 保存工程到指定路径
  Future<void> save(ProjectFile project, String path) async {
    final file = File(path);
    final jsonStr = project.toJsonString();
    await file.writeAsString(jsonStr);
  }

  /// 从路径加载工程
  Future<ProjectFile> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('工程文件不存在', path);
    }
    final jsonStr = await file.readAsString();
    return ProjectFile.fromJsonString(jsonStr);
  }

  /// 自动保存到临时文件
  Future<void> autoSave(ProjectFile project, String sourcePath) async {
    final autoPath = '$sourcePath$autoSaveSuffix';
    await save(project, autoPath);
  }

  /// 检查是否存在自动保存文件
  Future<String?> findAutoSave(String sourcePath) async {
    final autoPath = '$sourcePath$autoSaveSuffix';
    final file = File(autoPath);
    if (await file.exists()) {
      return autoPath;
    }
    return null;
  }

  /// 验证素材文件是否存在
  Future<List<String>> validateFiles(List<MediaClip> clips) async {
    final missing = <String>[];
    for (final clip in clips) {
      if (!await File(clip.filePath).exists()) {
        missing.add(clip.filePath);
      }
    }
    return missing;
  }

  /// 检测自动保存文件是否比主文件更新
  Future<bool> isAutoSaveNewer(String sourcePath) async {
    final autoPath = '$sourcePath$autoSaveSuffix';
    final autoFile = File(autoPath);
    final mainFile = File(sourcePath);

    if (!await autoFile.exists()) return false;
    if (!await mainFile.exists()) return true;

    final autoModified = await autoFile.lastModified();
    final mainModified = await mainFile.lastModified();
    return autoModified.isAfter(mainModified);
  }
}
