import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text("VIDEO GALLERY", style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), fontSize: 24)),
      ),
    );
  }
}