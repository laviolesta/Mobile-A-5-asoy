import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import Model dan Service yang Anda butuhkan
import '../models/notif_item.dart';
import '../services/notif_service.dart';

// Import Widgets yang Anda butuhkan
import '../widgets/notif_card.dart';
import '../widgets/header_widget.dart';
import '../widgets/bottom_navbar.dart';
import '../utils/no_animation_route.dart'; // Asumsi: Digunakan untuk navigasi tanpa animasi

// Import Halaman Tujuan Navigasi
import 'home_page.dart';
import 'sewa/sewa_page.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  // --- STATE UNTUK PAGINATION & DATA ---
  List<NotificationItem> _notifications = [];
  DocumentSnapshot? _lastDocument; 
  bool _isLoading = false; 
  bool _isPaginating = false; 
  bool _hasMore = true; 
  String? _errorMessage;
  String? _userId; // ID Pengguna untuk filter notifikasi
  
  final ScrollController _scrollController = ScrollController(); 

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi User ID dan Mulai Load Data
    _initializeUserAndLoad(); 
    _scrollController.addListener(_onScroll);
  }

  // === FUNGSI INTI: INIALISASI USER & LOAD DATA ===
  void _initializeUserAndLoad() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Menangani kasus jika user belum login
      setState(() {
        _errorMessage = "Anda harus login untuk melihat notifikasi.";
      });
      return;
    }
    
    _userId = user.uid;
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- LOGIC NAVIGASI BOTTOM BAR ---
  void _onNavTapped(BuildContext context, int index) {
    if (index == 2) return; // Tetap di NotifikasiPage

    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const SewaPage();
        break;
      default:
        return; // Harusnya tidak terjadi
    }

    Navigator.pushReplacement(
      context,
      NoAnimationPageRoute(page: page),
    );
  }

  // --- LOGIC: SCROLL DAN LOAD MORE ---
  void _onScroll() {
    // Memuat data baru ketika scroll mencapai 80% dari bagian bawah
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8 &&
        !_isPaginating && 
        _hasMore) {
      _loadMoreData();
    }
  }

  // --- LOGIC: LOAD DATA AWAL ---
  Future<void> _loadInitialData() async {
    if (_userId == null || _isLoading) return; // Cek User ID
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await NotificationService.fetchPaginatedNotifications(
          _userId!, // Menggunakan User ID yang sudah dipastikan tidak null
          null
      );
      
      setState(() {
        _notifications = result['notifications'] as List<NotificationItem>;
        _lastDocument = result['lastDocument'] as DocumentSnapshot?;
        _hasMore = result['hasMore'] as bool;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat notifikasi: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  // --- LOGIC: LOAD MORE DATA ---
  Future<void> _loadMoreData() async {
    if (_userId == null || _isPaginating || !_hasMore) return; // Cek User ID dan kondisi lain
    setState(() {
      _isPaginating = true;
    });

    try {
      final result = await NotificationService.fetchPaginatedNotifications(
          _userId!, 
          _lastDocument
      );
      // Pengecekan Type Cast dilakukan di sini
      final newNotifications = result['notifications'] as List<NotificationItem>; 
      
      setState(() {
        _notifications.addAll(newNotifications);
        _lastDocument = result['lastDocument'] as DocumentSnapshot?;
        _hasMore = result['hasMore'] as bool;
        _isPaginating = false;
      });
    } catch (e) {
      setState(() {
        _isPaginating = false;
        // Error paging biasanya tidak perlu ditampilkan, cukup di log.
      });
    }
  }

  // --- LOGIC: DELETE ITEM (SWIPE) ---
  Future<void> _deleteItem(int index) async {
    final itemToDelete = _notifications[index];
    try {
      await NotificationService.deleteNotification(itemToDelete.id);
      setState(() {
        _notifications.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${itemToDelete.title} dihapus")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus: ${e.toString()}")),
      );
    }
  }

  // --- LOGIC: TANDAI SUDAH DIBACA DAN NAVIGASI ---
  Future<void> _markAsReadAndNavigate(NotificationItem item, int index) async {
    if (!item.isRead) {
      try {
        await NotificationService.markAsRead(item.id);
        
        // Mengupdate tampilan lokal menggunakan copyWith
        setState(() {
          // Asumsi kelas NotificationItem memiliki metode copyWith
          _notifications[index] = item.copyWith(isRead: true); 
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menandai dibaca: ${e.toString()}")),
        );
      }
    }
    
    // TODO: Implementasi navigasi ke halaman detail terkait notifikasi
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Navigasi ke Detail Notifikasi ID: ${item.id}")),
    );
  }

  // --- WIDGET LIST NOTIFIKASI ---
  Widget _buildNotificationList() {
    if (_isLoading && _notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Menampilkan pesan error jika user belum login atau terjadi kesalahan fatal
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 10),
              Text(_errorMessage!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(child: Text("Tidak ada notifikasi"));
    }

    return RefreshIndicator( 
      onRefresh: _loadInitialData, 
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        // Tambah 1 jika masih ada data (untuk menampilkan loading indicator)
        itemCount: _notifications.length + (_hasMore ? 1 : 0), 
        itemBuilder: (context, index) {
          
          // Loading indicator di bagian bawah
          if (index == _notifications.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final item = _notifications[index];

          // Widget Dismissible untuk hapus (swipe)
          return Dismissible( 
            key: ValueKey(item.id), 
            direction: DismissDirection.endToStart, 
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            
            onDismissed: (direction) => _deleteItem(index),

            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => _markAsReadAndNavigate(item, index),
                child: NotificationCard(
                  title: item.title,
                  description: item.description,
                  isRead: item.isRead, 
                  onDetailTap: () => _markAsReadAndNavigate(item, index), // Panggil handler utama
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          const HeaderWidget(title: "Notifikasi"),
          
          // Body (List Notifikasi)
          Expanded(
            child: _buildNotificationList(), 
          ),
        ],
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) => _onNavTapped(context, index),
      ),
    );
  }
}