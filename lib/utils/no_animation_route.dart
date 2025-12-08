import 'package:flutter/material.dart';

class NoAnimationPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  NoAnimationPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
}
