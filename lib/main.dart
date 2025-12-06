import 'package:flutter/material.dart';
import 'welcome_page.dart';

void main() {
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
      home: const WelcomePage(), // Menambahkan const agar lebih efisien
    );
  }
}