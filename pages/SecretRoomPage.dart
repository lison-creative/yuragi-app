import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../main.dart';

class SecretRoomPage extends StatefulWidget {
  const SecretRoomPage({super.key});

  @override
  State<SecretRoomPage> createState() => _SecretRoomPageState();
}

class _SecretRoomPageState extends State<SecretRoomPage> {
  bool _isUnlocked = false;
  List<Map<String, String>> _letters = [];

  @override
  void initState() {
    super.initState();
    _loadLetters();
  }

  // [修正] SecondPage の _saveToSecretRoom と完全に同期するロジック
  Future<void> _loadLetters() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('secret_letters') ?? [];

    setState(() {
      _letters = history.map((item) {
        try {
          // SecondPage は json.encode({"date": ..., "content": ...}) で保存している
          final Map<String, dynamic> decoded = json.decode(item);
          return {
            "date": decoded['date']?.toString() ?? "不明な刻",
            "text": (decoded['content'] ?? decoded['text'] ?? "無題の便り").toString(),
          };
        } catch (e) {
          // JSONでない古い形式やエラー時のフォールバック
          return {
            "date": "過去の記憶",
            "text": item.toString()
          };
        }
      }).toList();
      // SecondPage側で history.insert(0, ...) しているので、
      // ここですでに新しい順になっています。さらに reversed をかける必要はありません。
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "愛し貴方へ",
                  style: GoogleFonts.notoSerifJp(
                    color: const Color(0xFFD4AF37),
                    fontSize: 22,
                    letterSpacing: 8,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 40),
                const Icon(Icons.auto_awesome, color: Color(0xFF3D3222), size: 30),
                const SizedBox(height: 30),
                Text(
                  "ここは誰かの心の終点、\n先に進みますか？",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerifJp(
                    color: const Color(0xFFD4AF37).withOpacity(0.7),
                    fontSize: 16,
                    letterSpacing: 2,
                    height: 2.0,
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                    onPressed: () {
                      _loadLetters(); // 入室時に最新の手紙を読み込む
                      setState(() => _isUnlocked = true);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
                      backgroundColor: const Color(0xFF1A150E),
                    ),
                    child: Text(
                      "静かに進む",
                      style: GoogleFonts.notoSerifJp(
                        color: const Color(0xFFD4AF37),
                        fontSize: 16,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: TextButton(
                    onPressed: () {
                      MainNavigation.of(context)?.changePage(1);
                    },
                    child: Text(
                      "引き返す",
                      style: GoogleFonts.notoSerifJp(
                        color: Colors.white24,
                        fontSize: 14,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: SecretGridPainter())),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _isUnlocked = false);
                          MainNavigation.of(context)?.changePage(1);
                        },
                        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD4AF37), size: 16),
                        label: Text("BACK", style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), letterSpacing: 2)),
                      ),
                      const Spacer(),
                      Text("SECRET ARCHIVE", style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), fontSize: 16, letterSpacing: 4)),
                      const Spacer(),
                      const SizedBox(width: 80),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF3D3222), indent: 20, endIndent: 20, height: 20),
                Expanded(
                  child: _letters.isEmpty
                      ? Center(child: Text("まだ何も綴られていません", style: GoogleFonts.notoSerifJp(color: Colors.white24)))
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _letters.length,
                    itemBuilder: (context, index) => _buildArchiveCard(_letters[index]['date']!, _letters[index]['text']!),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveCard(String date, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: const Color(0xFF3D3222), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            color: const Color(0xFF1A150E),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), fontSize: 11)),
                const Icon(Icons.bookmark_outline, color: Color(0xFF3D3222), size: 12),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(text, style: GoogleFonts.notoSerifJp(color: Colors.white70, fontSize: 14, height: 1.6)),
          ),
        ],
      ),
    );
  }
}

class SecretGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.05)
      ..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}