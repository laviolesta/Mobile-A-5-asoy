import 'package:flutter/material.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  // contoh data notifikasi
  List<Map<String, String>> notifications = [
    {
      "title": "Judul Notifikasi",
      "description": "Deskripsi singkat",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F2),

      // --- AppBar Custom ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.only(top: 35),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE0DFDC)),
            ),
          ),
          child: const Text(
            "Notifikasi",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      // --- Body ---
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              for (int i = 0; i < notifications.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NotificationCard(
                    title: notifications[i]["title"]!,
                    description: notifications[i]["description"]!,
                    onDetailTap: () {},
                    onClose: () {
                      setState(() {
                        notifications.removeAt(i);
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),

      // --- Bottom Navigation Placeholder ---
      bottomNavigationBar: Container(
        height: 70,
        color: Colors.white,
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onDetailTap;
  final VoidCallback onClose;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.onDetailTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Text section ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onDetailTap,
                  child: const Text(
                    "Lihat detail",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Close Icon ---
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}