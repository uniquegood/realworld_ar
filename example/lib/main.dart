import 'package:flutter/material.dart';
import 'package:realworld_ar/realworld_ar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _realWorldAr = RealWorldAr();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: TextButton(
            onPressed: () {
              _realWorldAr.show();
            },
            child: const Text("AR 인증"),
          ),
        ),
      ),
    );
  }
}
