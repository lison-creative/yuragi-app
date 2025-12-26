import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

// --- [動画データ構造] ---
class GalleryVideo {
  final String title;
  final String imageUrl;
  final String youtubeUrl;
  final String description;

  GalleryVideo({
    required this.title,
    required this.imageUrl,
    required this.youtubeUrl,
    required this.description,
  });
}

// 展示する動画のリスト
final List<GalleryVideo> garageVideos = [
  GalleryVideo(
    title: "どこかで幸せに。\n近日公開",
    imageUrl: "assets/back.jpg",
    youtubeUrl: "https://www.youtube.com/@Cocoro-no-yuragi",
    description: "「お互いを嫌いになったわけじゃない。」\nそんな言葉では片付けられない想いを、映像と共に表現しました。静寂の中に響く調べを、ぜひ視覚でも感じてください。",
  ),
  GalleryVideo(
    title: "半径70センチメートル",
    imageUrl: "assets/back.jpg",
    youtubeUrl: "https://youtu.be/XRgcLxcnfiM",
    description: "手が届きそうで届かない、その僅かな距離。物理的な距離ではなく、心の空白をテーマにしたミュージックビデオです。",
  ),
  GalleryVideo(
    title: "傾いたバランス",
    imageUrl: "assets/back.jpg",
    youtubeUrl: "https://youtu.be/kwKRKtTSvvE",
    description: "正しさよりも優しさを。崩れゆく世界の中で、私たちが握りしめるべきものは何か。激しさと切なさが交差する一作です。",
  ),
  GalleryVideo(
    title: "検索「寂しさとは」",
    imageUrl: "assets/back.jpg",
    youtubeUrl: "https://youtu.be/qpRJAhb-kYU",
    description: "寂しいってなんだろう、分からないままでいいのかもしれない。",
  ),

];

class GaragePage extends StatefulWidget {
  const GaragePage({super.key}); // Keyの書き方を最新に
  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  late PageController _pageController;
  double _currentPage = 0.0;
  bool _isLightOn = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8)
      ..addListener(() {
        if (mounted) {
          setState(() {
            // 安全に現在のページを取得
            _currentPage = _pageController.hasClients ? (_pageController.page ?? 0.0) : 0.0;
          });
        }
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. 背景（Musicと共通）
          Positioned.fill(
            child: Opacity(
              opacity: _isLightOn ? 0.35 : 0.12,
              child: Image.asset('assets/back.jpg', fit: BoxFit.cover),
            ),
          ),

          // 2. ビーズ装飾（Musicと共通）
          Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: FullScreenBeadedDecoration()))),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),

                // 3. ギャラリーエリア（ズームアニメーション付き）
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: garageVideos.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      double delta = (_currentPage - index).abs();
                      // 中央にあるときは1.0、離れると0.85になるスケール
                      double scale = (1.0 - (delta * 0.15)).clamp(0.85, 1.0);
                      bool isCenter = delta < 0.2;

                      return Center(
                        child: Transform.scale(
                          scale: scale,
                          child: _buildArtFrame(garageVideos[index], isCenter),
                        ),
                      );
                    },
                  ),
                ),

                // ナビゲーションバーのための余白
                const SizedBox(height: 100),
              ],
            ),
          ),

          // 4. 四隅のリベット（Musicと共通）
          Positioned(top: 15, left: 15, child: _rivet()),
          Positioned(top: 15, right: 15, child: _rivet()),
          Positioned(bottom: 15, left: 15, child: _rivet()),
          Positioned(bottom: 15, right: 15, child: _rivet()),
        ],
      ),
    );
  }

  // --- UI Parts ---

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFD4AF37), size: 22),
          onPressed: () => MainNavigation.of(context)?.changePage(1),
        ),
        Text("GARAGE GALLERY", style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), fontSize: 22, letterSpacing: 3, fontWeight: FontWeight.w900)),
        GestureDetector(
          onTap: () => setState(() => _isLightOn = !_isLightOn),
          child: CustomPaint(size: const Size(40, 40), painter: MoonLightPainter(isOn: _isLightOn)),
        ),
      ],
    ),
  );

  Widget _buildArtFrame(GalleryVideo video, bool isCenter) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // タイトル
        Text(
          video.title,
          style: GoogleFonts.notoSerifJp(color: const Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 15),

        // 額縁
        GestureDetector(
          onTap: () => _launchURL(video.youtubeUrl),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF3D3222), // 木枠
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 20, offset: const Offset(0, 10)),
                if (isCenter) BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.15), blurRadius: 30),
              ],
            ),
            child: Container(
              width: 260,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(video.imageUrl, fit: BoxFit.cover),
                  Container(color: Colors.black.withValues(alpha: 0.2)),
                  const Center(child: Icon(Icons.play_circle_outline, color: Colors.white70, size: 50)),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 25),

        // コメントエリア
        AnimatedOpacity(
          duration: const Duration(milliseconds: 600),
          opacity: isCenter ? 1.0 : 0.0,
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Container(height: 1, width: 40, color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                const SizedBox(height: 15),
                Text(
                  video.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerifJp(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.8),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _rivet() => Container(width: 14, height: 14, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: Alignment(-0.3, -0.3), colors: [Color(0xFFD4AF37), Color(0xFF1A1A1A)])));
}

// --- [共通Painter：music_pageからコピー] ---
class FullScreenBeadedDecoration extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.16);
    for (double i = 0; i <= size.width; i += 32) {
      for (double j = 0; j <= size.height; j += 32) {
        if ((i + j) % 64 == 0) canvas.drawCircle(Offset(i, j), 1.1, p);
      }
    }
  }
  @override bool shouldRepaint(CustomPainter old) => false;
}

class MoonLightPainter extends CustomPainter {
  final bool isOn;
  MoonLightPainter({required this.isOn});
  @override void paint(Canvas canvas, Size size) {
    final p = Paint()..color = isOn ? const Color(0xFFFFFDE7) : const Color(0xFF333333);
    final path = Path()..addOval(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.5), radius: size.width * 0.45));
    final path2 = Path()..addOval(Rect.fromCircle(center: Offset(size.width * 0.75, size.height * 0.35), radius: size.width * 0.42));
    canvas.drawPath(Path.combine(PathOperation.difference, path, path2), p);
  }
  @override bool shouldRepaint(covariant MoonLightPainter old) => isOn != old.isOn;
}