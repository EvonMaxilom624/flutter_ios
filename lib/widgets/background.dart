import 'package:flutter/material.dart';

class CustomBackground extends StatelessWidget {
  final Widget child;
  final String backgroundImage;

  const CustomBackground({
    super.key,
    required this.child,
    this.backgroundImage = 'newbg.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
