import 'package:flutter/material.dart';
import './model/notif_item.dart';
import './services/notif_service.dart';
import './widget/notif_card.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {

  late Future<List<NotificationItem>> futureNotifications;

  @override
  void initState() {
    super.initState();
    futureNotifications = NotificationService.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F2),

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

      body: FutureBuilder<List<NotificationItem>>(
        future: futureNotifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Gagal memuat notifikasi"),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Text("Tidak ada notifikasi"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NotificationCard(
                  title: item.title,
                  description: item.description,
                  onDetailTap: () {},
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar: Container(
        height: 70,
        color: Colors.white, // placeholder
      ),
    );
  }
}