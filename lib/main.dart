import 'package:flutter/material.dart';

import 'screens/todo_home_page.dart';

void main() {
  runApp(const FlutterIosDemoApp());
}

class FlutterIosDemoApp extends StatelessWidget {
  const FlutterIosDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter iOS Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}
