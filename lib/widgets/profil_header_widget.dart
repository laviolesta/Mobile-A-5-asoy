import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  // Terima data sebagai parameter
  final String nama;
  final String email;
  final String nim;
  final String fakultas;
  final String jurusan;
  final String no_whatsapp;

  // 🟢 TAMBAHAN 1: DEFINISI PROPERTI photoUrl
  final String? photoUrl;

  final VoidCallback onEditWaTap;
  final VoidCallback onEditPhotoTap;

  const ProfileHeaderWidget({
    super.key,
    required this.nama,
    required this.email,
    required this.nim,
    required this.fakultas,
    required this.jurusan,
    required this.no_whatsapp,
    // 🟢 TAMBAHAN 2: TERIMA DI CONSTRUCTOR
    this.photoUrl,
    required this.onEditWaTap,
    required this.onEditPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Foto Profil dan Icon Edit
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              // 🟢 PENGGUNAAN photoUrl untuk gambar jaringan
              CircleAvatar(
                radius: 40,
                // Jika photoUrl ada dan tidak kosong, gunakan NetworkImage
                backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                    ? NetworkImage(photoUrl!) as ImageProvider
                    : const AssetImage('assets/default_avatar.png'), // Ganti dengan path aset default Anda
                // Jika tidak ada photoUrl, tampilkan ikon default
                child: (photoUrl == null || photoUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null, // Jangan tampilkan ikon jika ada gambar
                backgroundColor: Colors.blue, // Warna latar belakang jika ikon default yang tampil
              ),

              GestureDetector(
                onTap: onEditPhotoTap,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.grey),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Nama
          Text(
            nama,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Daftar Detail Profil
          _buildProfileDetail(
            label: "Email Kampus",
            value: email,
            showEdit: false,
          ),
          _buildProfileDetail(
            label: "NIM",
            value: nim,
            showEdit: false,
          ),
          _buildProfileDetail(
            label: "Fakultas",
            value: fakultas,
            showEdit: false,
          ),
          _buildProfileDetail(
            label: "Jurusan",
            value: jurusan,
            showEdit: false,
          ),
          _buildProfileDetail(
            label: "No. WhatsApp",
            value: no_whatsapp,
            showEdit: true,
            onEditTap: onEditWaTap,
          ),
        ],
      ),
    );
  }

  // Widget Baris Detail Profil
  Widget _buildProfileDetail({
    required String label,
    required String value,
    required bool showEdit,
    VoidCallback? onEditTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          if (showEdit)
            SizedBox(
              height: 30,
              child: OutlinedButton(
                onPressed: onEditTap,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                child: const Text(
                  "Edit",
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ),
            ),
        ],
      ),
    );
  }
}