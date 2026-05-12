// App 主界面: 三栏布局 + 快捷键 + 菜单栏
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/project_provider.dart';
import '../core/services/project_service.dart';
import '../features/material_library/widgets/material_library_panel.dart';
import '../features/preview/widgets/preview_panel.dart';
import '../features/timeline/widgets/timeline_panel.dart';
import '../features/export/widgets/export_panel.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _buildShortcuts(),
      child: Actions(
        actions: _buildActions(),
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: Column(
              children: [
                _buildMenuBar(),
                Expanded(
                  child: Row(
                    children: [
                      // 左侧: 素材库
                      SizedBox(
                        width: 260,
                        child: MaterialLibraryPanel(
                          onClipSelected: (clip) {
                            ref.read(previewProvider.notifier).previewClip(clip);
                          },
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      // 中间: 播放器预览
                      Expanded(child: PreviewPanel()),
                      const VerticalDivider(width: 1),
                    ],
                  ),
                ),
              ],
            ),
            // 底部: 时间轴
            bottomSheet: SizedBox(
              height: 200,
              child: TimelinePanel(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuBar() {
    return Container(
      height: 32,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          const SizedBox(width: 8),
          MenuBar(
            children: [
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    onPressed: () => ref.read(projectManagerProvider.notifier).newProject(),
                    child: const Text('新建工程'),
                  ),
                  MenuItemButton(
                    onPressed: () {},
                    child: const Text('打开工程...'),
                  ),
                  MenuItemButton(
                    onPressed: _handleSave,
                    child: const Text('保存'),
                  ),
                  const Divider(),
                  MenuItemButton(
                    onPressed: _showExportDialog,
                    child: const Text('导出...'),
                  ),
                ],
                child: const Text('文件'),
              ),
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    onPressed: () =>
                        ref.read(timelineProvider.notifier).jumpToPrevClip(),
                    child: const Text('撤销'),
                  ),
                  MenuItemButton(
                    onPressed: () {},
                    child: const Text('重做'),
                  ),
                ],
                child: const Text('编辑'),
              ),
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    onPressed: () {},
                    child: const Text('适应'),
                  ),
                  MenuItemButton(
                    onPressed: () {},
                    child: const Text('16:9'),
                  ),
                  MenuItemButton(
                    onPressed: () {},
                    child: const Text('4:3'),
                  ),
                ],
                child: const Text('视图'),
              ),
            ],
          ),
          const Spacer(),
          Text('Cauncut', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Map<ShortcutActivator, Intent> _buildShortcuts() {
    return {
      // 播放控制
      const SingleActivator(LogicalKeyboardKey.space):
          const PlayPauseIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowUp):
          const JumpToPrevIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowDown):
          const JumpToNextIntent(),
      const SingleActivator(LogicalKeyboardKey.home):
          const JumpToStartIntent(),
      const SingleActivator(LogicalKeyboardKey.end): const JumpToEndIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowLeft):
          const StepBackIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowRight):
          const StepForwardIntent(),
      // 编辑
      const SingleActivator(LogicalKeyboardKey.keyS):
          const SplitClipIntent(),
      const SingleActivator(LogicalKeyboardKey.delete):
          const DeleteClipIntent(),
      const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
          const UndoIntent(),
      SingleActivator(LogicalKeyboardKey.keyZ,
          control: true, shift: true): const RedoIntent(),
      const SingleActivator(LogicalKeyboardKey.escape):
          const DeselectIntent(),
      // 文件
      const SingleActivator(LogicalKeyboardKey.keyS, control: true):
          const SaveIntent(),
      const SingleActivator(LogicalKeyboardKey.keyE, control: true):
          const ExportIntent(),
    };
  }

  Map<Type, Action<Intent>> _buildActions() {
    final timeline = ref.read(timelineProvider.notifier);
    final preview = ref.read(previewProvider.notifier);

    return {
      PlayPauseIntent: CallbackAction<PlayPauseIntent>(
        onInvoke: (_) => preview.togglePlay(),
      ),
      JumpToPrevIntent: CallbackAction<JumpToPrevIntent>(
        onInvoke: (_) => timeline.jumpToPrevClip(),
      ),
      JumpToNextIntent: CallbackAction<JumpToNextIntent>(
        onInvoke: (_) => timeline.jumpToNextClip(),
      ),
      JumpToStartIntent: CallbackAction<JumpToStartIntent>(
        onInvoke: (_) => timeline.jumpToStart(),
      ),
      JumpToEndIntent: CallbackAction<JumpToEndIntent>(
        onInvoke: (_) => timeline.jumpToEnd(),
      ),
      StepBackIntent: CallbackAction<StepBackIntent>(
        onInvoke: (_) => timeline.stepBackward(30),
      ),
      StepForwardIntent: CallbackAction<StepForwardIntent>(
        onInvoke: (_) => timeline.stepForward(30),
      ),
      UndoIntent: CallbackAction<UndoIntent>(
        onInvoke: (_) {
          // TODO: ref.read(historyProvider.notifier).undo();
        },
      ),
      RedoIntent: CallbackAction<RedoIntent>(
        onInvoke: (_) {
          // TODO: ref.read(historyProvider.notifier).redo();
        },
      ),
      SaveIntent: CallbackAction<SaveIntent>(
        onInvoke: (_) => _handleSave(),
      ),
      ExportIntent: CallbackAction<ExportIntent>(
        onInvoke: (_) => _showExportDialog(),
      ),
    };
  }

  void _handleSave() {
    final project = ref.read(projectManagerProvider);
    if (project.lastSavedPath != null) {
      ref.read(projectManagerProvider.notifier).syncFromState(
            ref.read(materialLibraryProvider),
            ref.read(timelineProvider),
            ref.read(exportSettingsProvider),
          );
      ref.read(projectManagerProvider.notifier).save(project.lastSavedPath!);
    } else {
      _handleSaveAs();
    }
  }

  void _handleSaveAs() {
    // TODO: 文件保存对话框
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (_) => const ExportPanel(),
    );
  }
}

// --- Intent 定义 ---

// --- Intent 定义 ---
class PlayPauseIntent extends Intent {
  const PlayPauseIntent();
}

class JumpToPrevIntent extends Intent {
  const JumpToPrevIntent();
}

class JumpToNextIntent extends Intent {
  const JumpToNextIntent();
}

class JumpToStartIntent extends Intent {
  const JumpToStartIntent();
}

class JumpToEndIntent extends Intent {
  const JumpToEndIntent();
}

class StepBackIntent extends Intent {
  const StepBackIntent();
}

class StepForwardIntent extends Intent {
  const StepForwardIntent();
}

class SplitClipIntent extends Intent {
  const SplitClipIntent();
}

class DeleteClipIntent extends Intent {
  const DeleteClipIntent();
}

class UndoIntent extends Intent {
  const UndoIntent();
}

class RedoIntent extends Intent {
  const RedoIntent();
}

class DeselectIntent extends Intent {
  const DeselectIntent();
}

class SaveIntent extends Intent {
  const SaveIntent();
}

class ExportIntent extends Intent {
  const ExportIntent();
}
