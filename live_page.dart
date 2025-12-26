import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../main.dart'; // Navigation管理の定義場所を確認してください

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  List<Map<String, dynamic>> _posts = [];
  final String _postPassword = "08020742";
  final double _canvasWidth = 1000.0;
  final double _daySectionHeight = 600.0;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> data = prefs.getStringList('live_posts') ?? [];
    if (mounted) {
      setState(() {
        _posts = data.map((item) => json.decode(item) as Map<String, dynamic>).toList();
      });
    }
  }

  Future<void> _savePost(String text, double fontSize, bool isBold) async {
    final prefs = await SharedPreferences.getInstance();
    final random = math.Random();
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final newPost = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "text": text,
      "date": dateStr,
      "time": "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
      "relTop": random.nextDouble() * (_daySectionHeight - 200) + 100,
      "relLeft": random.nextDouble() * (_canvasWidth - 350) + 50,
      "angle": (random.nextDouble() - 0.5) * 0.15,
      "fontSize": fontSize,
      "isBold": isBold,
    };

    _posts.add(newPost);
    await _syncPrefs();
  }

  Future<void> _deletePost(String id) async {
    setState(() => _posts.removeWhere((p) => p['id'] == id));
    await _syncPrefs();
  }

  Future<void> _syncPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> data = _posts.map((item) => json.encode(item)).toList();
    await prefs.setStringList('live_posts', data);
    if (mounted) setState(() {});
  }

  // --- キーボード対応・自動フォーカス付きダイアログ ---
  void _showPostDialog() {
    final TextEditingController passController = TextEditingController();
    final TextEditingController textController = TextEditingController();
    double selectedSize = 15.0;
    bool selectedBold = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // キーボードの高さを取得
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;

          return AnimatedPadding(
            padding: EdgeInsets.only(bottom: bottomInset),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Center(
              child: SingleChildScrollView(
                child: AlertDialog(
                  backgroundColor: const Color(0xFFF5F5F5),
                  shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.black12)),
                  title: Text("想いを綴る", style: GoogleFonts.notoSerifJp(color: Colors.black87, fontSize: 16)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: passController,
                        obscureText: true,
                        autofocus: true, // ダイアログを開いた瞬間にキーボードを出す
                        keyboardType: TextInputType.number,
                        style: const TextStyle(letterSpacing: 3),
                        decoration: const InputDecoration(
                          hintText: "PASSWORD",
                          hintStyle: TextStyle(fontSize: 10, letterSpacing: 0),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          DropdownButton<double>(
                            value: selectedSize,
                            items: [12.0, 15.0, 20.0, 28.0].map((s) => DropdownMenuItem(value: s, child: Text("サイズ:${s.toInt()}"))).toList(),
                            onChanged: (val) => setDialogState(() => selectedSize = val!),
                          ),
                          FilterChip(
                            label: const Text("太字"),
                            selected: selectedBold,
                            onSelected: (val) => setDialogState(() => selectedBold = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: textController,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        style: GoogleFonts.notoSerifJp(
                            color: Colors.black,
                            fontSize: selectedSize,
                            fontWeight: selectedBold ? FontWeight.bold : FontWeight.normal
                        ),
                        decoration: const InputDecoration(
                          hintText: "ここには、何を描いても自由です。",
                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.black38))),
                    TextButton(
                      onPressed: () {
                        if (passController.text == _postPassword && textController.text.isNotEmpty) {
                          _savePost(textController.text, selectedSize, selectedBold);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("POST", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedPosts = {};
    for (var post in _posts) {
      String d = post['date'];
      groupedPosts.putIfAbsent(d, () => []).add(post);
    }
    List<String> sortedDates = groupedPosts.keys.toList()..sort((a, b) => b.compareTo(a));

    double pageMultiplier = (_posts.length / 100).floor() + 1.0;
    double totalHeight = math.max(1500.0, (sortedDates.length * _daySectionHeight) * pageMultiplier);

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      resizeToAvoidBottomInset: false, // ダイアログ側で制御するため false
      body: Stack(
        children: [
          // 1. ノート本体（ズーム・スクロール領域）
          InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(800),
            minScale: 0.2,
            maxScale: 3.0,
            child: Container(
              width: _canvasWidth,
              height: totalHeight,
              color: const Color(0xFFFCFAEF),
              child: CustomPaint(
                painter: NotebookPainter(height: totalHeight),
                child: Stack(
                  children: [
                    for (int i = 0; i < sortedDates.length; i++) ...[
                      Positioned(
                        top: i * _daySectionHeight + 40,
                        left: 60,
                        child: Text(
                          sortedDates[i],
                          style: GoogleFonts.cinzel(
                              color: Colors.red.withOpacity(0.4),
                              fontSize: 24,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      ...groupedPosts[sortedDates[i]]!.map((post) {
                        return _buildScratchPost(post, i * _daySectionHeight);
                      }),
                    ]
                  ],
                ),
              ),
            ),
          ),

          // 2. 固定UI：戻るボタン（確実に反応するように Material でラップ）
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  // Navigationが取得できない場合を考慮
                  final nav = MainNavigation.of(context);
                  if (nav != null) {
                    nav.changePage(1);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.arrow_back_ios_new, color: Colors.black54, size: 28),
                ),
              ),
            ),
          ),

          // 3. 固定UI：投稿ボタン
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              backgroundColor: Colors.black87,
              elevation: 8,
              onPressed: _showPostDialog,
              child: const Icon(Icons.edit, color: Color(0xFFD4AF37), size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScratchPost(Map<String, dynamic> post, double offsetTop) {
    return Positioned(
      top: offsetTop + (post['relTop'] ?? 100),
      left: post['relLeft'] ?? 50,
      child: Transform.rotate(
        angle: post['angle'] ?? 0,
        child: GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFFFCFAEF),
                title: Text("破り捨てる", style: GoogleFonts.notoSerifJp(fontSize: 16)),
                content: const Text("このつぶやきをノートから消去しますか？"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("残す")),
                  TextButton(
                      onPressed: () {
                        _deletePost(post['id']);
                        Navigator.pop(context);
                      },
                      child: const Text("捨てる", style: TextStyle(color: Colors.red))
                  ),
                ],
              ),
            );
          },
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.all(8),
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post['time'] ?? "", style: GoogleFonts.notoSerifJp(color: Colors.black26, fontSize: 9)),
                Text(
                  post['text'],
                  style: GoogleFonts.notoSerifJp(
                      color: Colors.black87,
                      fontSize: (post['fontSize'] ?? 15.0).toDouble(),
                      fontWeight: (post['isBold'] ?? false) ? FontWeight.bold : FontWeight.normal,
                      height: 1.6
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotebookPainter extends CustomPainter {
  final double height;
  NotebookPainter({required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.blue.withOpacity(0.08)
      ..strokeWidth = 1.0;
    for (double i = 0; i < height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
    final marginPaint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(45, 0), Offset(45, height), marginPaint);
    canvas.drawLine(const Offset(48, 0), Offset(48, height), marginPaint);
  }
  @override
  bool shouldRepaint(CustomPainter old) => false;
}