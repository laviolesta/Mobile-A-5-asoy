import 'package:flutter/material.dart';
import '../../widgets/header_widget.dart';
import '../../widgets/bottom_navbar.dart';
import '../../utils/no_animation_route.dart';

import '../home_page.dart';
import '../notifikasi_page.dart';

class SewakanPage extends StatelessWidget {
  const SewakanPage({super.key});

  void _onNavTapped(BuildContext context, int index) {
    if (index == 1) return;

    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 2:
        page = const NotifikasiPage();
        break;
      default:
        page = const SewakanPage();
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
          HeaderWidget(title: "Sewakan"),
          Expanded(
            child: Center(child: Text("Halaman barang yang kamu sewakan")),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onNavTapped(context, index),
      ),
    );
  }
}
