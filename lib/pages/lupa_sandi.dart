import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void _handleResetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Masukkan email Anda!")));
      return;
    }

    setState(() => _isLoading = true);

    // Panggil fungsi reset di backend
    String? result = await AuthService().resetPassword(email: _emailController.text);

    setState(() => _isLoading = false);

    if (result == null) {
      if (!mounted) return;
      // Tampilkan pesan sukses
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Email Terkirim"),
          content: const Text("Silakan cek email Anda (termasuk folder Spam) untuk mereset kata sandi."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup Dialog
                Navigator.pop(context); // Kembali ke Halaman Login
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color colorTitle = Color(0xFF1E355D);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chevron_left, size: 24, color: colorTitle),
                  SizedBox(width: 5),
                  Text("Kembali", style: TextStyle(color: colorTitle, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png', // Pakai background yang sama
              fit: BoxFit.cover,
            ),
          ),

          // KONTEN BAGAN
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Lupa\nSandi?",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                        color: colorTitle,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Masukkan email yang terdaftar. Kami akan mengirimkan link untuk mereset kata sandi Anda.",
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 30),

                    // INPUT EMAIL
                    _buildFloatingLabelInput("Email Kampus", _emailController),
                    
                    const SizedBox(height: 30),

                    // TOMBOL KIRIM
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
                          elevation: 2,
                        ),
                        onPressed: _isLoading ? null : _handleResetPassword,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Kirim Link Reset",
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
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

  // Widget Helper Input (Sama dengan sebelumnya)
  Widget _buildFloatingLabelInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
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