import 'package:flutter/material.dart';
import 'package:soham/screens/GettingStartedScreen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () async {



      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GettingStartedScreen()),
      );

    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Image.asset(
              "assets/logo_gif.gif",
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}