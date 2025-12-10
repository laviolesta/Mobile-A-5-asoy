import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String nama_lengkap;
  final String email;
  final String nim;
  final String fakultas;
  final String jurusan;
  final String no_whatsapp;

  final String? photoUrl; // URL Foto Profil dari Cloudinary
  final List<String>? liked_products; // Daftar ID Produk yang Disukai

  const UserModel({
    required this.id,
    required this.nama_lengkap,
    required this.email,
    required this.nim,
    required this.fakultas,
    required this.jurusan,
    required this.no_whatsapp,
    this.photoUrl,
    this.liked_products,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return UserModel(
      id: doc.id,
      nama_lengkap: data?['nama_lengkap'] as String? ?? 'N/A',
      email: data?['email'] as String? ?? 'N/A',
      nim: data?['nim'] as String? ?? 'N/A',
      fakultas: data?['fakultas'] as String? ?? 'N/A',
      jurusan: data?['jurusan'] as String? ?? 'N/A',
      no_whatsapp: data?['no_whatsapp'] as String? ?? 'N/A',

      photoUrl: data?['photoUrl'] as String?,
      liked_products: (data?['liked_products'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': id,
      'nama_lengkap': nama_lengkap,
      'email': email,
      'nim': nim,
      'fakultas': fakultas,
      'jurusan': jurusan,
      'no_whatsapp': no_whatsapp,

      if (photoUrl != null) 'photoUrl': photoUrl,
      if (liked_products != null) 'liked_products': liked_products,

      'created_at': FieldValue.serverTimestamp(),
    };
  }
}