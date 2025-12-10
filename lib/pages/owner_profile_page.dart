import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../widgets/profil_header_widget.dart';
import '../widgets/product_card_widget.dart';
import '../services/product_service.dart';

class OwnerProfilePage extends StatefulWidget {
  final String ownerId;

  const OwnerProfilePage({super.key, required this.ownerId});

  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  final UserService _userService = UserService();
  final ProductService _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profil Pemilik",
          style: TextStyle(color: Colors.black),
        ),
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
            /// ==========================
            /// STREAM USER OWNER
            /// ==========================
            StreamBuilder<UserModel>(
              stream: _userService.streamUser(widget.ownerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        "Profil pemilik tidak ditemukan.",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }

                final user = snapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ==========================
                    /// HEADER PROFIL (READONLY)
                    /// ==========================
                    ProfileHeaderWidget(
                      nama: user.nama_lengkap,
                      email: user.email,
                      nim: user.nim,
                      fakultas: user.fakultas,
                      jurusan: user.jurusan,
                      no_whatsapp: user.no_whatsapp,
                      photoUrl: user.photoUrl,

                      // supaya tombol edit HILANG (kirim null) dan mode owner view aktif
                      onEditWaTap: null,
                      onEditPhotoTap: null,
                      isOwnerView: true,
                    ),

                    const Divider(height: 1, thickness: 1, color: Colors.grey),

                    /// ==========================
                    /// PRODUK YANG DISEWAKAN
                    /// ==========================
                    _buildOwnedProductsSection(),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// =========================================================
  /// SECTION: PRODUK YANG DISEWAKAN (Tidak ada edit, delete)
  /// =========================================================
  Widget _buildOwnedProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 24.0, left: 16.0, bottom: 8.0),
          child: Text(
            "Produk yang Disewakan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        SizedBox(
          height: 250,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _productService.streamProductsByOwner(widget.ownerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = snapshot.data ?? [];

              if (products.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Pemilik belum menyewakan produk apa pun.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return ProductCardWidget(product: product);
                },
              );
            },
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}