import 'dart:io';
import 'package:flutter/foundation.dart';
import 'audio_recorder_helper.dart';

class AudioFilePickerService {
  /// Launches native OS file picker to select an audio or video recording file (MP3, WAV, M4A, MP4, MOV, WEBM)
  static Future<String?> pickAudioFile() async {
    if (kIsWeb) return null;

    if (Platform.isWindows) {
      try {
        final res = await Process.run('powershell', [
          '-NoProfile',
          '-Command',
          r'''
Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Title = 'Select Voice or Video Recording (MP3, WAV, M4A, MP4, MOV)'
$dialog.Filter = 'Audio & Video Recordings (*.mp3;*.wav;*.m4a;*.mp4;*.mov;*.webm;*.ogg)|*.mp3;*.wav;*.m4a;*.mp4;*.mov;*.webm;*.ogg|All Files (*.*)|*.*'
$downloads = [Environment]::GetFolderPath('UserProfile') + '\Downloads'
if (Test-Path $downloads) { $dialog.InitialDirectory = $downloads }
$dialog.Multiselect = $false
if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    Write-Output $dialog.FileName
}
'''
        ]);
        final output = res.stdout.toString().trim();
        if (output.isNotEmpty && File(output).existsSync()) {
          return output;
        }
      } catch (e) {
        debugPrint('Windows file picker error: $e');
      }
    } else if (Platform.isMacOS) {
      try {
        final res = await Process.run('osascript', [
          '-e',
          'POSIX path of (choose file with prompt "Select Voice or Video Recording" of type {"mp3", "wav", "m4a", "mp4", "mov", "webm", "ogg"})'
        ]);
        final output = res.stdout.toString().trim();
        if (output.isNotEmpty && File(output).existsSync()) {
          return output;
        }
      } catch (e) {
        debugPrint('macOS file picker error: $e');
      }
    }

    return null;
  }

  /// Scans common user directories for recent audio files (e.g. from Downloads or Temp)
  static Future<List<File>> getRecentAudioRecordings() async {
    if (kIsWeb) return [];

    final List<File> candidates = [];
    final Set<String> seenPaths = {};

    final userProfile = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '';

    final searchDirs = [
      if (userProfile.isNotEmpty) Directory('$userProfile\\Downloads'),
      if (userProfile.isNotEmpty) Directory('$userProfile/Downloads'),
      if (userProfile.isNotEmpty) Directory('$userProfile\\Music'),
      if (userProfile.isNotEmpty) Directory('$userProfile\\Documents'),
      Directory.systemTemp,
    ];

    final allowedExts = {'mp3', 'wav', 'm4a', 'mp4', 'mov', 'mkv', 'webm', 'ogg'};

    for (final dir in searchDirs) {
      if (!dir.existsSync()) continue;
      try {
        final entries = dir.listSync(recursive: false).whereType<File>();
        for (final file in entries) {
          final ext = file.path.split('.').last.toLowerCase();
          if (allowedExts.contains(ext) && !seenPaths.contains(file.path)) {
            // Check file size > 10KB (avoid empty or tiny chunks)
            try {
              final len = file.lengthSync();
              if (len > 10 * 1024) {
                seenPaths.add(file.path);
                candidates.add(file);
              }
            } catch (_) {}
          }
        }
      } catch (_) {}
    }

    // Sort newest modified first
    candidates.sort((a, b) {
      try {
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      } catch (_) {
        return 0;
      }
    });

    return candidates.take(8).toList();
  }

  /// Loads a selected audio file into a [RecordedAudio] object ready for preview and cloning
  static Future<RecordedAudio?> loadAudioFile(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) return null;

    try {
      final bytes = await file.readAsBytes();
      final ext = filePath.split('.').last.toLowerCase();

      // Estimate duration based on file format & size
      Duration duration = const Duration(seconds: 30);
      if (ext == 'wav' && bytes.length >= 44) {
        try {
          final byteRate = bytes[28] |
              (bytes[29] << 8) |
              (bytes[30] << 16) |
              (bytes[31] << 24);
          if (byteRate > 0) {
            final seconds = (bytes.length - 44) / byteRate;
            duration = Duration(milliseconds: (seconds * 1000).toInt());
          }
        } catch (_) {}
      } else if (ext == 'mp3' || ext == 'm4a') {
        // Approximate standard ~128kbps = 16KB/s
        final estSec = bytes.length / (24 * 1024);
        duration = Duration(milliseconds: (estSec * 1000).toInt());
      }

      return RecordedAudio(
        path: filePath,
        bytes: bytes,
        duration: duration,
        peakAmplitude: 0.85,
        isSilent: false,
        inputDeviceName: 'Audio File (${file.uri.pathSegments.last})',
      );
    } catch (e) {
      debugPrint('Load audio file error: $e');
      return null;
    }
  }
}
