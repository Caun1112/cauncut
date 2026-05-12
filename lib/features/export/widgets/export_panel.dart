// 导出设置面板
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/export_settings.dart';
import '../../../core/providers/project_provider.dart';
import '../../../core/services/export_service.dart';

class ExportPanel extends ConsumerStatefulWidget {
  const ExportPanel({super.key});

  @override
  ConsumerState<ExportPanel> createState() => _ExportPanelState();
}

class _ExportPanelState extends ConsumerState<ExportPanel> {
  final _controller = TextEditingController();
  final _exportService = ExportService();
  ExportProgress? _progress;
  ExportStatus _status = ExportStatus.idle;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(exportSettingsProvider);
    final isExporting = _status == ExportStatus.exporting;

    return AlertDialog(
      title: const Text('导出视频'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === 基本信息 ===
              _sectionTitle('基本信息'),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: '文件名',
                  hintText: '输入导出文件名',
                  isDense: true,
                ),
                onChanged: (v) => _update((s) => s.copyWith(title: v)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: '输出目录',
                        hintText: '选择输出位置',
                        isDense: true,
                      ),
                      readOnly: true,
                      controller:
                          TextEditingController(text: settings.outputPath),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () => _pickOutputDir(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // === 视频设置 ===
              _sectionTitle('视频设置'),
              // 格式
              _buildSegmented<String>(
                label: '格式',
                values: const ['mp4', 'mov'],
                labels: const ['MP4', 'MOV'],
                selected: settings.format,
                onChanged: (v) => _update((s) => s.copyWith(format: v)),
              ),
              // 分辨率
              _buildDropdown(
                label: '分辨率',
                value: settings.resolutionPreset,
                items: ['4K', '1440p', '1080p', '720p', '480p', 'custom'],
                onChanged: (v) =>
                    _update((s) => s.copyWith(resolutionPreset: v ?? '1080p')),
              ),
              if (settings.resolutionPreset == 'custom') ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: '宽', isDense: true),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                            text: '${settings.customWidth}'),
                        onChanged: (v) {
                          final w = int.tryParse(v);
                          if (w != null) {
                            _update((s) {
                              var ns = s.copyWith(customWidth: w);
                              if (s.lockAspectRatio && s.customHeight > 0) {
                                final ratio = s.customWidth / s.customHeight;
                                ns = ns.copyWith(
                                    customHeight: (w / ratio).round());
                              }
                              return ns;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(settings.lockAspectRatio
                          ? Icons.lock
                          : Icons.lock_open),
                      onPressed: () => _update(
                          (s) => s.copyWith(lockAspectRatio: !s.lockAspectRatio)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: '高', isDense: true),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                            text: '${settings.customHeight}'),
                        onChanged: (v) {
                          final h = int.tryParse(v);
                          if (h != null) {
                            _update((s) {
                              var ns = s.copyWith(customHeight: h);
                              if (s.lockAspectRatio && s.customWidth > 0) {
                                final ratio = s.customWidth / s.customHeight;
                                ns = ns.copyWith(
                                    customWidth: (h * ratio).round());
                              }
                              return ns;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
              // 帧率
              _buildFrameRate(settings),
              // 编码器
              _buildSegmented<String>(
                label: '编码器',
                values: const ['h264_nvenc', 'hevc_nvenc'],
                labels: const ['H.264 NVENC', 'HEVC NVENC'],
                selected: settings.videoCodec,
                onChanged: (v) => _update((s) => s.copyWith(videoCodec: v)),
              ),
              // 码率模式
              _buildSegmented<String>(
                label: '码率模式',
                values: const ['cbr', 'vbr'],
                labels: const ['CBR (恒定)', 'VBR (可变)'],
                selected: settings.bitrateMode,
                onChanged: (v) =>
                    _update((s) => s.copyWith(bitrateMode: v)),
              ),
              // 目标码率
              TextField(
                decoration: const InputDecoration(
                  labelText: '目标码率 (kbps)',
                  suffixText: 'kbps',
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                    text: '${settings.targetBitrateKbps}'),
                onChanged: (v) {
                  final kbps = int.tryParse(v);
                  if (kbps != null) {
                    _update((s) => s.copyWith(targetBitrateKbps: kbps));
                  }
                },
              ),
              // VBR 参数
              if (settings.bitrateMode == 'vbr') ...[
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: '最大码率 (kbps)',
                    suffixText: 'kbps',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                      text: '${settings.maxBitrateKbps}'),
                  onChanged: (v) {
                    final kbps = int.tryParse(v);
                    if (kbps != null) {
                      _update((s) => s.copyWith(maxBitrateKbps: kbps));
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('质量等级: ${settings.qualityLevel}',
                        style: Theme.of(context).textTheme.bodySmall),
                    Expanded(
                      child: Slider(
                        value: settings.qualityLevel.toDouble(),
                        min: 0, max: 51, divisions: 51,
                        onChanged: (v) => _update(
                            (s) => s.copyWith(qualityLevel: v.round())),
                      ),
                    ),
                  ],
                ),
              ],
              // 输出比例
              _buildSegmented<String>(
                label: '输出比例',
                values: const ['16:9', '4:3', '3:4', '1:1'],
                labels: const ['16:9', '4:3', '3:4', '1:1'],
                selected: settings.outputAspect,
                onChanged: (v) =>
                    _update((s) => s.copyWith(outputAspect: v)),
              ),
              const SizedBox(height: 16),

              // === 音频设置 ===
              _sectionTitle('音频设置'),
              Row(
                children: [
                  const Text('包含音频'),
                  const Spacer(),
                  Switch(
                    value: settings.includeAudio,
                    onChanged: (v) =>
                        _update((s) => s.copyWith(includeAudio: v)),
                  ),
                ],
              ),
              if (settings.includeAudio) ...[
                _buildDropdown(
                  label: '音频码率',
                  value: '${settings.audioBitrateKbps}',
                  items: ExportSettings.audioBitratePresets
                      .map((e) => '$e')
                      .toList(),
                  onChanged: (v) {
                    final kbps = int.tryParse(v ?? '128');
                    if (kbps != null) {
                      _update((s) => s.copyWith(audioBitrateKbps: kbps));
                    }
                  },
                ),
                _buildDropdown(
                  label: '采样率',
                  value: '${settings.audioSampleRate}',
                  items: ExportSettings.audioSampleRatePresets
                      .map((e) => '$e')
                      .toList(),
                  onChanged: (v) {
                    final sr = int.tryParse(v ?? '48000');
                    if (sr != null) {
                      _update((s) => s.copyWith(audioSampleRate: sr));
                    }
                  },
                ),
              ],
              const SizedBox(height: 16),

              // === Fit/Fill ===
              _buildSegmented<String>(
                label: '画面适配',
                values: const ['fit', 'fill'],
                labels: const ['适应', '填充'],
                selected: settings.fitMode,
                onChanged: (v) => _update((s) => s.copyWith(fitMode: v)),
              ),

              // === 进度条 ===
              if (_progress != null) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(value: _progress!.progress),
                const SizedBox(height: 8),
                Text(
                  '${(_progress!.progress * 100).toStringAsFixed(0)}% | '
                  '剩余: ${_fmtDuration(_progress!.eta)} | '
                  '已用: ${_fmtDuration(_progress!.elapsed)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (_status == ExportStatus.failed)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('导出失败',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
        if (_status == ExportStatus.exporting)
          TextButton(
            onPressed: _cancelExport,
            child: const Text('取消'),
          ),
        FilledButton(
          onPressed: isExporting ? null : _startExport,
          child: Text(isExporting ? '导出中...' : '开始导出'),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSegmented<T>({
    required String label,
    required List<T> values,
    required List<String> labels,
    required T selected,
    required ValueChanged<T> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          SegmentedButton<T>(
            segments: List.generate(values.length, (i) {
              return ButtonSegment<T>(
                value: values[i],
                label: Text(labels[i], style: const TextStyle(fontSize: 12)),
              );
            }),
            selected: {selected},
            onSelectionChanged: (s) => onChanged(s.first),
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              isExpanded: true,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameRate(ExportSettings settings) {
    final frList = ExportSettings.frameRatePresets.map((e) => e.toString()).toList();
    frList.add('custom');
    final currentFr = settings.useCustomFrameRate
        ? 'custom'
        : settings.frameRate.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: '帧率',
          value: currentFr,
          items: frList,
          onChanged: (v) {
            if (v == 'custom') {
              _update((s) => s.copyWith(useCustomFrameRate: true));
            } else {
              final fr = double.tryParse(v ?? '30');
              if (fr != null) {
                _update((s) => s.copyWith(
                    frameRate: fr, useCustomFrameRate: false));
              }
            }
          },
        ),
        if (settings.useCustomFrameRate)
          TextField(
            decoration: const InputDecoration(
              labelText: '自定义帧率',
              isDense: true,
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            controller:
                TextEditingController(text: '${settings.frameRate}'),
            onChanged: (v) {
              final fr = double.tryParse(v);
              if (fr != null) {
                _update((s) => s.copyWith(frameRate: fr));
              }
            },
          ),
      ],
    );
  }

  void _update(ExportSettings Function(ExportSettings) f) {
    ref.read(exportSettingsProvider.notifier).update(f);
  }

  void _pickOutputDir() {
    // TODO: 使用 file_picker 或 file_selector 选择目录
  }

  Future<void> _startExport() async {
    setState(() {
      _status = ExportStatus.exporting;
      _progress = null;
    });

    final timeline = ref.read(timelineProvider);
    final settings = ref.read(exportSettingsProvider);
    final result = await _exportService.export(
      clips: timeline.clips,
      settings: settings,
      onProgress: (p) {
        setState(() => _progress = p);
      },
    );

    setState(() {
      _status = result.status;
    });
  }

  void _cancelExport() {
    _exportService.cancel();
    setState(() => _status = ExportStatus.cancelled);
  }

  String _fmtDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
