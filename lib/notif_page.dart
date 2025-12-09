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

  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await NotificationService.fetchNotifications();
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(int index) async {
    final itemToDelete = _notifications[index];

    try {
      // 1. Hapus dari Firestore
      await NotificationService.deleteNotification(itemToDelete.id);

      // 2. Hapus dari List lokal dan update UI
      setState(() {
        _notifications.removeAt(index);
      });

      // Optional: Tampilkan konfirmasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${itemToDelete.title} dihapus")),
      );
    } catch (e) {
      // Jika gagal hapus, masukkan lagi notifikasi ke list jika sempat terhapus
      // Dan tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus: $e")),
      );
    }
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

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text("Error: $_errorMessage"))
              : _notifications.isEmpty
                  ? const Center(child: Text("Tidak ada notifikasi"))
                  : RefreshIndicator( // Pull-to-refresh
                      onRefresh: _fetchData, // Panggil _fetchData saat ditarik
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final item = _notifications[index];

                          // Swipe-to-delete
                          return Dismissible( 
                            key: Key(item.id), // Kunci unik (penting untuk Dismissible)
                            direction: DismissDirection.endToStart, // Hanya dari kanan ke kiri
                            
                            // Background saat di-swipe
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              color: Colors.red,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            
                            // Dipanggil saat item di-swipe hingga hilang
                            onDismissed: (direction) {
                              _deleteItem(index); // Panggil fungsi hapus
                            },

                            // Child yang akan di-swipe (NotificationCard)
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: NotificationCard(
                                title: item.title,
                                description: item.description,
                                onDetailTap: () {},
                              ),
                            ),
                          );
                        },
                      ),
                    ),

      bottomNavigationBar: Container(
        height: 70,
        color: Colors.white, // placeholder
      ),
    );
  }
}