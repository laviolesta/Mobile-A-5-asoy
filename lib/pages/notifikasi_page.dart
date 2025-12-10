import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../widgets/bottom_navbar.dart';
import '../utils/no_animation_route.dart';

import 'home_page.dart';
import 'sewa/sewa_page.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          HeaderWidget(title: "Notifikasi"),
          Expanded(
            child: Center(child: Text("Isi notifikasi di sini")),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) => _onNavTapped(context, index),
      ),
    );
  }
}
