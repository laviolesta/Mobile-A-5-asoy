import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notif_item.dart';
import '../services/product_service.dart';
import 'detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notif_service.dart';

// 1. UBAH DARI StatelessWidget KE StatefulWidget
class NotifDetailPage extends StatefulWidget {
  final NotificationItem notification;

  // Hapus const dari konstruktor
  NotifDetailPage({super.key, required this.notification});

  @override
  State<NotifDetailPage> createState() => _NotifDetailPageState();
}

// 2. BUAT STATE CLASS BARU
class _NotifDetailPageState extends State<NotifDetailPage> {
  final ProductService _productService = ProductService();
  bool _isConfirming = false; // State untuk loading tombol

  // Fungsi pembantu untuk memformat DateTime (Sama)
  String _formatDate(DateTime? date) {
    if (date == null) return "Tanggal tidak tersedia";
    final formatter = DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id');
    return formatter.format(date.toLocal()); 
  }

  // 3. LOGIKA NAVIGASI (Dipindahkan ke State)
  Future<void> _navigateToProductDetail() async {
    final productId = widget.notification.productId;
    if (productId == null) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID Produk tidak ditemukan.")),
      );
      return;
    }

    try {
      final productData = await _productService.getProductById(productId);

      if (productData != null && mounted) {
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
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk tidak ditemukan atau sudah dihapus.")),
        );
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat detail produk: $e")),
      );
    }
  }

  // 4. LOGIKA KONFIRMASI PENGEMBALIAN BARU (Di dalam State)
  Future<void> _handleConfirmReturn(String rentalId, String productId) async {
    final currentOwnerId = FirebaseAuth.instance.currentUser?.uid;
    if (currentOwnerId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Anda harus login untuk mengkonfirmasi.")));
      return;
    }
    
    setState(() => _isConfirming = true);

    final result = await _productService.confirmReturn(rentalId, productId, currentOwnerId);
    
    setState(() => _isConfirming = false);
    
    if (result == null) {
      // Hapus notifikasi dari list/firestore (opsional)
      try {
        await NotificationService.deleteNotification(widget.notification.id);
      } catch (e) {
        print("Gagal menghapus notifikasi setelah konfirmasi: $e");
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Konfirmasi pengembalian berhasil!"), 
            backgroundColor: Colors.green
        ));
        
        // Refresh halaman notifikasi sebelumnya, lalu kembali ke halaman utama
        Navigator.pop(context); // Kembali dari halaman detail
      }

    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result), 
          backgroundColor: Colors.red
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan jenis notifikasi
    final notification = widget.notification; // Akses notification melalui widget
    final bool isReturnNotification = notification.title.startsWith("Item ") && notification.title.endsWith("Telah Dikembalikan.");
        
    // Ambil data penting
    final String? productId = notification.productId;
    final String? rentalId = notification.rentalId; 
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
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

            if (productId != null)
               Padding(
                 padding: const EdgeInsets.only(top: 10.0, bottom: 20),
                 child: SizedBox(
                   width: double.infinity,
                   child: OutlinedButton.icon(
                     onPressed: _navigateToProductDetail, // Panggil fungsi di State
                     icon: const Icon(Icons.shopping_bag_outlined),
                     label: const Text(
                       "Lihat Detail Produk",
                       style: TextStyle(fontSize: 16),
                     ),
                     style: OutlinedButton.styleFrom(
                       foregroundColor: const Color(0xFF1E355D),
                       side: const BorderSide(color: Color(0xFF1E355D)),
                       padding: const EdgeInsets.symmetric(vertical: 15),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                     ),
                   ),
                 ),
               ),

            if (isReturnNotification && productId != null && rentalId != null) 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isConfirming ? null : () => _handleConfirmReturn(rentalId, productId),
                    icon: _isConfirming 
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: Text(
                      _isConfirming ? "Memproses..." : "Konfirmasi Barang Sudah Diterima",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
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