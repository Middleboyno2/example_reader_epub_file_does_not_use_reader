import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class EpubContent extends StatefulWidget {
  final String htmlFilePath;

  const EpubContent({super.key, required this.htmlFilePath});

  @override
  State<EpubContent> createState() => _EpubContentViewerState();
}

class _EpubContentViewerState extends State<EpubContent> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    }

    // ⚙️ Khởi tạo controller WebView
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFile(widget.htmlFilePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đọc chương EPUB')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
