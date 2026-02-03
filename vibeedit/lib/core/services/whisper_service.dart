/// WhisperService - OpenAI Whisper API for auto-captions
/// Handles audio extraction and caption generation
library;

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Caption segment model
class CaptionSegment {
  CaptionSegment({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.text,
  });

  final String id;
  final Duration startTime;
  final Duration endTime;
  final String text;

  /// Convert to SRT format
  String toSrt(int index) {
    return '''$index
${_formatDuration(startTime)} --> ${_formatDuration(endTime)}
$text
''';
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    final millis = (d.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds,$millis';
  }
}

/// Whisper transcription result
class TranscriptionResult {
  TranscriptionResult({
    required this.segments,
    required this.language,
    required this.duration,
  });

  final List<CaptionSegment> segments;
  final String language;
  final Duration duration;

  /// Convert all segments to SRT format
  String toSrt() {
    final buffer = StringBuffer();
    for (int i = 0; i < segments.length; i++) {
      buffer.write(segments[i].toSrt(i + 1));
      buffer.write('\n');
    }
    return buffer.toString();
  }
}

/// Service status
enum WhisperStatus { idle, downloadingModel, extractingAudio, transcribing, complete, error }

/// OpenAI Whisper service for auto-captioning
class WhisperService {
  WhisperService({this.apiKey, this.modelDownloadUri});

  final String? apiKey;
  final Uri? modelDownloadUri;

  WhisperStatus _status = WhisperStatus.idle;
  WhisperStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  double _progress = 0.0;
  double get progress => _progress;

  final _statusController = StreamController<WhisperStatus>.broadcast();
  Stream<WhisperStatus> get statusStream => _statusController.stream;

  /// Cached local path to the whisper model file (downloaded on demand)
  String? _localModelPath;

  /// Ensure model is available locally by downloading on demand
  Future<String?> ensureModelDownloaded({String fileName = 'whisper-base.bin'}) async {
    if (_localModelPath != null && await File(_localModelPath!).exists()) {
      return _localModelPath;
    }
    if (modelDownloadUri == null) return null; // optional until configured

    final dir = await getApplicationSupportDirectory();
    final modelsDir = Directory('${dir.path}${Platform.pathSeparator}models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    final filePath = '${modelsDir.path}${Platform.pathSeparator}$fileName';
    final file = File(filePath);
    if (await file.exists()) {
      _localModelPath = filePath;
      return _localModelPath;
    }

    _status = WhisperStatus.downloadingModel;
    _progress = 0.0;
    _statusController.add(_status);

    final request = http.Request('GET', modelDownloadUri!);
    final response = await request.send();
    if (response.statusCode != 200) {
      _status = WhisperStatus.error;
      _errorMessage = 'Failed to download model: HTTP ${response.statusCode}';
      _statusController.add(_status);
      return null;
    }
    final contentLength = response.contentLength ?? 0;
    int received = 0;
    final sink = file.openWrite();
    await for (final chunk in response.stream) {
      received += chunk.length;
      sink.add(chunk);
      if (contentLength > 0) {
        _progress = received / contentLength;
        _statusController.add(_status);
      }
    }
    await sink.close();

    _localModelPath = filePath;
    return _localModelPath;
  }

  /// Generate captions from video file
  /// For now, returns mock captions. Real implementation would:
  /// 1. Extract audio from video using FFmpeg
  /// 2. Send audio to OpenAI Whisper API
  /// 3. Parse response into CaptionSegments
  Future<TranscriptionResult?> generateCaptions(String videoPath) async {
    try {
      // Download model on demand (no bundling)
      await ensureModelDownloaded();

      _status = WhisperStatus.extractingAudio;
      _progress = 0.0;
      _statusController.add(_status);

      // Simulate audio extraction
      await Future.delayed(const Duration(seconds: 1));
      _progress = 0.3;

      _status = WhisperStatus.transcribing;
      _statusController.add(_status);

      // Simulate transcription
      await Future.delayed(const Duration(seconds: 2));
      _progress = 0.8;

      // Mock captions for demo
      final mockSegments = [
        CaptionSegment(
          id: '1',
          startTime: const Duration(seconds: 0),
          endTime: const Duration(seconds: 3),
          text: 'Welcome to VibeEdit AI',
        ),
        CaptionSegment(
          id: '2',
          startTime: const Duration(seconds: 3),
          endTime: const Duration(seconds: 6),
          text: 'Create amazing videos with AI',
        ),
        CaptionSegment(
          id: '3',
          startTime: const Duration(seconds: 6),
          endTime: const Duration(seconds: 10),
          text: 'Auto-generate captions instantly',
        ),
        CaptionSegment(
          id: '4',
          startTime: const Duration(seconds: 10),
          endTime: const Duration(seconds: 14),
          text: 'Professional editing made easy',
        ),
        CaptionSegment(
          id: '5',
          startTime: const Duration(seconds: 14),
          endTime: const Duration(seconds: 18),
          text: 'Export in any format you need',
        ),
      ];

      _progress = 1.0;
      _status = WhisperStatus.complete;
      _statusController.add(_status);

      return TranscriptionResult(
        segments: mockSegments,
        language: 'en',
        duration: const Duration(seconds: 18),
      );
    } catch (e) {
      _status = WhisperStatus.error;
      _errorMessage = e.toString();
      _statusController.add(_status);
      return null;
    }
  }

  /// Reset service state
  void reset() {
    _status = WhisperStatus.idle;
    _progress = 0.0;
    _errorMessage = null;
    _statusController.add(_status);
  }

  void dispose() {
    _statusController.close();
  }
}
