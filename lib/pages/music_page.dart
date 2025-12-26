import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../main.dart';

enum RepeatMode { off, all, one }

class MusicData {
  final String title;
  final String lyrics;
  final String audioPath;
  final String backgroundAsset;
  bool isPlaying;
  RepeatMode repeatMode;

  MusicData({
    required this.title,
    required this.lyrics,
    required this.audioPath,
    required this.backgroundAsset,
    this.isPlaying = false,
    this.repeatMode = RepeatMode.off,
  });
}

// ---------------------------------------------------------------------------
// [重要修正] musicList をクラスの外（トップレベル）に配置
// これにより main.dart から直接「musicList」として参照できるようになります。
// ---------------------------------------------------------------------------
final List<MusicData> musicList = [
  MusicData(
    title: "どこかで幸せに。",
    lyrics: "お互いを嫌いになったわけじゃない\nでも、あるんだよ、そういうの。...",
    audioPath: "music/dokokadeshiawaseni.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "半径70センチメートル",
    lyrics: "70cmの傘を買って\n二人で、入るのが夢だった。...",
    audioPath: "music/umbrella.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "傾いたバランス",
    lyrics: "触れてしまったら、バイバイができなくなるような、そんな気がしたの。...",
    audioPath: "music/傾いたバランス.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "検索「寂しさとは」",
    lyrics: "寂しいってなんだろう...",
    audioPath: "music/検索「寂しさとは」.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "不協心音",
    lyrics: "初めて聞いた言葉は覚えてない...",
    audioPath: "music/不協心音.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "ふたりの終点",
    lyrics: "部屋の鍵を返して、終わらせたつもり。...",
    audioPath: "music/ふたりの終点.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "さよならの予感",
    lyrics: "歌詞ちょっと待ってね",
    audioPath: "music/さよならの予感.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "最後の嘘",
    lyrics: "歌詞は明日やる",
    audioPath: "music/最後の嘘.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "雨粒ドレス",
    lyrics: "まじメリークリスマス",
    audioPath: "music/雨粒ドレス.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "sleepless",
    lyrics: "クリスマスプレゼントだぜっ！！",
    audioPath: "music/sleepless.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "I・KAROS",
    lyrics: "この曲は思い入れある",
    audioPath: "music/イカロス.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "未練といえばそうかもね。",
    lyrics: "切ないなあ",
    audioPath: "music/未練.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "言葉たらず。",
    lyrics: "今度知り合いがカバーしますっ",
    audioPath: "music/言葉たらず.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "ただの男だった\n-純白汚損事件-",
    lyrics: "騙されちゃダメだっ",
    audioPath: "music/ただの男.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "傾いたバランス",
    lyrics: "いーや好きって言ったのそっちじゃん!!",
    audioPath: "music/バランス.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "無自覚な狂気\n- ブラックジョーク　-",
    lyrics: "あの人間は許さんが、こんなに世界が広がったんだ、、まぁいいか。",
    audioPath: "music/ブラックジョーク.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "ブルーノイズブルース",
    lyrics: "これいいでしょ",
    audioPath: "music/ブルーノイズブルース.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "アイドルミッション!!",
    lyrics: "MVかわいいよね",
    audioPath: "music/アイドル.wav",
    backgroundAsset: "assets/back.jpg",
  ),
  MusicData(
    title: "ドッペルゲンガー",
    lyrics: "これ好き",
    audioPath: "music/ドッペルゲンガー.wav",
    backgroundAsset: "assets/back.jpg",
  ),
];

final AudioPlayer globalAudioPlayer = AudioPlayer();

class MusicPage extends StatefulWidget {
  static final GlobalKey<_MusicPageState> globalKey = GlobalKey<_MusicPageState>();
  MusicPage({Key? key}) : super(key: globalKey);

  @override _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  bool _isLightOn = true;
  int _currentPlayingIndex = 0;

  late ScrollController _infiniteController;
  final ScrollController _syncScrollController = ScrollController();
  static const int _loopMultiplier = 1000;
  static const double _itemEstimatedHeight = 140.0;

