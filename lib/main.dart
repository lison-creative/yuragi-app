import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'audio_handler.dart';
import 'second_page.dart';
import 'pages/music_page.dart';
import 'pages/garage_page.dart';
import 'pages/shop_page.dart';
import 'pages/live_page.dart';
import 'pages/SecretRoomPage.dart';
import 'pages/settings_page.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(brightness: Brightness.dark),
  home: const EntrancePage(),
));

// --- Safari/Chrome対策：入り口ページ（音量確認の儀式） ---
class EntrancePage extends StatelessWidget {
  const EntrancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: FullScreenBeadedDecoration()),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("AUDITORY CHECK",
                    style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), fontSize: 18, letterSpacing: 10)),
                const SizedBox(height: 60),

                // 物理ボタンの操作を促すガイド
                const Icon(Icons.volume_up, color: Colors.white24, size: 28),
                const SizedBox(height: 15),
                Text(
                  "端末の音量ボタンを上げ、\n準備ができたら扉に触れてください",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerifJp(color: Colors.white38, fontSize: 11, height: 1.8),
                ),

                const SizedBox(height: 80),

                GestureDetector(
                  onTap: () async {
                    // タップした瞬間に一瞬音を鳴らして実績を作る
                    final tempPlayer = AudioPlayer();
                    try {
                      await tempPlayer.setVolume(0);
                      await tempPlayer.play(AssetSource('openingmusic.wav'));
                      await Future.delayed(const Duration(milliseconds: 100));
                      await tempPlayer.stop();
                      await tempPlayer.dispose();
                    } catch (_) {}

                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const MainNavigation(),
                          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                          transitionDuration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 0.8),
                    ),
                    // 指紋アイコンで「解印」や「入室」を演出
                    child: const Icon(Icons.fingerprint, color: Color(0xFFD4AF37), size: 42),
                  ),
                ),
                const SizedBox(height: 30),
                Text("ENTER THE ROOM",
                    style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37).withOpacity(0.6), fontSize: 12, letterSpacing: 4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 本編メインナビゲーション ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  static _MainNavigationState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainNavigationState>();

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final MyAudioHandler _audioHandler = MyAudioHandler();

  final List<String> _pageTitles = [
    "ENTRANCE", "MENU", "MUSIC ARCHIVE", "GARAGE GALLERY", "SHOP", "FEELING", "FAN LETTER"
  ];

  void changePage(int index) {
    setState(() => _currentIndex = index);
  }

  void _openSettings() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SettingsPage(
        player: _audioHandler.player,
        musicList: musicList,
        onUnlock: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              const FirstPage(),
              const SecondPage(),
              MusicPage(),
              const Scaffold(backgroundColor: Colors.black),
              const GaragePage(),
              const ShopPage(),
              const LivePage(),
              const SecretRoomPage(),
            ],
          ),

          if (_currentIndex != 0)
            Positioned(top: 50, left: 0, right: 0, child: _buildSynchronizedTextList()),

          if (_currentIndex != 0)
            Positioned(
              top: 45, right: 20,
              child: IconButton(
                icon: const Icon(Icons.settings, color: Color(0xFFD4AF37), size: 18),
                onPressed: () => _openSettings(),
              ),
            ),

          if (_audioHandler.currentSong != null && _currentIndex != 0)
            _buildMiniPlayer(),
        ],
      ),
    );
  }

  Widget _buildSynchronizedTextList() {
    return SizedBox(
      height: 30,
      child: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: _pageTitles.length,
          itemBuilder: (context, index) {
            bool isSelected = _currentIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                _pageTitles[index],
                style: GoogleFonts.cinzel(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.white24,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    final song = _audioHandler.currentSong!;
    return Positioned(
      left: 20, right: 20, bottom: 40,
      child: GestureDetector(
        onTap: () {
          changePage(2);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            MusicPage.globalKey.currentState?.openPlayer();
          });
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              const Icon(Icons.music_note, color: Color(0xFFD4AF37), size: 16),
              const SizedBox(width: 15),
              Expanded(child: Text(song['title']!, style: GoogleFonts.notoSerifJp(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis)),
              Icon(_audioHandler.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 24),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 最初のメイン画面 ---
class FirstPage extends StatefulWidget {
  const FirstPage({super.key});
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> with TickerProviderStateMixin {
  late AnimationController _logoController, _mainEffectController, _swayController, _blinkController;
  late Animation<double> _zoomAnimation, _blurAnimation, _brightnessAnimation, _verticalSway, _textOpacity;
  final _audioHandler = MyAudioHandler();

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(duration: const Duration(seconds: 30), vsync: this)..repeat();
    _mainEffectController = AnimationController(duration: const Duration(seconds: 8), vsync: this)..repeat();
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(CurvedAnimation(parent: _mainEffectController, curve: Curves.easeInOutSine));
    _blurAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0.001), weight: 85),
      TweenSequenceItem(tween: Tween<double>(begin: 0.001, end: 15.0), weight: 15),
    ]).animate(_mainEffectController);
    _brightnessAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _mainEffectController, curve: Curves.easeIn));
    _swayController = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat();
    _verticalSway = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 12).chain(CurveTween(curve: Curves.easeInOutSine)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 12, end: 0).chain(CurveTween(curve: Curves.easeInOutSine)), weight: 50),
    ]).animate(_swayController);
    _blinkController = AnimationController(duration: const Duration(seconds: 4), vsync: this)..repeat();
    _textOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.2, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.2).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
    ]).animate(_blinkController);
  }

  @override
  void dispose() {
    _logoController.dispose(); _mainEffectController.dispose(); _swayController.dispose(); _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_mainEffectController, _swayController]),
            builder: (context, _) => Transform.translate(
              offset: Offset(0, _verticalSway.value),
              child: Transform.scale(
                scale: _zoomAnimation.value,
                child: Opacity(
                  opacity: _brightnessAnimation.value.clamp(0.0, 1.0),
                  child: Stack(
                    children: [
                      Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/back.jpg'), fit: BoxFit.cover))),
                      Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: _blurAnimation.value.clamp(0.001, 20.0), sigmaY: _blurAnimation.value.clamp(0.001, 20.0)), child: Container(color: Colors.transparent))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(decoration: BoxDecoration(gradient: RadialGradient(center: Alignment.center, radius: 1.2, colors: [Colors.amber.withOpacity(0.1), Colors.black.withOpacity(0.7)]))),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(animation: _textOpacity, builder: (context, child) => Opacity(opacity: _textOpacity.value, child: Text("OFFICIAL APPLICATION", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 11, letterSpacing: 6)))),
                const SizedBox(height: 35),
                RotationTransition(turns: _logoController, child: GestureDetector(onTap: () => MainNavigation.of(context)?.changePage(1), child: Container(decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.2), blurRadius: 45, spreadRadius: 2)]), child: ClipOval(child: Image.asset('assets/rogo.png', width: 180, height: 180, fit: BoxFit.cover))))),
                const SizedBox(height: 60),
                _buildPlayButton(),
              ],
            ),
          ),
          Positioned(bottom: 60, left: 0, right: 0, child: Center(child: Text("- yuragi -", style: GoogleFonts.notoSerifJp(color: const Color(0xFFD4AF37).withOpacity(0.8), fontSize: 22, letterSpacing: 12)))),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    bool isPlaying = _audioHandler.isPlaying && _audioHandler.currentSong?['path'] == 'openingmusic.wav';
    return GestureDetector(
      onTap: () async {
        if (isPlaying) await _audioHandler.toggle();
        else await _audioHandler.playNewSong({'title': 'Featured', 'path': 'openingmusic.wav'});
        setState(() {});
      },
      child: Column(
        children: [
          Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: Colors.white.withOpacity(0.8), size: 55),
          const SizedBox(height: 10),
          Text("LISTEN", style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.5), fontSize: 14, letterSpacing: 5)),
        ],
      ),
    );
  }
}

class FullScreenBeadedDecoration extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFFD4AF37).withOpacity(0.16);
    for (double i = 0; i <= size.width; i += 32) {
      for (double j = 0; j <= size.height; j += 32) {
        if ((i + j) % 64 == 0) canvas.drawCircle(Offset(i, j), 1.1, p);
      }
    }
  }
  @override bool shouldRepaint(CustomPainter old) => false;
}