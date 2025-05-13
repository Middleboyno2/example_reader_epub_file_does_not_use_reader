import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

class RawHtmlViewer extends StatefulWidget {
  final String htmlFilePath;

  const RawHtmlViewer({super.key, required this.htmlFilePath});

  @override
  State<RawHtmlViewer> createState() => _RawHtmlViewerState();
}

class _RawHtmlViewerState extends State<RawHtmlViewer> {
  String rawHtml = "";

  @override
  void initState() {
    super.initState();
    loadHtmlContent();
  }

  Future<void> loadHtmlContent() async {
    final file = File(widget.htmlFilePath);
    final bytes = await file.readAsBytes();
    final content = utf8.decode(bytes); // đảm bảo đúng encoding
    setState(() {
      rawHtml = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Raw HTML Debug Viewer")),
      body: rawHtml.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          rawHtml,
          style: const TextStyle(fontFamily: 'monospace'), // giống console
        ),
      ),
    );
  }
}
