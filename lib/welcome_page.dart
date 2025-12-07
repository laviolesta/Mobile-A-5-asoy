import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signin_page.dart';
import 'signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil tinggi layar
    final double screenHeight = MediaQuery.of(context).size.height;

    // Definisi Warna
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
                  
                  // Mengatur jarak dari atas sebesar 42% (Agak turun dari sebelumnya)
                  SizedBox(height: screenHeight * 0.42),

                  // BAGIAN 1: Teks SewaMi & Tagline
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end, // Rata Kanan
                    children: [
                      // Judul: SewaMi
                      RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 75, 
                            fontWeight: FontWeight.bold,
                            shadows: [
                              const Shadow(
                                offset: Offset(3, 3), // Arah bayangan
                                blurRadius: 10.0,     // Tingkat blur (samar)
                                color: Colors.black12, // Warna transparan gelap
                              ),
                            ],
                          ),
                          children: const [
                            TextSpan(
                              text: 'Sewa',
                              style: TextStyle(color: colorSewa),
                            ),
                            TextSpan(
                              text: 'Mi',
                              style: TextStyle(color: colorMi),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 5),

                      // Tagline
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

                  // Spacer mendorong elemen berikutnya ke bawah
                  const Spacer(), 

                  // BAGIAN 2: Tombol-Tombol
                  // Tombol 1: Daftar Sekarang (Hitam)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupPage()),
                        );
                      },
                      child: Text(
                        'Daftar Sekarang',
                        style: GoogleFonts.inter(
                          fontSize: 18, 
                          fontWeight: FontWeight.normal, // JANGAN BOLD
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Tombol 2: Sudah Punya Akun (Putih)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SigninPage()),
                        );
                      },
                      child: Text(
                        'Sudah Punya Akun',
                        style: GoogleFonts.inter(
                          fontSize: 18, 
                          fontWeight: FontWeight.normal, // JANGAN BOLD
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // BAGIAN 3: Footer (Syarat dan Ketentuan)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          color: Colors.black87, 
                          fontSize: 12,
                        ),
                        children: const [
                          TextSpan(text: 'Dengan '),
                          TextSpan(
                            text: 'mendaftar',
                            style: TextStyle(fontWeight: FontWeight.w900), // LEBIH BOLD
                          ),
                          TextSpan(text: ' atau '),
                          TextSpan(
                            text: 'masuk',
                            style: TextStyle(fontWeight: FontWeight.w900), // LEBIH BOLD
                          ),
                          TextSpan(text: ', Anda menyetujui\n'),
                          TextSpan(
                            text: 'Syarat dan Ketentuan',
                            style: TextStyle(fontWeight: FontWeight.w900), // LEBIH BOLD
                          ),
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