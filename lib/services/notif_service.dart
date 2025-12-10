import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notif_item.dart';

class NotificationService {
  // Batas notifikasi per halaman
  static const int _limit = 5;

  static Future<void> markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception("Failed to mark notification as read: $e");
    }
  }

  // --- MODIFIKASI: TAMBAH PARAMETER userId UNTUK FILTERING ---
  static Future<Map<String, dynamic>> fetchPaginatedNotifications(
      String currentUserId, // <--- BARU: User ID pengguna yang sedang login
      DocumentSnapshot? lastDocument) async {
    
    // 1. Definisikan Query dasar dengan filter userId
    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId) // <--- FILTER KRITIS
        .orderBy('createdAt', descending: true)
        .limit(_limit);

    // 2. Terapkan pagination jika ada dokumen terakhir
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    try {
      QuerySnapshot snapshot = await query.get();

      List<NotificationItem> notifications = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NotificationItem.fromJson(data);
      }).toList();

      // Dapatkan dokumen terakhir di halaman ini
      DocumentSnapshot? newLastDocument = snapshot.docs.isNotEmpty
          ? snapshot.docs.last
          : lastDocument;

      // Kembalikan data dan dokumen terakhir
      return {
        'notifications': notifications,
        'lastDocument': newLastDocument,
        'hasMore': snapshot.docs.length == _limit,
      };

    } catch (e) {
      throw Exception("Failed to load notifications: $e");
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .delete();
      print("Notifikasi dengan ID $notificationId berhasil dihapus.");
    } catch (e) {
      throw Exception("Failed to delete notification: $e");
    }
  }
  
  // --- FUNGSI CREATE NOTIFIKASI ---
  static Future<void> createNotification({
    required String title,
    required String description,
    required String userId, // Target user
    String? productId,
    String? rentalId,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': title,
        'description': description,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'productId': productId,
        'rentalId': rentalId,
      });
    } catch (e) {
      throw Exception("Failed to create notification: $e");
    }
  }
}