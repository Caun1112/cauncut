// 预览面板 (中间) — 视频预览 + 比例/播放控制
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/project_provider.dart';

class PreviewPanel extends ConsumerWidget {
  const PreviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(previewProvider);
    final aspectLabel = preview.outputAspect;
    final fitMode = preview.fitMode;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // 比例选择按钮组
          _AspectRatioBar(
            selected: aspectLabel,
            onChanged: (v) =>
                ref.read(previewProvider.notifier).setAspect(v),
          ),
          // 视频预览区
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(previewProvider.notifier).togglePlay(),
              child: Center(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                  child: preview.currentClipPath != null
                      ? _VideoPlaceholder(
                          isPlaying: preview.isPlaying,
                          clipName: preview.currentClipPath!.split('/').last,
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_circle_outline,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant),
                              const SizedBox(height: 8),
                              Text('选择素材开始预览',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
          // 播放控制条
          _PlaybackControls(
            isPlaying: preview.isPlaying,
            position: preview.currentPosition,
            onToggle: () =>
                ref.read(previewProvider.notifier).togglePlay(),
            fitMode: fitMode,
            onFitModeChanged: (m) =>
                ref.read(previewProvider.notifier).setFitMode(m),
          ),
        ],
      ),
    );
  }
}

class _AspectRatioBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _AspectRatioBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const ratios = ['16:9', '4:3', '3:4', '1:1'];
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ratios.map((r) {
          final isSelected = r == selected;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(r, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (_) => onChanged(r),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final Duration position;
  final VoidCallback onToggle;
  final String fitMode;
  final ValueChanged<String> onFitModeChanged;

  const _PlaybackControls({
    required this.isPlaying,
    required this.position,
    required this.onToggle,
    required this.fitMode,
    required this.onFitModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 24,
            ),
            onPressed: onToggle,
            tooltip: 'Space',
          ),
          const SizedBox(width: 8),
          Text(
            _fmtDuration(position),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          // Fit/Fill 切换
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'fit', label: Text('适应')),
              ButtonSegment(value: 'fill', label: Text('填充')),
            ],
            selected: {fitMode},
            onSelectionChanged: (s) => onFitModeChanged(s.first),
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = d.inMilliseconds.remainder(1000) ~/ 10;
    return '${d.inMinutes}:$m:$s.${ms.toString().padLeft(2, "0")}';
  }
}

class _VideoPlaceholder extends StatelessWidget {
  final bool isPlaying;
  final String clipName;

  const _VideoPlaceholder({required this.isPlaying, required this.clipName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPlaying ? Icons.play_circle_filled : Icons.movie,
            size: 48,
            color: Colors.white54,
          ),
          const SizedBox(height: 8),
          Text(clipName,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          if (isPlaying)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('▶ 播放中',
                  style: TextStyle(color: Colors.white38, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}
