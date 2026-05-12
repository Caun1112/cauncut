// 素材库面板 (左侧)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/media_clip.dart';
import '../../../core/providers/project_provider.dart';

class MaterialLibraryPanel extends ConsumerWidget {
  final void Function(MediaClip clip) onClipSelected;

  const MaterialLibraryPanel({super.key, required this.onClipSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clips = ref.watch(materialLibraryProvider);
    final readyCount = clips.where((c) => c.status == ImportStatus.ready).length;
    final failedCount = clips.where((c) => c.status == ImportStatus.failed).length;

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          // 标题栏
          _PanelHeader(
            title: '素材库',
            count: '($readyCount / ${clips.length})',
            trailing: IconButton(
              icon: const Icon(Icons.add, size: 20),
              tooltip: '导入视频',
              onPressed: () => _importFiles(context, ref),
            ),
          ),
          // 失败提示
          if (failedCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(Icons.warning, size: 14,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 6),
                  Text('$failedCount 个文件导入失败',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.error)),
                ],
              ),
            ),
          // 缩略图模式切换
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Text('排序: 时长↓', style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.image, size: 18),
                  tooltip: '首帧缩略图',
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.view_column, size: 18),
                  tooltip: '缩略图条',
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // 素材列表
          Expanded(
            child: clips.isEmpty
                ? Center(
                    child: Text('拖入视频文件或点击 + 导入',
                        style: Theme.of(context).textTheme.bodySmall))
                : ListView.builder(
                    itemCount: clips.length,
                    itemBuilder: (_, i) => _ClipTile(
                      clip: clips[i],
                      onTap: () {
                        if (clips[i].status == ImportStatus.ready) {
                          onClipSelected(clips[i]);
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _importFiles(BuildContext context, WidgetRef ref) {
    // TODO: 调用文件选择器 -> 导入服务
    // 目前添加 mock 数据
    final mock = MediaClip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: '/mock/video_${DateTime.now().millisecond}.mp4',
      fileName: '示例视频.mp4',
      duration: const Duration(seconds: 45),
      width: 1920,
      height: 1080,
      frameRate: 30,
    );
    ref.read(materialLibraryProvider.notifier).addClip(mock);
  }
}

class _PanelHeader extends StatelessWidget {
  final String title;
  final String count;
  final Widget? trailing;

  const _PanelHeader({
    required this.title,
    required this.count,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: 4),
          Text(count, style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _ClipTile extends StatelessWidget {
  final MediaClip clip;
  final VoidCallback onTap;

  const _ClipTile({required this.clip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isFailed = clip.status == ImportStatus.failed;
    return InkWell(
      onTap: isFailed ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            // 缩略图占位
            Container(
              width: 80,
              height: 45,
              decoration: BoxDecoration(
                color: isFailed
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: isFailed
                  ? Icon(Icons.broken_image,
                      size: 24,
                      color: Theme.of(context).colorScheme.error)
                  : Icon(Icons.movie, size: 24,
                      color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(clip.fileName,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    isFailed
                        ? clip.errorMessage ?? '导入失败'
                        : '${_fmtDuration(clip.duration)} | ${clip.width}×${clip.height}',
                    style: TextStyle(
                        fontSize: 11,
                        color: isFailed
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  if (clip.status == ImportStatus.importing)
                    const SizedBox(
                      height: 2,
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inMinutes}:$m:$s';
  }
}
