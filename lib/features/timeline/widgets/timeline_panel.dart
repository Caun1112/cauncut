// 时间轴面板 (底部)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/timeline_model.dart';
import '../../../core/providers/project_provider.dart';

class TimelinePanel extends ConsumerWidget {
  const TimelinePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(timelineProvider);
    final zoom = timeline.zoomLevel;
    final cursor = timeline.cursorPosition;
    final totalDur = timeline.totalDuration;

    final totalWidth = totalDur.inMicroseconds * zoom / 1000000;
    final cursorX = cursor.inMicroseconds * zoom / 1000000;

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        children: [
          // 时间刻度尺
          SizedBox(
            height: 24,
            child: _TimelineRuler(
              zoom: zoom,
              totalWidth: totalWidth > 0 ? totalWidth : 1200,
              cursorX: cursorX,
            ),
          ),
          // 素材轨道 + 游标
          Expanded(
            child: Stack(
              children: [
                // 素材轨道
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalWidth > 0 ? totalWidth : 1200,
                    child: _ClipTrack(
                      clips: timeline.clips,
                      zoom: zoom,
                      cursorPosition: cursor,
                      onTapAt: (pos) =>
                          ref.read(timelineProvider.notifier).setCursor(pos),
                    ),
                  ),
                ),
                // 游标线
                if (cursorX > 0)
                  Positioned(
                    left: cursorX,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          // 底部控制栏
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                Text(
                  '缩放: ${zoom.toStringAsFixed(0)} px/s',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Expanded(
                  child: Slider(
                    value: zoom,
                    min: 5,
                    max: 500,
                    onChanged: (v) =>
                        ref.read(timelineProvider.notifier).setZoom(v),
                  ),
                ),
                Text(
                  '游标: ${_fmtDuration(cursor)} / ${_fmtDuration(totalDur)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inMinutes}:$m:$s';
  }
}

/// 时间刻度尺
class _TimelineRuler extends StatelessWidget {
  final double zoom;
  final double totalWidth;
  final double cursorX;

  const _TimelineRuler({
    required this.zoom,
    required this.totalWidth,
    required this.cursorX,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(totalWidth, 24),
      painter: _RulerPainter(zoom: zoom, cursorX: cursorX),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double zoom;
  final double cursorX;

  _RulerPainter({required this.zoom, required this.cursorX});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF888888)
      ..strokeWidth = 0.5;

    final textStyle = TextStyle(color: const Color(0xFFAAAAAA), fontSize: 10);

    // 每秒一条刻度
    for (double t = 0; t * zoom < size.width + zoom; t += 1.0) {
      final x = t * zoom;
      canvas.drawLine(Offset(x, 14), Offset(x, 24), paint);

      // 每 5 秒一个标签
      if (t.round() % 5 == 0) {
        canvas.drawLine(Offset(x, 8), Offset(x, 24), paint);
        final tp = TextPainter(
          text: TextSpan(text: '${t.round()}s', style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + 3, 2));
      }

      // 半秒刻度
      if (zoom > 60) {
        final hx = (t + 0.5) * zoom;
        canvas.drawLine(Offset(hx, 18), Offset(hx, 24), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) =>
      zoom != oldDelegate.zoom || cursorX != oldDelegate.cursorX;
}

/// 素材轨道
class _ClipTrack extends StatelessWidget {
  final List<TimelineClip> clips;
  final double zoom;
  final Duration cursorPosition;
  final ValueChanged<Duration> onTapAt;

  const _ClipTrack({
    required this.clips,
    required this.zoom,
    required this.cursorPosition,
    required this.onTapAt,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        children: clips.map((clip) {
          final left = clip.timelineIn.inMicroseconds * zoom / 1000000;
          final width = clip.duration.inMicroseconds * zoom / 1000000;
          return Positioned(
            left: left,
            top: 4,
            width: width.clamp(20, double.infinity),
            height: 72,
            child: GestureDetector(
              onTap: () => onTapAt(clip.timelineIn),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clip.fileName,
                        style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer),
                        overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    // 裁切手柄
                    Row(
                      children: [
                        // 左裁切手柄
                        Container(
                          width: 6,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const Spacer(),
                        // 右裁切手柄
                        Container(
                          width: 6,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
