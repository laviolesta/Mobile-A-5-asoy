import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart'; // Wajib untuk TapGestureRecognizer
import 'signin_page.dart';
import 'signup_page.dart';
import '../widgets/syarat_ketentuan.dart'; // Import file modal yang baru dibuat

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    const Color colorSewa = Color(0xFF1E355D);
    const Color colorMi = Color(0xFF2F98BB);

    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_welcome.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. KONTEN
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: screenHeight * 0.42),

                  // BAGIAN 1: Teks SewaMi
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 75,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              const Shadow(
                                offset: Offset(3, 3),
                                blurRadius: 10.0,
                                color: Colors.black12,
                              ),
                            ],
                          ),
                          children: const [
                            TextSpan(text: 'Sewa', style: TextStyle(color: colorSewa)),
                            TextSpan(text: 'Mi', style: TextStyle(color: colorMi)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Sewa dan sewakan\nbarang kamu kapanpun",
                        textAlign: TextAlign.right,
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // BAGIAN 2: Tombol
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage()));
                      },
                      child: Text('Daftar Sekarang', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.normal)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SigninPage()));
                      },
                      child: Text('Sudah Punya Akun', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.normal)),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // BAGIAN 3: Footer (DENGAN FUNGSI KLIK)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.inter(color: Colors.black87, fontSize: 12),
                        children: [
                          const TextSpan(text: 'Dengan '),
                          const TextSpan(text: 'mendaftar', style: TextStyle(fontWeight: FontWeight.w900)),
                          const TextSpan(text: ' atau '),
                          const TextSpan(text: 'masuk', style: TextStyle(fontWeight: FontWeight.w900)),
                          const TextSpan(text: ', Anda menyetujui\n'),
                          
                          // --- TEKS INI BISA DIKLIK ---
                          TextSpan(
                            text: 'Syarat dan Ketentuan',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E355D), // Biru tua
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Tampilkan Modal
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true, // Agar modal tinggi
                                  backgroundColor: Colors.transparent, // Transparan agar sudut rounded terlihat
                                  builder: (context) => const TermsModal(),
                                );
                              },
                          ),
                          // ---------------------------
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}