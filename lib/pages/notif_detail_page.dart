import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notif_item.dart';

class NotifDetailPage extends StatelessWidget {
  final NotificationItem notification;

  const NotifDetailPage({super.key, required this.notification});

  // Fungsi pembantu untuk memformat DateTime
  String _formatDate(DateTime? date) {
    if (date == null) {
      return "Tanggal tidak tersedia";
    }
    // Format tanggal dan waktu ke bahasa Indonesia
    final formatter = DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id');
    return formatter.format(date.toLocal()); // Gunakan .toLocal() jika tanggal disimpan di UTC
  }

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}