class NotificationItem {
  final String id;
  final String title;
  final String description;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}
