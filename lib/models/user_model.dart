import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // Field data yang sesuai dengan requirement profil
  final String id; // ID dokumen Firebase (atau UID user)
  final String nama;
  final String email;
  final String nim;
  final String fakultas;
  final String jurusan;
  final String no_whatsapp;
  // Anda bisa tambahkan field lain seperti List<String> likedProductIds;

  const UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.nim,
    required this.fakultas,
    required this.jurusan,
    required this.no_whatsapp,
  });

  // --- 1. Factory Constructor untuk konversi dari JSON/Map (dari Firebase) ---
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    // Lakukan pengecekan null dan penanganan tipe data yang aman
    return UserModel(
      id: doc.id,
      nama: data?['nama'] as String? ?? 'N/A',
      email: data?['email'] as String? ?? 'N/A',
      nim: data?['nim'] as String? ?? 'N/A',
      fakultas: data?['fakultas'] as String? ?? 'N/A',
      jurusan: data?['jurusan'] as String? ?? 'N/A',
      no_whatsapp: data?['no_whatsapp'] as String? ?? 'N/A',
    );
  }

  // --- 2. Method untuk konversi ke Map/JSON (untuk disimpan ke Firebase) ---
  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'email': email,
      'nim': nim,
      'fakultas': fakultas,
      'jurusan': jurusan,
      'no_whatsapp': no_whatsapp,
    };
  }
}