import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class EpubContent extends StatefulWidget {
  final List<Map<String, String>> listHtmlFilePath;
  final String title;

  const EpubContent({super.key, required this.listHtmlFilePath, required this.title});

  @override
  State<EpubContent> createState() => _EpubContentState();
}

class _EpubContentState extends State<EpubContent> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          setState(() {
            _isLoading = false;
          });
        },
      ));

    _loadAllChapters();
  }

  Future<void> _loadAllChapters() async {
    String fullHtml = """
    <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: sans-serif; padding: 20px; line-height: 1.6; }
          h2 { margin-top: 40px; }
        </style>
      </head>
      <body>
    """;

    for (var i = 0; i < widget.listHtmlFilePath.length; i++) {
      final path = widget.listHtmlFilePath[i]['path']!;
      final htmlContent = await File(path).readAsString();

      // Cắt phần thân <body> nếu cần
      final bodyStart = htmlContent.indexOf('<body');
      final bodyEnd = htmlContent.indexOf('</body>');
      String bodyOnly = htmlContent;

      if (bodyStart != -1 && bodyEnd != -1) {
        final startTagEnd = htmlContent.indexOf('>', bodyStart) + 1;
        bodyOnly = htmlContent.substring(startTagEnd, bodyEnd);
      }

      fullHtml += """
        <h2>Chương ${i + 1}</h2>
        $bodyOnly
        <hr />
      """;
    }

    fullHtml += """
      </body>
    </html>
    """;

    _controller.loadHtmlString(fullHtml);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đọc tất cả chương"),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}
