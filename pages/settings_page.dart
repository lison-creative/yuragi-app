import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SettingsPage extends StatefulWidget {
  final AudioPlayer player;
  final List<dynamic> musicList;
  final VoidCallback onUnlock;

  const SettingsPage({
    super.key,
    required this.player,
    required this.musicList,
    required this.onUnlock,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  int _level = 1;
  int _exp = 0;
  bool _isAudioEnabled = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _level = prefs.getInt('level') ?? 1;
      _exp = prefs.getInt('exp') ?? 0;
    });
  }

  Future<void> _handleSafariUnlock() async {
    try {
      await widget.player.setVolume(0.0);
      if (widget.musicList.isNotEmpty) {
        await widget.player.play(AssetSource(widget.musicList[0].audioPath));
        await Future.delayed(const Duration(milliseconds: 200));
        await widget.player.stop();
      }
      await widget.player.setVolume(1.0);
      setState(() => _isAudioEnabled = true);
      _pulseController.stop();
    } catch (e) {
      debugPrint("Unlock Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.88,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              border: Border.all(color: const Color(0xFF3D3222), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("SYSTEM ORACLE",
                    style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), fontSize: 20, letterSpacing: 6)),
                const SizedBox(height: 10),
                const Text("世界の音を呼び覚ます設定", style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
                const Divider(color: Colors.white10, height: 40),

                // --- 音響解除セクション（改良版） ---
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("RESONANCE", style: TextStyle(color: Color(0xFF888888), fontSize: 10, letterSpacing: 2)),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _isAudioEnabled ? null : _handleSafariUnlock,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          color: _isAudioEnabled ? const Color(0xFFD4AF37).withOpacity(0.15) : Colors.black,
                          border: Border.all(
                            color: _isAudioEnabled
                                ? const Color(0xFFD4AF37)
                                : const Color(0xFFD4AF37).withOpacity(0.2 + (_pulseController.value * 0.4)),
                            width: 1.5,
                          ),
                          boxShadow: [
                            if (!_isAudioEnabled)
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.1 * _pulseController.value),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _isAudioEnabled ? Icons.auto_awesome : Icons.fingerprint,
                              color: _isAudioEnabled ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.5),
                              size: 40,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              _isAudioEnabled ? "RESONANCE READY" : "TOUCH TO ACTIVATE",
                              style: GoogleFonts.cinzel(
                                  color: _isAudioEnabled ? const Color(0xFFD4AF37) : Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isAudioEnabled ? "共鳴の準備が整いました" : "ここを触れて、旋律を許可してください",
                              style: const TextStyle(color: Colors.white24, fontSize: 9),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // --- プログレス（維持） ---
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("LV. $_level", style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 14)),
                          Text("EXP $_exp / 100", style: const TextStyle(color: Colors.white24, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: _exp / 100,
                        color: const Color(0xFFD4AF37).withOpacity(0.6),
                        backgroundColor: Colors.white10,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAudioEnabled ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.05),
                    foregroundColor: _isAudioEnabled ? Colors.black : Colors.white24,
                    minimumSize: const Size(double.infinity, 50),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    side: BorderSide(color: _isAudioEnabled ? Colors.transparent : Colors.white10),
                  ),
                  onPressed: widget.onUnlock,
                  child: Text(_isAudioEnabled ? "世界の扉を開く" : "設定を閉じる",
                      style: GoogleFonts.notoSerifJp(fontWeight: FontWeight.bold, letterSpacing: 4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}