import 'dart:io';
import 'package:epubx/epubx.dart';
import 'package:example_reader_epub/abc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import 'exam_basic.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter EPUB Reader'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: _loadAndOpenEpub,
          child: const Text('Đọc Flutter.epub'),
        ),
      ),
    );
  }

  Future<void> _loadAndOpenEpub() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy đường dẫn tới thư mục tạm để copy file từ assets
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Flutter.epub';

      // Copy file từ assets vào thư mục tạm
      final data = await rootBundle.load('assets/Flutter.epub');
      final bytes = data.buffer.asUint8List();
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Mở file EPUB với VocsyEpub Viewer
      VocsyEpub.setConfig(
        themeColor: Theme.of(context).primaryColor,
        identifier: "iosBook",
        scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
        allowSharing: true,
        enableTts: true,
        nightMode: false,
      );

      // Mở EPUB reader với đường dẫn file
      VocsyEpub.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// 4. Lưu ý:
// - Package path_provider cũng cần được thêm vào pubspec.yaml để sử dụng getApplicationDocumentsDirectory()
// - Cần yêu cầu quyền Storage trên Android (thêm vào AndroidManifest.xml)
// - Đối với iOS, cần cấu hình thêm trong Info.plist