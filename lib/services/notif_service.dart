import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/notif_item.dart';

class NotificationService {
  static Future<List<NotificationItem>> fetchNotifications() async {
    try {
      // Ambil snapshot dari collection 'notifications' di Firestore
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('notifications').get();

      // Konversi snapshot ke list NotificationItem
      List<NotificationItem> notifications = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        data['id'] = doc.id;
        return NotificationItem.fromJson(data);
      }).toList();

      return notifications;
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
}