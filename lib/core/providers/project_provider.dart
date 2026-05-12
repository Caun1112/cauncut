// 全局工程状态提供者 — 素材库, 时间轴, 导出设置
// ignore_for_file: avoid_manual_providers_as_generated_provider_dependency

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/media_clip.dart';
import '../models/timeline_model.dart';
import '../models/export_settings.dart';
import '../models/project.dart';
import '../services/project_service.dart';

/// 素材库 Provider
class MaterialLibraryNotifier extends StateNotifier<List<MediaClip>> {
  MaterialLibraryNotifier() : super([]);

  void addClip(MediaClip clip) {
    state = [...state, clip];
    _sortByDuration();
  }

  void addClips(List<MediaClip> clips) {
    state = [...state, ...clips];
    _sortByDuration();
  }

  void removeClip(String id) {
    state = state.where((c) => c.id != id).toList();
  }

  void updateClipStatus(String id, ImportStatus status, {String? errorMessage}) {
    state = state.map((c) {
      if (c.id == id) return c.copyWith(status: status, errorMessage: errorMessage);
      return c;
    }).toList();
  }

  void _sortByDuration() {
    state = [...state]..sort((a, b) => b.duration.compareTo(a.duration));
  }
}

final materialLibraryProvider =
    StateNotifierProvider<MaterialLibraryNotifier, List<MediaClip>>(
  (ref) => MaterialLibraryNotifier(),
);

/// 时间轴 Provider
class TimelineNotifier extends StateNotifier<TimelineState> {
  TimelineNotifier() : super(const TimelineState());

  void addClip(TimelineClip clip) {
    final clips = [...state.clips, clip];
    state = state.copyWith(clips: clips);
  }

  void removeClip(String clipId) {
    final clips = state.clips.where((c) => c.id != clipId).toList();
    state = state.copyWith(clips: clips);
  }

  void setCursor(Duration position) {
    state = state.copyWith(cursorPosition: position);
  }

  void zoom(double factor) {
    final newZoom = (state.zoomLevel * factor).clamp(5.0, 500.0);
    state = state.copyWith(zoomLevel: newZoom);
  }

  void setZoom(double level) {
    state = state.copyWith(zoomLevel: level.clamp(5.0, 500.0));
  }

  void jumpToPrevClip() {
    final cursor = state.cursorPosition;
    // 找到游标前最近的 clip 边界
    Duration? prevBoundary;
    for (final clip in state.clips) {
      if (clip.timelineIn < cursor &&
          (prevBoundary == null || clip.timelineIn > prevBoundary)) {
        prevBoundary = clip.timelineIn;
      }
      if (clip.timelineOut < cursor &&
          (prevBoundary == null || clip.timelineOut > prevBoundary)) {
        prevBoundary = clip.timelineOut;
      }
    }
    state = state.copyWith(cursorPosition: prevBoundary ?? Duration.zero);
  }

  void jumpToNextClip() {
    final cursor = state.cursorPosition;
    Duration? nextBoundary;
    for (final clip in state.clips) {
      if (clip.timelineIn > cursor &&
          (nextBoundary == null || clip.timelineIn < nextBoundary)) {
        nextBoundary = clip.timelineIn;
      }
      if (clip.timelineOut > cursor &&
          (nextBoundary == null || clip.timelineOut < nextBoundary)) {
        nextBoundary = clip.timelineOut;
      }
    }
    state = state.copyWith(
        cursorPosition: nextBoundary ?? state.totalDuration);
  }

  void jumpToStart() => state = state.copyWith(cursorPosition: Duration.zero);
  void jumpToEnd() =>
      state = state.copyWith(cursorPosition: state.totalDuration);

  void stepForward(double fps) {
    final step = Duration(microseconds: (1000000 / fps).round());
    state = state.copyWith(cursorPosition: state.cursorPosition + step);
  }

  void stepBackward(double fps) {
    final step = Duration(microseconds: (1000000 / fps).round());
    final newPos = state.cursorPosition - step;
    state = state.copyWith(cursorPosition: newPos < Duration.zero ? Duration.zero : newPos);
  }
}

final timelineProvider =
    StateNotifierProvider<TimelineNotifier, TimelineState>(
  (ref) => TimelineNotifier(),
);

/// 导出设置 Provider
class ExportSettingsNotifier extends StateNotifier<ExportSettings> {
  ExportSettingsNotifier() : super(const ExportSettings());

  void update(ExportSettings Function(ExportSettings) updater) {
    state = updater(state);
  }
}

final exportSettingsProvider =
    StateNotifierProvider<ExportSettingsNotifier, ExportSettings>(
  (ref) => ExportSettingsNotifier(),
);

/// 预览状态 Provider
class PreviewNotifier extends StateNotifier<PreviewState> {
  PreviewNotifier() : super(const PreviewState());

  void previewClip(MediaClip clip) {
    state = PreviewState(
      currentClipId: clip.id,
      currentClipPath: clip.filePath,
      isPlaying: false,
      currentPosition: Duration.zero,
      fitMode: 'fit',
      outputAspect: '16:9',
    );
  }

