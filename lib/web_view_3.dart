import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:path/path.dart' as path;

class EpubContent3 extends StatefulWidget {
  final List<Map<String, String>> listHtmlFilePath;
  final String title;
  final String? basePath; // Thêm basePath để xử lý các file CSS

  const EpubContent3({
    super.key,
    required this.listHtmlFilePath,
    required this.title,
    this.basePath,
  });

  @override
  State<EpubContent3> createState() => _EpubContentState();
}

class _EpubContentState extends State<EpubContent3> {
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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { 
            font-family: sans-serif; 
            padding: 20px; 
            line-height: 1.6;
            color: #333;
          }
          h2 { margin-top: 40px; }
          /* Định nghĩa rõ ràng về link thật */
          a { 
            color: blue; 
            text-decoration: underline; 
          }
          /* Ghi đè lên các kiểu có thể gây nhầm lẫn */
          span:not(a span) {
            color: inherit !important;
            text-decoration: none !important;
          }
        </style>
      </head>
      <body>
    """;

    for (var i = 0; i < widget.listHtmlFilePath.length; i++) {
      final path = widget.listHtmlFilePath[i]['path']!;
      var htmlContent = await File(path).readAsString();

      // Cắt phần <body> ra nếu cần
      final bodyStart = htmlContent.indexOf('<body');
      final bodyEnd = htmlContent.indexOf('</body>');
      String bodyOnly = htmlContent;

      if (bodyStart != -1 && bodyEnd != -1) {
        final startTagEnd = htmlContent.indexOf('>', bodyStart) + 1;
        bodyOnly = htmlContent.substring(startTagEnd, bodyEnd);
      }

      // Xử lý các link thật
      final bodyWithFixedLinks = bodyOnly
      // 1. Thay thế link xhtml thành anchor
          .replaceAllMapped(
          RegExp(r'href="[^"]+?#([^"]+)"'),
              (match) => 'href="#${match[1]}"'
      )
      // 2. Đảm bảo tất cả các link đều có thuộc tính class để dễ nhận biết
          .replaceAllMapped(
          RegExp(r'<a\s+([^>]*)href="([^"]+)"([^>]*)>'),
              (match) => '<a ${match[1] ?? ''}href="${match[2]}" class="real-link"${match[3] ?? ''}>'
      );

      fullHtml += """
        <h2 id="chapter_${i + 1}">Chương ${i + 1}</h2>
        <div class="chapter-content">
          $bodyWithFixedLinks
        </div>
        <hr />
      """;
    }

    fullHtml += """
      <script>
        // Script để xử lý các phần tử giả link khi trang tải xong
        document.addEventListener('DOMContentLoaded', function() {
          // Xử lý các phần tử span có kiểu giống link
          const spans = document.querySelectorAll('span:not(a span)');
          spans.forEach(span => {
            // Đặt lại kiểu
            span.style.color = 'inherit';
            span.style.textDecoration = 'none';
          });
        });
      </script>
      </body>
    </html>
    """;

    _controller.loadHtmlString(fullHtml);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}