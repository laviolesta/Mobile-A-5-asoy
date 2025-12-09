import 'package:flutter/material.dart';
import '../widgets/profil_header_widget.dart';
import '../widgets/product_card_widget.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

// HAPUS BARIS DUMMY ID. Kita akan mengambil ID dari Firebase Auth.
// const String USER_ID_DUMMY = 'replace_with_actual_user_id';

class ProfilePage extends StatelessWidget {
  // Hapus 'const' dari constructor (sudah benar)
  ProfilePage({super.key});

  // Inisialisasi Service
  final UserService _userService = UserService();

  // Data dummy untuk produk yang disukai (tetap hardcoded untuk saat ini)
  final List<Map<String, dynamic>> likedProducts = const [
    {
      'name': 'Baju Putih',
      'price': 'Rp3.000/hari',
      'location': 'Gowa, Jl.Kelapa',
      'rating': 4.5,
      'reviews': 8,
      'likes': 6,
    },
    {
      'name': 'Jas Hitam',
      'price': 'Rp4.000/hari',
      'location': 'Gowa, Jl. Kelapa',
      'rating': 4.5,
      'reviews': 8,
      'likes': 7,
    },
  ];

  // Fungsi yang akan dijalankan saat tombol edit No WA diklik
  void _onEditWaPressed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fungsi Edit No. WhatsApp akan ditambahkan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan UID pengguna yang sedang login
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cek apakah user sudah login
            if (currentUserId == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Anda belum login atau sesi telah berakhir.',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
              )
            else
            // Menggunakan StreamBuilder untuk mendengarkan perubahan data user secara real-time
              StreamBuilder<UserModel>(
                stream: _userService.streamUser(currentUserId), // Menggunakan UID yang sebenarnya
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('Error: Gagal memuat data profil. ${snapshot.error}'),
                    ));
                  }

                  if (snapshot.hasData) {
                    final UserModel user = snapshot.data!;

                    return ProfileHeaderWidget(
                      nama: user.nama_lengkap,
                      email: user.email, // Asumsi nama field sudah disesuaikan
                      nim: user.nim,
                      fakultas: user.fakultas,
                      jurusan: user.jurusan,
                      no_whatsapp: user.no_whatsapp,
                      onEditWaTap: () => _onEditWaPressed(context),
                    );
                  }

                  // Kondisi jika dokumen tidak ditemukan di Firestore
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('Data profil tidak ditemukan. Pastikan data ada di koleksi "users".'),
                  ));
                },
              ),

            const Divider(height: 1, thickness: 1, color: Colors.grey),

            // Bagian Produk yang Disukai
            _buildLikedProductsSection(context),
          ],
        ),
      ),
    );
  }

  // Pindahkan logika section produk ke dalam method agar build method lebih rapi
  Widget _buildLikedProductsSection(BuildContext context) {
    // ... (Logika widget ini tidak berubah, hanya dipanggil)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 24.0, left: 16.0, bottom: 8.0),
          child: Text(
            "Produk yang disukai",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 30,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fungsi Edit Produk Disukai akan ditambahkan.')),
                    );
                  },
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
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: likedProducts.length,
            itemBuilder: (context, index) {
              return ProductCardWidget(product: likedProducts[index]);
            },
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}