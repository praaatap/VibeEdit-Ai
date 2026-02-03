/// API Service for VibeEdit AI Backend
/// Handles all HTTP requests to the backend
library;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// API Configuration
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000/api';
  static const Duration timeout = Duration(seconds: 30);
}

/// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

/// Main API Service
class ApiService {
  final http.Client _client = http.Client();

  // ═══════════════════════════════════════════════════════════════════════════
  // VIDEO ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Upload video file
  Future<Map<String, dynamic>> uploadVideo(File file) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/video/upload');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send().timeout(const Duration(minutes: 5));
    final body = await response.stream.bytesToString();
    return json.decode(body);
  }

  /// Get processing status
  Future<Map<String, dynamic>> getProcessingStatus(String videoId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/video/status/$videoId');
    final response = await _client.get(uri).timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EFFECTS ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Adjust video speed
  Future<Map<String, dynamic>> adjustSpeed({
    required String videoId,
    required double speed,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/effects/speed');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'video_id': videoId, 'speed': speed}),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Apply filters
  Future<Map<String, dynamic>> applyFilter({
    required String videoId,
    double brightness = 0,
    double contrast = 1.0,
    double saturation = 1.0,
    double blur = 0,
    double sharpen = 0,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/effects/filter');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'video_id': videoId,
            'brightness': brightness,
            'contrast': contrast,
            'saturation': saturation,
            'blur': blur,
            'sharpen': sharpen,
          }),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Apply preset filter
  Future<Map<String, dynamic>> applyPresetFilter({
    required String videoId,
    required String preset,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/effects/filter/preset');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'video_id': videoId, 'preset': preset}),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Crop video
  Future<Map<String, dynamic>> cropVideo({
    required String videoId,
    required int width,
    required int height,
    int x = 0,
    int y = 0,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/effects/crop');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'video_id': videoId,
            'width': width,
            'height': height,
            'x': x,
            'y': y,
          }),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Rotate video
  Future<Map<String, dynamic>> rotateVideo({
    required String videoId,
    required int degrees,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/effects/rotate');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'video_id': videoId, 'degrees': degrees}),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Apply chroma key (green screen)
  Future<Map<String, dynamic>> chromaKey({
    required String videoId,
    required String backgroundId,
    String color = 'green',
    double similarity = 0.3,
    double blend = 0.1,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/effects/chroma-key');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'video_id': videoId,
            'background_id': backgroundId,
            'color': color,
            'similarity': similarity,
            'blend': blend,
          }),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Stabilize video
  Future<Map<String, dynamic>> stabilizeVideo({
    required String videoId,
    int shakiness = 5,
    int accuracy = 15,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/effects/stabilize');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'video_id': videoId,
            'shakiness': shakiness,
            'accuracy': accuracy,
          }),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Get filter presets
  Future<List<Map<String, dynamic>>> getFilterPresets() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/effects/presets');
    final response = await _client.get(uri).timeout(ApiConfig.timeout);
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['presets']);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUDIO ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Extract audio from video
  Future<Map<String, dynamic>> extractAudio({
    required String videoId,
    String format = 'mp3',
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/audio/extract?video_id=$videoId&format=$format',
    );
    final response = await _client.post(uri).timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Add background music
  Future<Map<String, dynamic>> addBackgroundMusic({
    required String videoId,
    required String musicId,
    double musicVolume = 0.3,
    double originalVolume = 1.0,
    double fadeIn = 0,
    double fadeOut = 0,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/audio/background-music');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'video_id': videoId,
            'music_id': musicId,
            'music_volume': musicVolume,
            'original_volume': originalVolume,
            'fade_in': fadeIn,
            'fade_out': fadeOut,
          }),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Adjust volume
  Future<Map<String, dynamic>> adjustVolume({
    required String videoId,
    required double volume,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/audio/volume');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'video_id': videoId, 'volume': volume}),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Reduce noise
  Future<Map<String, dynamic>> reduceNoise({
    required String videoId,
    double reductionAmount = 0.21,
    double noiseFloor = -30,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/audio/noise-reduction');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'video_id': videoId,
            'reduction_amount': reductionAmount,
            'noise_floor': noiseFloor,
          }),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Normalize audio
  Future<Map<String, dynamic>> normalizeAudio({
    required String videoId,
    double targetLevel = -14.0,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/audio/normalize?video_id=$videoId&target_level=$targetLevel',
    );
    final response = await _client.post(uri).timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Remove audio (mute)
  Future<Map<String, dynamic>> removeAudio(String videoId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/audio/remove?video_id=$videoId',
    );
    final response = await _client.post(uri).timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXPORT ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Export video
  Future<Map<String, dynamic>> exportVideo({
    required String videoId,
    String format = 'mp4',
    String quality = 'high',
    int? customWidth,
    int? customHeight,
    int? fps,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/export/video');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'video_id': videoId,
            'format': format,
            'quality': quality,
            if (customWidth != null) 'custom_width': customWidth,
            if (customHeight != null) 'custom_height': customHeight,
            if (fps != null) 'fps': fps,
          }),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Export for platform
  Future<Map<String, dynamic>> exportForPlatform({
    required String videoId,
    required String platform,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/export/platform');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'video_id': videoId, 'platform': platform}),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Batch export
  Future<Map<String, dynamic>> batchExport({
    required String videoId,
    required List<String> platforms,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/export/batch');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'video_id': videoId, 'platforms': platforms}),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Get platform presets
  Future<List<Map<String, dynamic>>> getPlatformPresets() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/export/platforms');
    final response = await _client.get(uri).timeout(ApiConfig.timeout);
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['platforms']);
  }

  /// Get quality presets
  Future<List<Map<String, dynamic>>> getQualityPresets() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/export/quality');
    final response = await _client.get(uri).timeout(ApiConfig.timeout);
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['quality_presets']);
  }

  /// Extract thumbnail
  Future<Map<String, dynamic>> extractThumbnail({
    required String videoId,
    double timestamp = 0,
    int width = 1280,
    int height = 720,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/export/thumbnail');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'video_id': videoId,
            'timestamp': timestamp,
            'width': width,
            'height': height,
          }),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Export as GIF
  Future<Map<String, dynamic>> exportAsGif({
    required String videoId,
    int width = 480,
    int fps = 15,
    double? startTime,
    double? duration,
  }) async {
    var queryParams = 'video_id=$videoId&width=$width&fps=$fps';
    if (startTime != null) queryParams += '&start_time=$startTime';
    if (duration != null) queryParams += '&duration=$duration';

    final uri = Uri.parse('${ApiConfig.baseUrl}/export/gif?$queryParams');
    final response = await _client.post(uri).timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AI ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Analyze transcript with AI
  Future<Map<String, dynamic>> analyzeTranscript(String transcript) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/ai/analyze');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'transcript': transcript}),
        )
        .timeout(const Duration(minutes: 2));
    return json.decode(response.body);
  }

  /// Generate captions
  Future<Map<String, dynamic>> generateCaptions(String videoId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/ai/captions');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'video_id': videoId}),
        )
        .timeout(const Duration(minutes: 5));
    return json.decode(response.body);
  }

  /// Detect emotions
  Future<Map<String, dynamic>> detectEmotions(String transcript) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/ai/emotions');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'transcript': transcript}),
        )
        .timeout(ApiConfig.timeout);
    return json.decode(response.body);
  }

  /// Get clip suggestions
  Future<Map<String, dynamic>> getClipSuggestions({
    required String transcript,
    required int targetSeconds,
    required String platform,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/ai/suggest-clips');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'transcript': transcript,
            'target_seconds': targetSeconds,
            'platform': platform,
          }),
        )
        .timeout(const Duration(minutes: 2));
    return json.decode(response.body);
  }

  void dispose() {
    _client.close();
  }
}
