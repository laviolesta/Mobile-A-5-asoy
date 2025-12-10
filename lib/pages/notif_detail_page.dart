import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notif_item.dart';
import '../services/product_service.dart';
import 'detail_page.dart';

class NotifDetailPage extends StatelessWidget {
  final NotificationItem notification;
  final ProductService _productService = ProductService();

  NotifDetailPage({super.key, required this.notification});

  // Fungsi pembantu untuk memformat DateTime
  String _formatDate(DateTime? date) {
    if (date == null) return "Tanggal tidak tersedia";
    final formatter = DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id');
    return formatter.format(date.toLocal());
  }

  // Fungsi Mengambil data produk dan navigasi ---
  Future<void> _navigateToProductDetail(BuildContext context) async {
    final productId = notification.productId;
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID Produk tidak ditemukan.")),
      );
      return;
    }

    try {
      // Panggil service untuk mengambil data produk lengkap
      final productData = await _productService.getProductById(productId);

      if (productData != null) {
        // Navigasi ke DetailPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              product: productData,
              isOwnerView: true,
              likedProducts: const [],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk tidak ditemukan atau sudah dihapus.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat detail produk: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRentRequest = notification.title.startsWith("Permintaan Sewa Baru");

    return Scaffold(

      appBar: AppBar(
        leading: IconButton( // Tombol Kembali (<-)
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Detail Notifikasi"),

        titleSpacing: 0,

        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Notifikasi
            Text(
              notification.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Status Baca
            Text(
              'Status: ${notification.isRead ? 'Sudah Dibaca' : 'Belum Dibaca'}',
              style: TextStyle(
                color: notification.isRead ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),

            // Waktu Notifikasi Dibuat
            Text(
              'Dibuat: ${_formatDate(notification.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const Divider(height: 32),

            // Deskripsi
            Text(
              notification.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 20),

            // Footer detail teknis
            Text(
              'ID: ${notification.id}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),

            if (isRentRequest && notification.productId != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToProductDetail(context),
                    icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                    label: const Text(
                      "Lihat Produk yang Disewa",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E355D),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}