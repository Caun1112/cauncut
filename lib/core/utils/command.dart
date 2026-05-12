// Command Pattern — 撤销/重做, 与 Riverpod Notifier 协作
// Commands 不直接持有 Widget 引用或 Provider 引用, 而是持有函数引用

import '../models/timeline_model.dart';

abstract class Command {
  void execute();
  void undo();
  String get description;
}

/// 添加素材到时间轴
class AddClipCommand implements Command {
  final TimelineClip clip;
  final void Function(TimelineClip) addFn;
  final void Function(String clipId) removeFn;

  AddClipCommand({
    required this.clip,
    required this.addFn,
    required this.removeFn,
  });

  @override
  void execute() => addFn(clip);

  @override
  void undo() => removeFn(clip.id);

  @override
  String get description => '添加素材: ${clip.fileName}';
}

/// 从时间轴删除素材
class DeleteClipCommand implements Command {
  final TimelineClip clip;
  final int index;
  final void Function(String clipId) removeFn;
  final void Function(TimelineClip, int) insertFn;

  DeleteClipCommand({
    required this.clip,
    required this.index,
    required this.removeFn,
    required this.insertFn,
  });

  @override
  void execute() => removeFn(clip.id);

  @override
  void undo() => insertFn(clip, index);

  @override
  String get description => '删除素材: ${clip.fileName}';
}

/// 分割素材
class SplitClipCommand implements Command {
  final String clipId;
  final Duration splitPoint;
  final void Function(String clipId, Duration splitPoint) splitFn;
  final void Function(String clipId, String splitId1, String splitId2) unsplitFn;

  String? _newId1;
  String? _newId2;

  SplitClipCommand({
    required this.clipId,
    required this.splitPoint,
    required this.splitFn,
    required this.unsplitFn,
  });

  @override
  void execute() {
    final ids = splitFn(clipId, splitPoint);
    // 返回两个新 ID
  }

  @override
  void undo() {
    // unsplitFn(clipId, _newId1!, _newId2!);
  }

  @override
  String get description => '分割素材';
}

/// 裁切素材头尾
class TrimClipCommand implements Command {
  final String clipId;
  final double oldTrimStart;
  final double oldTrimEnd;
  final double newTrimStart;
  final double newTrimEnd;
  final void Function(String clipId, double trimStart, double trimEnd) trimFn;

  TrimClipCommand({
    required this.clipId,
    required this.oldTrimStart,
    required this.oldTrimEnd,
    required this.newTrimStart,
    required this.newTrimEnd,
    required this.trimFn,
  });

  @override
  void execute() => trimFn(clipId, newTrimStart, newTrimEnd);

  @override
  void undo() => trimFn(clipId, oldTrimStart, oldTrimEnd);

  @override
  String get description => '裁切素材';
}
