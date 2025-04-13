import 'dart:io';
import 'package:example_reader_epub/web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:epub_decoder/epub_decoder.dart';
import 'package:path_provider/path_provider.dart';

import 'ex.dart';

class EpubCoverScreen extends StatefulWidget {
  const EpubCoverScreen({super.key});

  @override
  State<EpubCoverScreen> createState() => _EpubCoverScreenState();
}

class _EpubCoverScreenState extends State<EpubCoverScreen> {
  String? coverPath;
  bool hasError = false;
  List<String> author = [];
  String title = '';
  List<Section> sections = [];
  late String epubExtractedDir;
  List<Map<String, String>> chapterFiles = [];

  @override
  void initState() {
    super.initState();
    loadEpub();
  }

  Future<void> loadEpub() async {
    try {
      // Đọc file EPUB từ assets
      final data = await rootBundle.load('assets/Flutter.epub');
      final epub = Epub.fromBytes(data.buffer.asUint8List());
      author = epub.authors;
      title = epub.title;
      sections = epub.sections;

      // Lấy ảnh bìa
      if (epub.cover != null) {
        final bytes = epub.cover!.fileContent;

        // Lưu ảnh vào thư mục app
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/epub_cover.png';
        final file = File(path);
        await file.writeAsBytes(bytes);

        setState(() {
          coverPath = path;
        });
      } else {
        setState(() {
          hasError = true;
        });
      }

      final dir = await getApplicationDocumentsDirectory();
      epubExtractedDir = dir.path;

      for (var section in sections) {
        final href = section.content.href; // ví dụ: Text/p001.xhtml
        final filename = href.split('/').last;

        final bytes = section.content.fileContent; // Uint8List
        final path = '${dir.path}/$filename';
        final file = File(path);
        await file.writeAsBytes(bytes);

        chapterFiles.add({'title': filename, 'path': path});
      }


      setState(() {
        coverPath = '${dir.path}/epub_cover.png';
      });
    } catch (e) {
      print('Lỗi load EPUB: $e');
      setState(() {
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ảnh bìa EPUB")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (hasError)
            const Text("Không thể load ảnh bìa 😢")
          else if (coverPath == null)
            const CircularProgressIndicator()
          else
            Image.file(File(coverPath!)),

          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),

          const Text("Danh sách chương:", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),

          // Danh sách các chương
          ...chapterFiles.map((chapter) => ListTile(
            title: Text(chapter['title'] ?? 'Chương'),
            onTap: () {
              final htmlFilePath = chapter['path']!;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EpubContentViewer(htmlFilePath: htmlFilePath),
                ),
              );
            },
          )),
        ],
      ),
    );
  }

}
