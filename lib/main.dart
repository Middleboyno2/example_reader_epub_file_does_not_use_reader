
import 'package:example_reader_epub/abc.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter EPUB Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EpubCoverScreen(),
    );
  }
}
