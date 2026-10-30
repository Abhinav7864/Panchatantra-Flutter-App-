import 'dart:js_interop';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

String getPlatformRecordingPath() {
  // Web does not use file system paths for recording
  return '';
}

Future<Uint8List?> readPlatformAudioBytes(String path) async {
  try {
    if (path.isEmpty) return null;
    final response = await web.window.fetch(path.toJS).toDart;
    final arrayBuffer = await response.arrayBuffer().toDart;
    final bytes = arrayBuffer.toDart.asUint8List();
    if (bytes.length > 100) {
      return bytes;
    }
  } catch (e) {
    debugPrint('readPlatformAudioBytes (web) error: $e');
  }
  return null;
}

Future<Source?> createPlatformAudioSource({
  Uint8List? bytes,
  String? path,
  String? assetFallback,
}) async {
  try {
    // 1. In browser, BytesSource works natively by creating blob URLs
    if (bytes != null && bytes.isNotEmpty) {
      return BytesSource(bytes);
    }

    // 2. If blob or http URL
    if (path != null && path.isNotEmpty) {
      return UrlSource(path);
    }

    // 3. Asset fallback
    if (assetFallback != null && assetFallback.isNotEmpty) {
      return AssetSource(assetFallback);
    }
  } catch (e) {
    debugPrint('createPlatformAudioSource (web) error: $e');
  }
  return null;
}
