import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String nama;
  final String email;
  final String nim;
  final String fakultas;
  final String jurusan;
  final String no_whatsapp;
  final String? photoUrl;

  final VoidCallback? onEditWaTap;
  final VoidCallback? onEditPhotoTap;

  final bool isOwnerView;

  const ProfileHeaderWidget({
    super.key,
    required this.nama,
    required this.email,
    required this.nim,
    required this.fakultas,
    required this.jurusan,
    required this.no_whatsapp,
    this.photoUrl,
    this.onEditWaTap,
    this.onEditPhotoTap,
    this.isOwnerView = false,
  });

  @override
  Widget build(BuildContext context) {
    final hideAllEditButtons = isOwnerView; // <— ini kunci utamanya

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // <— bikin semua rata kiri
        children: [
          // Foto profil + tombol edit
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                    ? NetworkImage(photoUrl!)
                    : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
              ),

              // Tombol edit foto — hilang kalau hideAllEditButtons = true
              if (!hideAllEditButtons)
                GestureDetector(
                  onTap: onEditPhotoTap,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 16),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            nama,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          _detail("Email Kampus", email),
          _detail("NIM", nim),
          _detail("Fakultas", fakultas),
          _detail("Jurusan", jurusan),

          // WhatsApp — tombol edit disabled kalau owner
          _detailWithEdit(
            label: "No. WhatsApp",
            value: no_whatsapp,
            showEdit: !hideAllEditButtons && onEditWaTap != null,
            onTap: onEditWaTap,
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _detailWithEdit({
    required String label,
    required String value,
    required bool showEdit,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: _detail(label, value)),
          if (showEdit)
            OutlinedButton(onPressed: onTap, child: const Text("Edit")),
        ],
      ),
    );
  }
}
