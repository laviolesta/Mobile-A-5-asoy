import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color colorTitle = Color(0xFF1E355D);
    const Color colorLink = Color(0xFF2F98BB); // Biru terang untuk link

    return Scaffold(
      // resizeToAvoidBottomInset: false, // Aktifkan jika ingin bg diam saat keyboard muncul
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. BAGAN PUTIH (CENTER)
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30), // Rounded corner
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Agar tinggi menyesuaikan isi
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Isi melebar
                  children: [
                    // JUDUL: Selamat Datang! (2 Baris, Size 64, Bold, Rata Kiri)
                    Text(
                      "Selamat\nDatang!",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                        fontSize: 64, // Ukuran Besar
                        fontWeight: FontWeight.bold,
                        color: colorTitle,
                        height: 1.0, // Rapatkan jarak antar baris
                      ),
                    ),
                    
                    const SizedBox(height: 40),

                    // INPUT: Email Kampus
                    _buildFloatingLabelInput("Email Kampus"),
                    const SizedBox(height: 20),
                    
                    // INPUT: Password
                    _buildFloatingLabelInput("Password", isPassword: true),
                    
                    const SizedBox(height: 10),

                    // LUPA SANDI (Biru Terang, Underline)
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          // Navigasi ke Lupa Sandi nanti
                        },
                        child: Text(
                          "Lupa Sandi",
                          style: GoogleFonts.inter(
                            color: colorLink,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline, // Garis bawah
                            decorationColor: colorLink,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // TOMBOL MASUK (Hitam, Teks Putih, Tidak Bold)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Bagan Hitam
                          foregroundColor: Colors.white, // Teks Putih
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          // Logika Login
                        },
                        child: Text(
                          "Masuk",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.normal, // TIDAK BOLD
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. TOMBOL KEMBALI (Di Atas Kiri)
          Positioned(
            top: 50, // Jarak dari atas (SafeArea manual)
            left: 20,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2), // Abu2 Transparan
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.black87),
                    const SizedBox(width: 8),
                    Text(
                      "Kembali",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper Input (Sama persis dengan Signup)
  Widget _buildFloatingLabelInput(String label, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.grey[600]),
        floatingLabelStyle: GoogleFonts.inter(color: const Color(0xFF1E355D), fontWeight: FontWeight.bold),
        
        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
        ),
        
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E355D), width: 2),
        ),
        
        filled: true,
        fillColor: Colors.white,
      ),
      style: GoogleFonts.inter(fontSize: 16),
    );
  }
}