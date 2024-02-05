import 'package:flutter/material.dart';
import 'package:global_news_app/screens/HomeScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => HomeScreen(title: "G-NEWS")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 100,
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const Image(
              image: AssetImage('assets/logo.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
            margin: const EdgeInsets.only(top: 20),
            child: const Text('Global News',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))
      ],
    )));
  }
}
