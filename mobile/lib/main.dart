import 'package:flutter/material.dart';
import 'screen/login_screen.dart';

void main() {
  runApp(const FocusStudyApp());
}

class FocusStudyApp extends StatelessWidget {
  const FocusStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusStudy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
