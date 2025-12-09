class NotificationItem {
  final int id;
  final String title;
  final String description;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json["id"],
      title: json["title"],
      description: json["description"],
    );
  }
}
