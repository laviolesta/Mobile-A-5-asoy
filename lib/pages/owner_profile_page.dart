import 'package:flutter/material.dart';

class OwnerProfilePage extends StatelessWidget {
  const OwnerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Pemilik")),
      body: const Center(
        child: Text("Halaman Profil Pemilik"),
      ),
    );
  }
}