  void previewTimelineAt(Duration position) {
    state = state.copyWith(currentPosition: position);
  }

  void play() => state = state.copyWith(isPlaying: true);
  void pause() => state = state.copyWith(isPlaying: false);
  void togglePlay() => state = state.copyWith(isPlaying: !state.isPlaying);
  void setFitMode(String mode) => state = state.copyWith(fitMode: mode);
  void setAspect(String aspect) =>
      state = state.copyWith(outputAspect: aspect);
}

class PreviewState {
  final String? currentClipId;
  final String? currentClipPath;
  final bool isPlaying;
  final Duration currentPosition;
  final String fitMode;
  final String outputAspect;

  const PreviewState({
    this.currentClipId,
    this.currentClipPath,
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
    this.fitMode = 'fit',
    this.outputAspect = '16:9',
  });

  PreviewState copyWith({
    String? currentClipId,
    String? currentClipPath,
    bool? isPlaying,
    Duration? currentPosition,
    String? fitMode,
    String? outputAspect,
  }) =>
      PreviewState(
        currentClipId: currentClipId ?? this.currentClipId,
        currentClipPath: currentClipPath ?? this.currentClipPath,
        isPlaying: isPlaying ?? this.isPlaying,
        currentPosition: currentPosition ?? this.currentPosition,
        fitMode: fitMode ?? this.fitMode,
        outputAspect: outputAspect ?? this.outputAspect,
      );
}

final previewProvider = StateNotifierProvider<PreviewNotifier, PreviewState>(
  (ref) => PreviewNotifier(),
);

/// 工程管理 Provider — 保存/加载/脏标记
class ProjectManagerNotifier extends StateNotifier<ProjectFile> {
  final ProjectService _service = ProjectService();

  ProjectManagerNotifier() : super(ProjectFile());

  Future<void> newProject() async {
    state = ProjectFile(name: '新建工程_${DateTime.now().millisecondsSinceEpoch}');
  }

  Future<void> save(String path) async {
    state = state.copyWith(lastSavedPath: path, lastModified: DateTime.now());
    await _service.save(state, path);
  }

  Future<void> saveAs() async {
    // TODO: 弹出文件保存对话框
  }

  Future<void> load(String path) async {
    // 检查自动保存
    if (await _service.isAutoSaveNewer(path)) {
      // TODO: 显示恢复提示
    }
    state = await _service.load(path);
  }

  /// 同步状态到工程文件 (素材库/时间轴/导出设置)
  void syncFromState(
    List<MediaClip> materialLib,
    TimelineState timelineState,
    ExportSettings exportSettings,
  ) {
    state = state.copyWith(
      materialLibrary: materialLib,
      timeline: timelineState.clips,
      exportSettings: exportSettings,
      lastModified: DateTime.now(),
    );
  }

  /// 验证素材文件
  Future<List<String>> validateFiles() async {
    return _service.validateFiles(state.materialLibrary);
  }
}

final projectManagerProvider =
    StateNotifierProvider<ProjectManagerNotifier, ProjectFile>(
  (ref) => ProjectManagerNotifier(),
);

/// 自动保存 Provider — 5 分钟定时保存
class AutoSaveNotifier extends StateNotifier<AutoSaveState> {
  Timer? _timer;

  AutoSaveNotifier(this.ref) : super(const AutoSaveState());

  final Ref ref;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void markDirty() {
    if (!state.isDirty) {
      state = state.copyWith(isDirty: true);
    }
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _timer?.cancel();
    _timer = Timer(const Duration(minutes: 5), _performAutoSave);
  }

  Future<void> _performAutoSave() async {
    if (!state.isDirty) return;

    final project = ref.read(projectManagerProvider);
    final path = project.lastSavedPath;
    if (path == null) return;

    state = state.copyWith(isSaving: true);
    try {
      final service = ProjectService();
      await service.autoSave(project, path);
      state = AutoSaveState(
        isDirty: false,
        lastSaved: DateTime.now(),
      );
    } catch (_) {
      state = state.copyWith(isSaving: false);
    }
  }
}

class AutoSaveState {
  final bool isDirty;
  final bool isSaving;
  final DateTime? lastSaved;

  const AutoSaveState({
    this.isDirty = false,
    this.isSaving = false,
    this.lastSaved,
  });

  AutoSaveState copyWith({bool? isDirty, bool? isSaving, DateTime? lastSaved}) =>
      AutoSaveState(
        isDirty: isDirty ?? this.isDirty,
        isSaving: isSaving ?? this.isSaving,
        lastSaved: lastSaved ?? this.lastSaved,
      );
}

final autoSaveProvider =
    StateNotifierProvider.autoDispose<AutoSaveNotifier, AutoSaveState>(
  (ref) => AutoSaveNotifier(ref),
);

/// 工程文件路径 Provider
final projectPathProvider = StateProvider<String?>((ref) => null);
