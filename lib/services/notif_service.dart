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
        // doc.data() adalah Map<String, dynamic>
        return NotificationItem.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return notifications;
    } catch (e) {
      throw Exception("Failed to load notifications: $e");
    }
  }
}