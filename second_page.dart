import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'main.dart';

class CategoryData {
  final String title;
  final String imagePath;
  final int pageIndex;
  CategoryData({required this.title, required this.imagePath, required this.pageIndex});
}

final List<CategoryData> categories = [
  CategoryData(title: "MUSIC", imagePath: 'assets/rogo.png', pageIndex: 2),
  CategoryData(title: "GARAGE", imagePath: 'assets/rogo.png', pageIndex: 4),
  CategoryData(title: "SHOP", imagePath: 'assets/rogo.png', pageIndex: 5),
  CategoryData(title: "FEELING", imagePath: 'assets/rogo.png', pageIndex: 6),
  CategoryData(title: "Letter", imagePath: 'assets/rogo.png', pageIndex: 6),
  CategoryData(title: "秘密の部屋", imagePath: 'assets/rogo.png', pageIndex: 7),
];

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});
  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _bgFadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bgFadeAnimation;

  double _currentPage = 0.0;
  bool _showContent = false;
  bool _isLightOn = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.7, initialPage: 0);
    _pageController.addListener(() {
      if (mounted) setState(() => _currentPage = _pageController.page ?? 0.0);
    });

    _fadeController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _bgFadeController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
    _bgFadeAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(CurvedAnimation(parent: _bgFadeController, curve: Curves.easeIn));

    _startWelcomeEffect();
  }

  void _startWelcomeEffect() async {
    if (!mounted) return;
    setState(() => _showContent = false);
    _bgFadeController.reset();
    _fadeController.reset();
    await Future.delayed(const Duration(milliseconds: 300));
    _bgFadeController.forward();
    await _fadeController.forward();
    await Future.delayed(const Duration(seconds: 3));
    await _fadeController.reverse();
    if (mounted) setState(() => _showContent = true);
  }

  Future<void> _saveToSecretRoom(String text) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('secret_letters') ?? [];
    String date = DateTime.now().toString().substring(0, 16);
    Map<String, String> newLetter = {"date": date, "content": text};
    history.insert(0, json.encode(newLetter));
    await prefs.setStringList('secret_letters', history);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _bgFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. 背景レイヤー
          AnimatedBuilder(
            animation: _bgFadeAnimation,
            builder: (context, child) {
              double lightPower = _isLightOn ? 1.0 : 0.15;
              return Positioned.fill(
                child: Opacity(
                  opacity: _bgFadeAnimation.value * lightPower,
                  child: Image.asset('assets/back.jpg', fit: BoxFit.cover),
                ),
              );
            },
          ),

          // 2. ビーズ装飾
          if (_showContent) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: FullScreenBeadedDecoration()))),

          // 3. 月明かりのハロー効果
          if (_isLightOn && _showContent)
            Positioned(
              top: -100, right: -50,
              child: IgnorePointer(
                child: Container(
                  width: 600, height: 600,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [const Color(0xFFFFFDE7).withOpacity(0.15), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),

          // 4. メインコンテンツ（アンティークフレーム等）
          AnimatedOpacity(
            opacity: _showContent ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 5000),
            curve: Curves.easeInCirc,
            child: IgnorePointer(
              ignoring: !_showContent,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(top: 15, left: 15, child: _rivet(size: 15)),
                  Positioned(top: 15, right: 15, child: _rivet(size: 15)),
                  Positioned(bottom: 15, left: 15, child: _rivet(size: 15)),
                  Positioned(bottom: 15, right: 15, child: _rivet(size: 15)),

                  SafeArea(
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 10),
                        _buildSyncHeader(),
                        Expanded(child: _buildMainSlider()),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. ウェルカムメッセージ
          if (!_showContent || _fadeController.isAnimating)
            IgnorePointer(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "愛 し 貴 方 へ",
                    style: GoogleFonts.yujiSyuku(
                      color: const Color(0xFFD4AF37),
                      fontSize: 32,
                      letterSpacing: 14,
                      shadows: [const Shadow(color: Colors.black, blurRadius: 25)],
                    ),
                  ),
                ),
              ),
            ),

          // 6. 【最前面】流れる星の演出
          if (_showContent) const Positioned.fill(child: FallingStarsLayer()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => MainNavigation.of(context)?.changePage(0),
            child: Text("夢から覚める", style: GoogleFonts.notoSerifJp(color: const Color(0xFFD4AF37).withOpacity(0.8), fontSize: 14, letterSpacing: 4)),
          ),
          GestureDetector(
            onTap: () => setState(() => _isLightOn = !_isLightOn),
            child: CustomPaint(
              size: const Size(60, 60),
              painter: MoonLightPainter(isOn: _isLightOn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncHeader() {
    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(categories.length, (index) {
          double diff = (index - _currentPage).abs();
          return Opacity(
            opacity: (1 - diff).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset((index - _currentPage) * 160, 0),
              child: Text(
                categories[index].title,
                style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), fontSize: 24 + (12 * (1 - diff).clamp(0, 1)), fontWeight: FontWeight.bold, letterSpacing: 10),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMainSlider() {
    return PageView.builder(
      controller: _pageController,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        double diff = (index - _currentPage).abs();
        return Transform.scale(
          scale: (1 - (diff * 0.25)).clamp(0.75, 1.0),
          child: _buildAntiqueFrame(index, diff),
        );
      },
    );
  }

  Widget _buildAntiqueFrame(int index, double diff) {
    const double frameWidth = 210.0;
    const double frameHeight = 310.0;
    double moonLightEffect = (1.0 - diff).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        if (categories[index].title == "Letter") {
          _showLetterDialog();
        } else {
          MainNavigation.of(context)?.changePage(categories[index].pageIndex);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(left: -90, top: 180, child: CustomPaint(size: const Size(110, 60), painter: MegaChainPainter(isLeft: true))),
          Positioned(right: -90, top: 180, child: CustomPaint(size: const Size(110, 60), painter: MegaChainPainter(isLeft: false))),
          Positioned(left: -70, top: 240, child: CustomPaint(size: const Size(90, 50), painter: MegaChainPainter(isLeft: true))),
          Positioned(right: -70, top: 240, child: CustomPaint(size: const Size(90, 50), painter: MegaChainPainter(isLeft: false))),

          Container(
            width: frameWidth, height: frameHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              border: Border.all(color: const Color(0xFF3D3222), width: 10),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.9), blurRadius: 35),
                if (_isLightOn)
                  BoxShadow(
                    color: const Color(0xFFFFFDE7).withOpacity(0.15 * moonLightEffect),
                    blurRadius: 20, spreadRadius: -5,
                  ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 1.5),
                gradient: _isLightOn ? LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.05 * moonLightEffect), Colors.transparent],
                ) : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(opacity: 0.3, child: Image.asset(categories[index].imagePath, fit: BoxFit.contain)),
                  Text(categories[index].title, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ),
          Positioned(top: 2, left: -6, child: _rivet(size: 18)),
          Positioned(top: 2, right: -6, child: _rivet(size: 18)),
          Positioned(bottom: 2, left: -6, child: _rivet(size: 18)),
          Positioned(bottom: 2, right: -6, child: _rivet(size: 18)),
        ],
      ),
    );
  }

  void _showLetterDialog() {
    final TextEditingController _letterController = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: Border.all(color: const Color(0xFF3D3222), width: 3),
            title: Text("Letter to...", style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), letterSpacing: 4)),
            content: TextField(
              controller: _letterController,
              maxLines: 8,
              style: GoogleFonts.notoSerifJp(color: Colors.white70),
              decoration: InputDecoration(
                hintText: "想いを綴る...",
                hintStyle: GoogleFonts.notoSansJp(color: Colors.white24),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderSide: BorderSide(color: const Color(0xFF3D3222))),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text("閉じる", style: TextStyle(color: Colors.white24))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3D3222)),
                onPressed: () async {
                  String text = _letterController.text;
                  if (text.isEmpty) return;
                  await _saveToSecretRoom(text);
                  Navigator.pop(context);
                  _playBurningEffect();
                },
                child: Text("想いを届ける", style: GoogleFonts.notoSerifJp(color: const Color(0xFFD4AF37))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _playBurningEffect() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 4),
        content: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 0.0),
            duration: const Duration(seconds: 3),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, -200 * (1 - value)),
                  child: Column(
                    children: [
                      Icon(Icons.whatshot, color: Colors.orange, size: 50 * (1 - value + 0.5)),
                      Text("手紙は灰となり、天へ...", style: GoogleFonts.notoSerifJp(color: const Color(0xFFD4AF37), fontSize: 18)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _rivet({double size = 16}) => Container(
    width: size, height: size,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(center: Alignment(-0.4, -0.4), colors: [Color(0xFFB8860B), Color(0xFF1A1A1A)]),
      boxShadow: [BoxShadow(color: Colors.black, blurRadius: 5, offset: Offset(2, 2))],
    ),
  );
}

// --- 新設：流れる星の演出レイヤー ---

// 個々の星のデータを保持するクラス
class Star {
  final UniqueKey id = UniqueKey();
  late double startX;
  late double startY;
  late double endY;
  late double size;
  late Duration duration;
  late double blurSigma;

  Star({required double screenWidth, required double screenHeight, math.Random? random}) {
    final _random = random ?? math.Random();
    startX = _random.nextDouble() * screenWidth;
    startY = -(_random.nextDouble() * 50); // 画面上部から少し外れた位置
    endY = screenHeight + 50; // 画面下部まで落ちる
    size = _random.nextDouble() * 5 + 3; // 3〜8のサイズ
    duration = Duration(milliseconds: _random.nextInt(3000) + 4000); // 4〜7秒かけて落下
    blurSigma = _random.nextDouble() * 3 + 1; // 1〜4のぼかし
  }
}

class FallingStarsLayer extends StatefulWidget {
  const FallingStarsLayer({super.key});

  @override
  State<FallingStarsLayer> createState() => _FallingStarsLayerState();
}

class _FallingStarsLayerState extends State<FallingStarsLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1)); // ダミー duration
    _controller.addListener(() {
      // フレームごとに星の状態を更新
      if (mounted) setState(() {});
    });

    // 数秒おきに新しい星を生成するタイマー
    _startStarGeneration();
  }

  void _startStarGeneration() async {
    while (mounted) {
      // 1〜3秒に1つ星を生成
      await Future.delayed(Duration(milliseconds: _random.nextInt(2000) + 1000));
      if (!mounted) break;

      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final newStar = Star(screenWidth: screenWidth, screenHeight: screenHeight, random: _random);

      setState(() {
        _stars.add(newStar);
        // 星が画面外に出たらリストから削除するタイマーをセット
        Future.delayed(newStar.duration + const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _stars.removeWhere((s) => s.id == newStar.id));
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer( // このレイヤーは操作を受け付けない
      child: Stack(
        children: _stars.map((star) {
          return TweenAnimationBuilder<double>(
            key: star.id, // 星ごとにユニークなキーを設定
            tween: Tween<double>(begin: star.startY, end: star.endY),
            duration: star.duration,
            builder: (context, yPosition, child) {
              // フェードアウトのタイミングを調整
              double opacity = 1.0;
              if (yPosition > star.endY * 0.8) { // 画面下2割でフェードアウト開始
                opacity = (star.endY - yPosition) / (star.endY * 0.2);
              }
              opacity = opacity.clamp(0.0, 0.4); // 最大不透明度も調整

              return Positioned(
                left: star.startX,
                top: yPosition,
                child: Opacity(
                  opacity: opacity,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: star.blurSigma, sigmaY: star.blurSigma),
                    child: Container(
                      width: star.size,
                      height: star.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // 金色に近い色を使用
                        color: const Color(0xFFD4AF37).withOpacity(opacity * 2.5), // フェードアウトに合わせて色も薄く
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}


// Painters類はそのまま保持
class MoonLightPainter extends CustomPainter {
  final bool isOn;
  MoonLightPainter({required this.isOn});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = isOn ? const Color(0xFFFFFDE7) : const Color(0xFF333333)..style = PaintingStyle.fill;
    if (isOn) {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.4, Paint()..color = const Color(0xFFFFFDE7).withOpacity(0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    }
    final path = Path();
    path.addOval(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width * 0.4));
    final path2 = Path();
    path2.addOval(Rect.fromCircle(center: Offset(size.width * 0.7, size.height * 0.4), radius: size.width * 0.35));
    canvas.drawPath(Path.combine(PathOperation.difference, path, path2), paint);
  }
  @override bool shouldRepaint(covariant MoonLightPainter oldDelegate) => isOn != oldDelegate.isOn;
}

class MegaChainPainter extends CustomPainter {
  final bool isLeft;
  MegaChainPainter({required this.isLeft});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2D2418)..style = PaintingStyle.stroke..strokeWidth = 5.0;
    final path = Path();
    if (isLeft) { path.moveTo(size.width, 0); path.quadraticBezierTo(size.width * 0.4, size.height * 1.8, 0, 0); }
    else { path.moveTo(0, 0); path.quadraticBezierTo(size.width * 0.6, size.height * 1.8, size.width, 0); }
    canvas.drawPath(path, paint);
    final fillPaint = Paint()..color = const Color(0xFF1A150E)..style = PaintingStyle.fill;
    final metrics = path.computeMetrics().first;
    for (double i = 0; i <= 1.0; i += 0.15) {
      final pos = metrics.getTangentForOffset(metrics.length * i)!.position;
      canvas.drawOval(Rect.fromCenter(center: pos, width: 16, height: 11), fillPaint);
      canvas.drawOval(Rect.fromCenter(center: pos, width: 16, height: 11), paint..strokeWidth = 2.0);
    }
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FullScreenBeadedDecoration extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFD4AF37).withOpacity(0.15)..style = PaintingStyle.fill;
    for (double i = 0; i < size.width; i += 30) {
      for (double j = 0; j < size.height; j += 30) {
        if ((i + j) % 60 == 0) canvas.drawCircle(Offset(i, j), 1.0, paint);
      }
    }
  }
  @override bool shouldRepaint(CustomPainter old) => false;
}
