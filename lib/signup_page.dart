import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna Biru Utama (Sesuai palet sebelumnya)
    const Color colorTitle = Color(0xFF1E355D);

    return Scaffold(
      // resizeToAvoidBottomInset: false, // Aktifkan ini jika ingin background diam saat keyboard muncul
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE (Full Screen)
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png', // Pastikan file ini ada
              fit: BoxFit.cover,
            ),
          ),

          // 2. BAGAN PUTIH (Floating Card)
          Positioned.fill(
            child: SafeArea(
              child: Container(
                // Margin mengatur jarak bagan dari tepi layar
                // Top: 20 (sedikit jarak dari atas)
                // Bottom: 80 (Gap agak besar di bawah sesuai request)
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30), // Rounded corner bagan
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // A. TOMBOL KEMBALI
                      // Jenis Inter, Ukuran 13, Rounded, Transparan Abu2
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2), // Abu2 Transparan
                            borderRadius: BorderRadius.circular(20), // Agak rounded
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Agar lebar menyesuaikan isi
                            children: [
                              const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.black87),
                              const SizedBox(width: 8),
                              Text(
                                "Kembali",
                                style: GoogleFonts.inter( // Font Inter
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // B. JUDUL DAFTAR AKUN (Scrollable jika layar pendek)
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Judul Center, Bold, Ukuran 40
                              Text(
                                "Daftar Akun",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: colorTitle,
                                ),
                              ),
                              
                              const SizedBox(height: 40),

                              // C. KOLOM INPUT DATA
                              // Nama kolom menyatu dengan garis (menggunakan labelText)
                              _buildFloatingLabelInput("Nama Lengkap"),
                              const SizedBox(height: 20),
                              _buildFloatingLabelInput("Email Kampus", keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 20),
                              _buildFloatingLabelInput("NIM", keyboardType: TextInputType.number),
                              const SizedBox(height: 20),
                              _buildFloatingLabelInput("Fakultas"),
                              const SizedBox(height: 20),
                              _buildFloatingLabelInput("Jurusan"),
                              const SizedBox(height: 20),
                              _buildFloatingLabelInput("No. WhatsApp", keyboardType: TextInputType.phone),
                              const SizedBox(height: 20),
                              _buildFloatingLabelInput("Password", isPassword: true),
                              const SizedBox(height: 20),
                              _buildFloatingLabelInput("Konfirmasi Password", isPassword: true),
                              
                              const SizedBox(height: 40),

                              // D. TOMBOL DAFTAR
                              // Center, Tulisan Putih, Bagan Hitam
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
                                    // Logika Daftar
                                  },
                                  child: Text(
                                    "Daftar",
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Spasi tambahan di bawah agar tidak mentok
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Input dengan Label menyatu di garis (Floating Label)
  Widget _buildFloatingLabelInput(String label, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label, // INI KUNCINYA: labelText akan "mengapung" ke garis saat diklik
        labelStyle: GoogleFonts.inter(color: Colors.grey[600]),
        floatingLabelStyle: GoogleFonts.inter(color: const Color(0xFF1E355D), fontWeight: FontWeight.bold),
        
        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        
        // Garis saat tidak diklik
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // "Tidak terlalu rounded tapi masih rounded"
          borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
        ),
        
        // Garis saat diklik/fokus
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E355D), width: 2),
        ),
        
        // Background putih (opsional, agar garis di belakang teks tertutup rapi)
        filled: true,
        fillColor: Colors.white,
      ),
      style: GoogleFonts.inter(fontSize: 16),
    );
  }
}