import 'package:flutter/material.dart';
import 'pages/generate_code_page.dart';
import 'pages/scan_code_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        "/generate": (context) => const GenerateCodePage(),
        "/scan": (context) =>  const ScanCodePage(),
      },
      initialRoute: "/scan", // Start with ScanCodePage
    );
  }
}
