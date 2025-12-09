import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // <--- INI WAJIB ADA
import 'notif_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 4. Wajib ada
  
  // 5. Inisialisasi Firebase sesuai konfigurasi otomatis tadi
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan pita 'DEBUG' di pojok kanan atas
      title: 'SewaMi',
      theme: ThemeData(
        // Menggunakan warna Biru SewaMi (1E355D) sebagai warna dasar tema
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E355D)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const NotifikasiPage(), // Menambahkan const agar lebih efisien
    );
  }
}