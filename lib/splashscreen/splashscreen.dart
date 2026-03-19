import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/login/admin_login.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 3),
          () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Signinscreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FB),
      body: Center(
        child: Image.asset(
          "assets/splash.png", 
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}