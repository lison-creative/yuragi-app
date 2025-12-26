import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  final String shopUrl = "https://lison.base.shop/"; // ここを後で変える

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("WEB SHOP", style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), fontSize: 24)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse(shopUrl);
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              child: const Text("GO TO STORE"),
            ),
          ],
        ),
      ),
    );
  }
}