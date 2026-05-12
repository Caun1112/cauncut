// 导出服务 — GPU 加速导出流水线 (NVENC + AAC)
// 流程: 遍历时间轴素材 → decode → filter graph → encode → mux

import 'dart:async';
import '../models/timeline_model.dart';
import '../models/export_settings.dart';

/// 导出进度回调
typedef ExportProgressCallback = void Function(ExportProgress progress);

class ExportProgress {
  final double progress; // 0.0 ~ 1.0
  final Duration elapsed;
  final Duration eta;
  final int currentFrame;
  final int totalFrames;

  const ExportProgress({
    required this.progress,
    required this.elapsed,
    required this.eta,
    required this.currentFrame,
    required this.totalFrames,
  });
}

enum ExportStatus { idle, exporting, completed, failed, cancelled }

class ExportResult {
  final ExportStatus status;
  final String? filePath;
  final String? errorMessage;

  const ExportResult({
    required this.status,
    this.filePath,
    this.errorMessage,
  });
}

class ExportService {
  bool _cancelled = false;
  bool _gpuAvailable = false;
  Timer? _progressTimer;

  /// 检测 GPU 可用性 (NVENC)
  Future<bool> checkGpuAvailable() async {
    // TODO: 通过 FFmpeg av_hwdevice_ctx_create(AV_HWDEVICE_TYPE_CUDA) 检测
    _gpuAvailable = false;
    return _gpuAvailable;
  }

  /// 执行导出
  Future<ExportResult> export({
    required List<TimelineClip> clips,
    required ExportSettings settings,
    ExportProgressCallback? onProgress,
  }) async {
    _cancelled = false;
    final startTime = DateTime.now();

    try {
      // 1. 计算总帧数
      final totalDuration = _totalDuration(clips);
      final fps = settings.frameRate;
      final totalFrames = (totalDuration.inMicroseconds * fps / 1000000).round();

      // 2. 确定编码器
      final videoCodec = _selectCodec(settings);
      final filterGraph = _buildFilterGraph(settings);

      // 3. 逐帧编 (模拟 - 实际替换为 FFmpeg API 调用)
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < totalFrames; i++) {
        if (_cancelled) {
          return ExportResult(status: ExportStatus.cancelled);
        }

        // TODO: 真实编码流程
        // - 根据当前帧时间戳找到对应素材
        // - decode 该帧
        // - push through filter graph (scale/cuda)
        // - encode (NVENC/AAC)
        // - write packet to muxer

        // 模拟编码延迟 (每帧约 2-8ms GPU)
        await Future.delayed(const Duration(milliseconds: 1));

        // 进度回调
        if (onProgress != null && i % 30 == 0) {
          final elapsed = stopwatch.elapsed;
          final progress = (i + 1) / totalFrames;
          final eta = progress > 0
              ? Duration(milliseconds: ((elapsed.inMilliseconds / progress) - elapsed.inMilliseconds).round())
              : Duration.zero;
          onProgress(ExportProgress(
            progress: progress,
            elapsed: elapsed,
            eta: eta,
            currentFrame: i + 1,
            totalFrames: totalFrames,
          ));
        }
      }

      // 4. 刷新编码器缓冲区
      // TODO: flush encoders, write trailer

      final outputPath = '${settings.outputPath}/${settings.title}.${settings.format}';
      return ExportResult(
        status: ExportStatus.completed,
        filePath: outputPath,
      );
    } catch (e) {
      return ExportResult(
        status: ExportStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  void cancel() {
    _cancelled = true;
  }

  /// CBR 模式 NVENC 参数
  Map<String, String> _nvencCbrParams(ExportSettings s) => {
        'b': '${s.targetBitrateKbps}k',
        'minrate': '${s.targetBitrateKbps}k',
        'maxrate': '${s.targetBitrateKbps}k',
        'bufsize': '${s.maxBitrateKbps * 2}k',
        'rc': 'cbr',
        'preset': 'p5',
      };

  /// VBR 模式 NVENC 参数
  Map<String, String> _nvencVbrParams(ExportSettings s) => {
        'b': '${s.targetBitrateKbps}k',
        'maxrate': '${s.maxBitrateKbps}k',
        'bufsize': '${s.maxBitrateKbps * 2}k',
        'rc': 'vbr_hq',
        'cq': '${s.qualityLevel}',
        'preset': 'p5',
      };

  /// AAC 音频编码器参数
  Map<String, String> _aacParams(ExportSettings s) => {
        'b:a': '${s.audioBitrateKbps}k',
        'ar': '${s.audioSampleRate}',
        'ac': '2',
      };

  String _selectCodec(ExportSettings s) {
    if (_gpuAvailable) return s.videoCodec; // h264_nvenc or hevc_nvenc
    return s.videoCodec == 'hevc_nvenc' ? 'libx265' : 'libx264';
  }

  String _buildFilterGraph(ExportSettings s) {
    final w = s.outputWidth;
    final h = s.outputHeight;
    final fps = s.frameRate;
    final parts = <String>[
      if (_gpuAvailable) 'hwupload_cuda',
      if (_gpuAvailable)
        'scale_cuda=w=$w:h=$h'
      else
        'scale=w=$w:h=$h',
      'format=yuv420p',
      'fps=$fps',
    ];
    return parts.join(',');
  }

  Duration _totalDuration(List<TimelineClip> clips) {
    if (clips.isEmpty) return Duration.zero;
    return clips
        .map((c) => c.timelineIn + c.duration)
        .reduce((a, b) => a > b ? a : b);
  }
}
