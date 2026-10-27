import 'package:flutter/material.dart';

import 'screens/vote_screen.dart';

void main() {
  runApp(const IjwiApp());
}

class IjwiApp extends StatelessWidget {
  const IjwiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ijwi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1B7F5C),
        useMaterial3: true,
      ),
      home: const VoteScreen(),
    );
  }
}
