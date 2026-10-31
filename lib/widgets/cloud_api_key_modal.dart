import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/cloud_voice_service.dart';

class CloudApiKeyModal extends StatefulWidget {
  final VoidCallback? onConfigSaved;

  const CloudApiKeyModal({super.key, this.onConfigSaved});

  static Future<void> show(BuildContext context, {VoidCallback? onConfigSaved}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CloudApiKeyModal(onConfigSaved: onConfigSaved),
    );
  }

  @override
  State<CloudApiKeyModal> createState() => _CloudApiKeyModalState();
}

class _CloudApiKeyModalState extends State<CloudApiKeyModal> {
  final _keyController = TextEditingController();
  final _voiceIdController = TextEditingController();
  bool _obscureKey = true;
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;
  List<InworldVoice> _workspaceVoices = [];
  String? _selectedVoiceId;

  @override
  void initState() {
    super.initState();
    _loadExistingConfig();
  }

  Future<void> _loadExistingConfig() async {
    final cfg = await CloudVoiceService.loadConfig();
    setState(() {
      _keyController.text = cfg.apiKey;
      _voiceIdController.text = cfg.voiceId;
      _selectedVoiceId = cfg.voiceId.isNotEmpty ? cfg.voiceId : null;
    });

    if (cfg.apiKey.isNotEmpty) {
      _fetchVoices(silent: true);
    }
  }

  Future<void> _fetchVoices({bool silent = false}) async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      if (!silent) {
        setState(() {
          _statusMessage = '⚠️ Please enter your Inworld API Key first.';
          _isSuccess = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final voices = await CloudVoiceService.fetchInworldVoices(key);
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _workspaceVoices = voices;
        if (voices.isNotEmpty) {
          _isSuccess = true;
          _statusMessage = ' Connected to Inworld! Found ${voices.length} workspace voice(s).';
          if (_selectedVoiceId == null || !_workspaceVoices.any((v) => v.voiceId == _selectedVoiceId)) {
            _selectedVoiceId = voices.first.voiceId;
            _voiceIdController.text = voices.first.voiceId;
          }
        } else {
          _isSuccess = true;
          _statusMessage = ' Connected to Inworld! No custom cloned voices yet (record or upload audio to clone).';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _statusMessage = '❌ Could not connect to Inworld: $e';
      });
    }
  }

  Future<void> _saveConfig() async {
    final key = _keyController.text.trim();
    final voiceId = (_selectedVoiceId ?? _voiceIdController.text).trim();

    if (key.isEmpty) {
      setState(() {
        _statusMessage = '⚠️ API Key cannot be empty.';
        _isSuccess = false;
      });
      return;
    }

    String displayName = 'Inworld Cloned Voice';
    if (_workspaceVoices.isNotEmpty) {
      final match = _workspaceVoices.firstWhere(
        (v) => v.voiceId == voiceId,
        orElse: () => _workspaceVoices.first,
      );
      displayName = match.displayName;
    }

    final cfg = CloudVoiceConfig(
      provider: 'inworld',
      apiKey: key,
      voiceId: voiceId,
      voiceDisplayName: displayName,
      isEnabled: true,
    );

    await CloudVoiceService.saveConfig(cfg);
    if (!mounted) return;

    widget.onConfigSaved?.call();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ Inworld AI API Key saved! Cloned voice connected: $displayName'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _keyController.disposeDatabaseSafe();
    _voiceIdController.disposeDatabaseSafe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        18,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.cloud_sync_rounded,
                    color: Color(0xFF2563EB),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inworld AI Voice API',
                        style: GoogleFonts.baloo2(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Photorealistic voice cloning & Realtime TTS-2 cloud synthesis',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Get your API Key from Inworld Studio: platform.inworld.ai -> Workspace (green-banjo-3573) -> Settings -> API Keys.',
                      style: GoogleFonts.nunito(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'INWORLD API KEY',
              style: GoogleFonts.nunito(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _keyController,
              obscureText: _obscureKey,
              decoration: InputDecoration(
                hintText: 'Paste Inworld API Key (e.g. dXNlcl9pZ...)',
                hintStyle: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscureKey ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 20,
                        color: AppColors.textMedium,
                      ),
                      onPressed: () => setState(() => _obscureKey = !_obscureKey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : () => _fetchVoices(),
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_rounded, size: 18),
                label: Text(
                  _isLoading ? 'Connecting...' : 'Test Connection & Fetch Workspace Voices',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF93C5FD)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isSuccess ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isSuccess ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                  ),
                ),
                child: Text(
                  _statusMessage!,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _isSuccess ? const Color(0xFF166534) : const Color(0xFF991B1B),
                  ),
                ),
              ),
            ],
            if (_workspaceVoices.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'SELECT CLONED VOICE TO USE',
                style: GoogleFonts.nunito(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _workspaceVoices.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final voice = _workspaceVoices[i];
                    final isSelected = _selectedVoiceId == voice.voiceId;
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.record_voice_over_outlined,
                        color: isSelected ? AppColors.success : AppColors.textMedium,
                        size: 20,
                      ),
                      title: Text(
                        voice.displayName,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        voice.voiceId,
                        style: GoogleFonts.nunito(fontSize: 10, color: AppColors.textLight),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedVoiceId = voice.voiceId;
                          _voiceIdController.text = voice.voiceId;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              'OR ENTER VOICE ID MANUALLY',
              style: GoogleFonts.nunito(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _voiceIdController,
              decoration: InputDecoration(
                hintText: 'e.g. workspace-id__cloned-voice',
                hintStyle: GoogleFonts.nunito(fontSize: 12, color: AppColors.textLight),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() => _selectedVoiceId = val.trim());
              },
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _saveConfig,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: Text(
                  'Save & Use Inworld Cloud Voice',
                  style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.headerPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _TextControllerExt on TextEditingController {
  void disposeDatabaseSafe() {
    dispose();
  }
}
