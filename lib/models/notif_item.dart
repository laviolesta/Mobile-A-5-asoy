import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final bool isRead;
  final DateTime? createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    // Fungsi pembantu untuk mengkonversi Timestamp/String menjadi DateTime
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      // Asumsi Firestore menggunakan Timestamp
      if (value is Timestamp) {
        return value.toDate();
      }
      if (value is String) {
      return DateTime.tryParse(value); 
    }
    return null;
  }

    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isRead: json.containsKey('isRead') ? json['isRead'] as bool : false,
      // BARU: Parsing createdAt dari Timestamp Firestore
      createdAt: parseDateTime(json['createdAt']), 
    );
  }

  // --- METHOD BARU: copyWith ---
  // Digunakan untuk membuat salinan objek dengan hanya mengubah field yang diperlukan.
  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isRead: isRead ?? this.isRead, // <-- Digunakan untuk mengubah status dibaca
      createdAt: createdAt ?? this.createdAt,
    );
  }
}