  @override
  void initState() {
    super.initState();
    final initialItemIndex = (musicList.length * _loopMultiplier / 2).floor();
    _infiniteController = ScrollController(
      initialScrollOffset: initialItemIndex * _itemEstimatedHeight,
    );

    _infiniteController.addListener(() {
      double maxScroll = _infiniteController.position.maxScrollExtent;
      double minScroll = _infiniteController.position.minScrollExtent;
      double current = _infiniteController.offset;

      if (current >= maxScroll - 500) {
        _infiniteController.jumpTo(minScroll + (maxScroll / 2));
      } else if (current <= minScroll + 500) {
        _infiniteController.jumpTo(maxScroll / 2);
      }
    });
  }

  @override
  void dispose() {
    _infiniteController.dispose();
    _syncScrollController.dispose();
    super.dispose();
  }

  void openPlayer() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerDetailPage(index: _currentPlayingIndex)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
              child: Opacity(
                  opacity: _isLightOn ? 0.45 : 0.15,
                  child: Image.asset('assets/back.jpg', fit: BoxFit.cover)
              )
          ),
          Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: FullScreenBeadedDecoration()))),

          if (_isLightOn) Positioned(top: -120, right: -60, child: IgnorePointer(child: _buildHalo())),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 5),
                _buildSyncTextList(),

                Expanded(
                  child: ListView.builder(
                    controller: _infiniteController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 120),
                    itemCount: musicList.length * _loopMultiplier,
                    itemBuilder: (context, index) {
                      final realIndex = index % musicList.length;
                      final data = musicList[realIndex];

                      return Column(
                        key: ValueKey("infinite_song_$index"),
                        children: [
                          CustomPaint(
                              size: const Size(double.infinity, 35),
                              painter: VerticalChainPainter()
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _currentPlayingIndex = realIndex);
                              openPlayer();
                            },
                            child: _buildVintageSongCard(data, isCurrent: realIndex == _currentPlayingIndex),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildBottomPlayerBar(),
          Positioned(top: 15, left: 15, child: _rivet()),
          Positioned(top: 15, right: 15, child: _rivet()),
          Positioned(bottom: 15, left: 15, child: _rivet()),
          Positioned(bottom: 15, right: 15, child: _rivet()),
        ],
      ),
    );
  }

  Widget _buildSyncTextList() => Container(
      height: 45,
      decoration: BoxDecoration(
          border: Border.symmetric(horizontal: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.15), width: 0.8))
      ),
      child: ListView.separated(
          controller: _syncScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: musicList.length,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          separatorBuilder: (_, __) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Center(child: Text("|", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10)))
          ),
          itemBuilder: (context, index) => Center(
              child: Text(
                  musicList[index].title,
                  style: GoogleFonts.cinzel(
                      color: index == _currentPlayingIndex ? const Color(0xFFD4AF37) : Colors.white24,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: index == _currentPlayingIndex ? FontWeight.bold : FontWeight.normal
                  )
              )
          )
      )
  );

  Widget _buildVintageSongCard(MusicData data, {bool isCurrent = false}) => Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withValues(alpha: isCurrent ? 0.35 : 0.2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 12, offset: const Offset(0, 6))]
    ),
    child: Container(
      decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          border: Border.all(color: const Color(0xFF3D3222), width: 4)
      ),
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(data.title, style: GoogleFonts.notoSerifJp(color: const Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
          Icon(isCurrent ? Icons.graphic_eq : Icons.arrow_forward_ios, color: const Color(0xFFD4AF37), size: 16)
        ],
      ),
    ),
  );

  Widget _buildBottomPlayerBar() => Positioned(
    bottom: 30, left: 25, right: 25,
    child: GestureDetector(
      onTap: openPlayer,
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
            boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.2), blurRadius: 15)]
        ),
        child: Row(
          children: [
            Expanded(child: Text("Now: ${musicList[_currentPlayingIndex].title}", style: GoogleFonts.notoSerifJp(color: Colors.white, fontSize: 14), overflow: TextOverflow.ellipsis)),
            const Icon(Icons.play_circle_fill, color: Color(0xFFD4AF37), size: 32),
          ],
        ),
      ),
    ),
  );

  Widget _buildHeader() => Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFD4AF37), size: 22), onPressed: () => MainNavigation.of(context)?.changePage(1)), Text("MUSIC ARCHIVE", style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), fontSize: 22, letterSpacing: 5, fontWeight: FontWeight.w900)), GestureDetector(onTap: () => setState(() => _isLightOn = !_isLightOn), child: CustomPaint(size: const Size(42, 42), painter: MoonLightPainter(isOn: _isLightOn)))]));
  Widget _buildHalo() => Container(width: 600, height: 600, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0xFFFFFDE7).withValues(alpha: 0.15), Colors.transparent], stops: const [0.3, 1.0])));
  Widget _rivet() => Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: const Alignment(-0.3, -0.3), colors: [const Color(0xFFD4AF37), const Color(0xFF1A1A1A)], stops: const [0.1, 1.0]), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 3)]));
}

