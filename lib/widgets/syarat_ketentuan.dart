import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsModal extends StatelessWidget {
  const TermsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Tinggi 85% layar
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // --- HEADER ---
          const SizedBox(height: 15),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Syarat & Ketentuan",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E355D),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 1),

          // --- ISI KONTEN (Scrollable) ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection("1. Lingkup Pengguna", 
                    "Aplikasi SewaMi ditujukan eksklusif untuk mahasiswa aktif Universitas Hasanuddin (Unhas). Pengguna wajib memiliki email kampus yang valid sebagai verifikasi saat pendaftaran."
                  ),
                  _buildSection("2. Keamanan Transaksi", 
                    "• Dilarang menyewakan barang ilegal (narkoba, sajam) atau yang melanggar aturan akademik Unhas.\n"
                    "• Disarankan melakukan COD (Cash On Delivery) di area kampus yang ramai (contoh: Pelataran MKU, Gedung Perkuliahan, atau area Ramsis/Kantin)."
                  ),
                  _buildSection("3. Tanggung Jawab Penyewa", 
                    "• Barang harus dikembalikan sesuai kondisi awal.\n"
                    "• Jika terjadi kerusakan atau kehilangan, penyewa WAJIB mengganti rugi sesuai kesepakatan dengan pemilik barang (Service atau Ganti Baru)."
                  ),
                  _buildSection("4. Denda Keterlambatan", 
                    "Keterlambatan pengembalian barang akan dikenakan denda harian yang disepakati dengan pemberi sewa."
                  ),
                  _buildSection("5. Sanksi Pelanggaran", 
                    "Penipuan atau pencurian akan dilaporkan ke pihak berwajib dan Komisi Disiplin Fakultas masing-masing."
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // --- TOMBOL SAYA SETUJU (Hijau) ---
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60), // Hijau
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context), // Tutup Modal
                child: Text(
                  "Saya Setuju",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 5),
          Text(content, style: GoogleFonts.inter(fontSize: 14, color: Colors.black54, height: 1.5), textAlign: TextAlign.justify),
        ],
      ),
    );
  }
}