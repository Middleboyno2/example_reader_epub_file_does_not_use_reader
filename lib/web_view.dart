import 'dart:async';
import 'dart:io';
import 'package:example_reader_epub/widget/show_bottom_sheet.dart';
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
  late WebViewController _controller ;
  bool _isLoading = true;
  double position = 0.0;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    }
    fetchArticle();
    // _controller = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setNavigationDelegate(NavigationDelegate(
    //     onPageFinished: (_) {
    //       setState(() {
    //         _isLoading = false;
    //       });
    //     },
    //     onProgress: (progress) {
    //       setState(() {
    //         // This tracks the initial loading progress
    //         _progress = progress;
    //       });
    //     },
    //   ));

    _loadAllChapters();
  }

  Future<void> fetchArticle() async {
    late final PlatformWebViewControllerCreationParams params;
    params = const PlatformWebViewControllerCreationParams();

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'ARTICLE_SCROLL_CHANNEL',
        onMessageReceived: (progress) {
          setState(() {
            position = double.parse(progress.message);
          });
        },
      )
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _controller.runJavaScript(
              '''
              window.addEventListener('scroll', function() {
                progress = (this.scrollY / ( document.body.scrollHeight - window.innerHeight ) ) * 100;
                window.ARTICLE_SCROLL_CHANNEL.postMessage(progress);
              });
              ''',
            );
          },
        ),
      )
      ..loadRequest(Uri.parse('https://flutter.dev'));

    _controller = controller;
  }


  Future<void> _loadAllChapters() async {
    String fullHtml = """
    <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: sans-serif; padding: 20px; line-height: 1.6; }
          h2 { margin-top: 40px; }
          a { color: black; text-decoration: none; }
        </style>
      </head>
      <body>
    """;

    for (var i = 0; i < widget.listHtmlFilePath.length; i++) {
      final path = widget.listHtmlFilePath[i]['path']!;
      final htmlContent = await File(path).readAsString();

      // Cắt phần <body> ra nếu cần
      final bodyStart = htmlContent.indexOf('<body');
      final bodyEnd = htmlContent.indexOf('</body>');
      String bodyOnly = htmlContent;

      if (bodyStart != -1 && bodyEnd != -1) {
        final startTagEnd = htmlContent.indexOf('>', bodyStart) + 1;
        bodyOnly = htmlContent.substring(startTagEnd, bodyEnd);
      }

      // Thay thế các link href="file.xhtml#anchor" thành href="#anchor"
      final bodyWithFixedLinks = bodyOnly.replaceAllMapped(
        RegExp(r'<a href="[^"]+?#([^"]+)">'),
            (match) => '<a href="#${match[1]}">',
      );
      fullHtml += """
        $bodyWithFixedLinks
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
        title: Text(widget.title),
        actions: [
          // Reading progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.menu_book, size: 18),
                const SizedBox(width: 4),
                Text('${position.toStringAsFixed(2)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // setting
          IconButton(
            onPressed:() => showLanguageSelector(context),
            icon: Icon(Icons.settings)
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller
          ),

          // màn hình load tài liệu
          if (_isLoading) const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}
