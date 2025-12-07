import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart'; // Import Backend

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controller untuk menangkap teks input
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _fakultasController = TextEditingController();
  final TextEditingController _jurusanController = TextEditingController();
  final TextEditingController _waController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false; // Untuk loading spinner

  // Fungsi saat tombol Daftar ditekan
  void _handleSignUp() async {
    // 1. Validasi Input Kosong
    if (_namaController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Semua kolom harus diisi!")));
      return;
    }

    // 2. Validasi Password Cocok
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password tidak sama!")));
      return;
    }

    setState(() => _isLoading = true); // Mulai Loading

    // 3. Panggil Backend
    String? result = await AuthService().signUp(
      email: _emailController.text,
      password: _passwordController.text,
      nama: _namaController.text,
      nim: _nimController.text,
      fakultas: _fakultasController.text,
      jurusan: _jurusanController.text,
      noWhatsapp: _waController.text,
    );

    setState(() => _isLoading = false); // Stop Loading

    // 4. Cek Hasil
    if (result == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registrasi Berhasil! Silakan Login."), backgroundColor: Colors.green));
      Navigator.pop(context); // Kembali ke halaman sebelumnya
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chevron_left, size: 24, color: colorTitle),
                  const SizedBox(width: 5),
                  Text("Kembali", style: TextStyle(color: colorTitle, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Text("Daftar Akun", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.bold, color: colorTitle)),
                      const SizedBox(height: 40),
                      
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              _buildFloatingLabelInput("Nama Lengkap", _namaController),
                              const SizedBox(height: 20),
                              _buildFloatingLabelInput("Email Kampus", _emailController, keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 20),
                              _buildFloatingLabelInput("NIM", _nimController, keyboardType: TextInputType.number),
                              const SizedBox(height: 20),
                              _buildFloatingLabelInput("Fakultas", _fakultasController),
                              const SizedBox(height: 20),
                              _buildFloatingLabelInput("Jurusan", _jurusanController),
                              const SizedBox(height: 20),
                              _buildFloatingLabelInput("No. WhatsApp", _waController, keyboardType: TextInputType.phone),
                              const SizedBox(height: 20),
                              _buildFloatingLabelInput("Password", _passwordController, isPassword: true),
                              const SizedBox(height: 20),
                              _buildFloatingLabelInput("Konfirmasi Password", _confirmPasswordController, isPassword: true),
                              const SizedBox(height: 40),
                              
                              // TOMBOL DAFTAR dengan Loading
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  onPressed: _isLoading ? null : _handleSignUp, // Disable jika loading
                                  child: _isLoading 
                                    ? const CircularProgressIndicator(color: Colors.white) 
                                    : Text("Daftar", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                              ),
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

  Widget _buildFloatingLabelInput(String label, TextEditingController controller, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller, // HUBUNGKAN CONTROLLER DI SINI
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.grey[600]),
        floatingLabelStyle: GoogleFonts.inter(color: const Color(0xFF1E355D), fontWeight: FontWeight.bold),
        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[400]!, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E355D), width: 2)),
        filled: true,
        fillColor: Colors.white,
      ),
      style: GoogleFonts.inter(fontSize: 16),
    );
  }
}