class PlayerDetailPage extends StatefulWidget {
  final int index;
  const PlayerDetailPage({Key? key, required this.index}) : super(key: key);
  @override _PlayerDetailPageState createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> {
  late MusicData _data;
  late int _currentIndex;
  StreamSubscription? _completeSubscription;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _setupPlayer();
    _completeSubscription = globalAudioPlayer.onPlayerComplete.listen((event) {
      _handlePlaybackComplete();
    });
  }

  @override
  void dispose() {
    _completeSubscription?.cancel();
    super.dispose();
  }

  void _setupPlayer() {
    _data = musicList[_currentIndex];
    globalAudioPlayer.setSource(AssetSource(_data.audioPath));
  }

  void _handlePlaybackComplete() {
    if (!mounted) return;
    if (_data.repeatMode == RepeatMode.one) {
      globalAudioPlayer.seek(Duration.zero);
      globalAudioPlayer.resume();
    } else if (_data.repeatMode == RepeatMode.all) {
      _playNext();
    } else {
      if (_currentIndex < musicList.length - 1) {
        _playNext();
      } else {
        setState(() => _data.isPlaying = false);
      }
    }
  }

  void _playNext() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % musicList.length;
      _data = musicList[_currentIndex];
      _data.isPlaying = true;
    });
    globalAudioPlayer.setSource(AssetSource(_data.audioPath));
    globalAudioPlayer.resume();
  }

  void _togglePlay() async {
    if (_data.isPlaying) await globalAudioPlayer.pause();
    else await globalAudioPlayer.resume();
    setState(() => _data.isPlaying = !_data.isPlaying);
  }

  void _seekRelative(int seconds) async {
    final pos = await globalAudioPlayer.getCurrentPosition() ?? Duration.zero;
    await globalAudioPlayer.seek(pos + Duration(seconds: seconds));
  }

  void _cycleRepeatMode() {
    setState(() {
      if (_data.repeatMode == RepeatMode.off) _data.repeatMode = RepeatMode.all;
      else if (_data.repeatMode == RepeatMode.all) _data.repeatMode = RepeatMode.one;
      else _data.repeatMode = RepeatMode.off;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Opacity(opacity: 0.5, child: Image.asset(_data.backgroundAsset, fit: BoxFit.cover))),
          Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: FullScreenBeadedDecoration()))),
          SafeArea(
            child: Column(
              children: [
                _buildBackHeader(),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10), child: Text(_data.title, textAlign: TextAlign.center, style: GoogleFonts.notoSerifJp(color: const Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, shadows: const [Shadow(color: Colors.black, blurRadius: 15)]))),
                Expanded(child: Row(children: [Expanded(flex: 4, child: _buildControlPanel()), Expanded(flex: 6, child: _buildLyricPanel())])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackHeader() => Align(alignment: Alignment.topLeft, child: InkWell(onTap: () => Navigator.pop(context), child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [const Icon(Icons.arrow_back, color: Color(0xFFD4AF37), size: 38), Text("BACK", style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5))]))));
  Widget _buildControlPanel() => Column(mainAxisAlignment: MainAxisAlignment.center, children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildCircleButton(Icons.replay_10, () => _seekRelative(-10), label: "-10s"), const SizedBox(width: 25), _buildCircleButton(Icons.forward_10, () => _seekRelative(10), label: "+10s")]), const SizedBox(height: 45), _buildMainPlayButton(), const SizedBox(height: 45), _buildCircleButton(Icons.replay, () => globalAudioPlayer.seek(Duration.zero), label: "RESTART"), const SizedBox(height: 30), _buildRepeatButton()]);
  Widget _buildMainPlayButton() => GestureDetector(onTap: _togglePlay, child: Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD4AF37), width: 2), gradient: const RadialGradient(colors: [Color(0xFF5A4D3B), Color(0xFF000000)]), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.9), blurRadius: 25)]), child: Icon(_data.isPlaying ? Icons.pause : Icons.play_arrow, color: const Color(0xFFD4AF37), size: 45)));
  Widget _buildCircleButton(IconData icon, VoidCallback onTap, {required String label}) => Column(children: [IconButton(icon: Icon(icon, color: Colors.white70, size: 30), onPressed: onTap), Text(label, style: GoogleFonts.cinzel(color: Colors.white30, fontSize: 10, letterSpacing: 1))]);
  Widget _buildRepeatButton() { IconData icon = Icons.repeat; Color col = Colors.white30; String label = "OFF"; if (_data.repeatMode != RepeatMode.off) { icon = _data.repeatMode == RepeatMode.one ? Icons.repeat_one : Icons.repeat; col = const Color(0xFFD4AF37); label = _data.repeatMode == RepeatMode.one ? "ONE" : "ALL"; } return Column(children: [IconButton(icon: Icon(icon, color: col, size: 30), onPressed: _cycleRepeatMode), Text(label, style: GoogleFonts.cinzel(color: col, fontSize: 10, letterSpacing: 1))]); }
  Widget _buildLyricPanel() => Container(margin: const EdgeInsets.fromLTRB(0, 10, 20, 40), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.2), width: 1.5)), child: SingleChildScrollView(padding: const EdgeInsets.all(25), child: CustomPaint(painter: NoteLinePainter(), child: Text(_data.lyrics, style: GoogleFonts.notoSerifJp(color: Colors.white.withValues(alpha: 0.9), fontSize: 17, height: 2.5, letterSpacing: 1.5)))));
}

class VerticalChainPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF3D3222)..style = PaintingStyle.stroke..strokeWidth = 3.5;
    final center = size.width / 2;
    canvas.drawLine(Offset(center - 13, 0), Offset(center - 13, size.height), paint);
    canvas.drawLine(Offset(center + 13, 0), Offset(center + 13, size.height), paint);
    final ring = Paint()..color = const Color(0xFF1A150E)..style = PaintingStyle.fill;
    for (double i = 6; i < size.height; i += 14) {
      canvas.drawOval(Rect.fromCenter(center: Offset(center - 13, i), width: 9, height: 13), ring);
      canvas.drawOval(Rect.fromCenter(center: Offset(center + 13, i), width: 9, height: 13), ring);
    }
  }
  @override bool shouldRepaint(CustomPainter old) => false;
}

class NoteLinePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final p = Paint()..shader = LinearGradient(colors: [Colors.transparent, const Color(0xFFD4AF37).withValues(alpha: 0.3), Colors.transparent]).createShader(Rect.fromLTWH(0, 0, size.width, size.height))..strokeWidth = 1.3;
    for (double i = 42; i < size.height; i += 42) { canvas.drawLine(Offset(0, i), Offset(size.width, i), p); }
  }
  @override bool shouldRepaint(CustomPainter old) => false;
}

class FullScreenBeadedDecoration extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final p = Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.16);
    for (double i = 0; i < size.width; i += 32) {
      for (double j = 0; j < size.height; j += 32) {
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