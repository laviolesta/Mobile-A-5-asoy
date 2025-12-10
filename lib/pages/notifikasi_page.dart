import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; // <--- PERLU TAMBAHAN IMPORT INI
import '../models/notif_item.dart';
import '../services/notif_service.dart';
import '../widgets/notif_card.dart';
import '../widgets/header_widget.dart';
import '../widgets/bottom_navbar.dart';
import '../utils/no_animation_route.dart';
import 'sewa/sewa_page.dart';
import 'home_page.dart';
import 'notif_detail_page.dart'; 

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
  
  final ScrollController _scrollController = ScrollController(); 

  // --- LOGIC GET USER ID ---
  String get _currentUserId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User belum login.");
    }
    return user.uid;
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- LOGIC NAVIGASI ---
  void _onNavTapped(BuildContext context, int index) {
    if (index == 2) return;

    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const SewaPage();
        break;
      default:
        page = const NotifikasiPage();
    }

    Navigator.pushReplacement(
      context,
      NoAnimationPageRoute(page: page),
    );
  }

  // --- LOGIC: SCROLL DAN LOAD MORE ---
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8 &&
        !_isPaginating && 
        _hasMore) {
      _loadMoreData();
    }
  }

  // --- LOGIC: LOAD DATA AWAL ---
  Future<void> _loadInitialData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await NotificationService.fetchPaginatedNotifications(
          _currentUserId, // <--- User ID diteruskan
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
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // --- LOGIC: LOAD MORE DATA ---
  Future<void> _loadMoreData() async {
    if (_isPaginating || !_hasMore) return;
    setState(() {
      _isPaginating = true;
    });

    try {
      final result = await NotificationService.fetchPaginatedNotifications(
          _currentUserId, // <--- User ID diteruskan
          _lastDocument
      );
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
        SnackBar(content: Text("Gagal menghapus: $e")),
      );
    }
  }

  // --- LOGIC: MARK AS READ & NAVIGATE TO DETAIL ---
  Future<void> _markAsReadAndNavigate(NotificationItem item, int index) async {
    bool shouldNavigate = true;
    NotificationItem itemToPass = item;

    // Mark as Read jika belum dibaca
    if (!item.isRead) {
      try {
        await NotificationService.markAsRead(item.id);
        
        // Update state di halaman ini
        setState(() {
          itemToPass = item.copyWith(isRead: true);
          _notifications[index] = itemToPass; // Update item di list
        });
      } catch (e) {
        shouldNavigate = false; // Jangan navigasi jika gagal update status baca
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menandai dibaca: $e")),
        );
      }
    }

    // Navigasi ke Halaman Detail
    if (shouldNavigate) {
      // Navigasi ke NotifDetailPage
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NotifDetailPage(notification: itemToPass),
        ),
      );
    }
  }

  // --- WIDGET LIST NOTIFIKASI ---
  Widget _buildNotificationList() {
    if (_isLoading && _notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text("Error: $_errorMessage"));
    }
    if (_notifications.isEmpty) {
      return const Center(child: Text("Tidak ada notifikasi"));
    }

    return RefreshIndicator( 
      onRefresh: _loadInitialData, 
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length + (_hasMore ? 1 : 0), 
        itemBuilder: (context, index) {
          
          if (index == _notifications.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final item = _notifications[index];

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
                  onDetailTap: () {},
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
      // 1. HEADER DARI KODE LAMA
      // 1. HEADER DARI KODE LAMA
      body: Column(
        children: [
          const HeaderWidget(title: "Notifikasi"),
          Expanded(
            child: _buildNotificationList(), // Memanggil List Notifikasi
          ),
        ],
      ),
      
      // 2. BOTTOM NAV BAR DARI KODE LAMA
      
      // 2. BOTTOM NAV BAR DARI KODE LAMA
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) => _onNavTapped(context, index),
      ),
    );
  }
}