import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';

class EpubContentViewer2 extends StatefulWidget {
  final List<Map<String, String>> listHtmlFilePath;


  const EpubContentViewer2({super.key, required this.listHtmlFilePath});

  @override
  State<EpubContentViewer2> createState() => _EpubContentViewer2State();
}

class _EpubContentViewer2State extends State<EpubContentViewer2> {
  final List<String> b = [];
  String _selectedContent = "";
  String _plainText = "";
  final List<String> _htmlContent = [];
  bool _isLoading = true;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    //loadHtmlContent();
    loadAllContent();
  }

  void addMarkdown(String value) {
    b.add(value);
    for (var i in b) {
      print(i);
    }
  }
  String extractTextFromHtml(String rawHtml) {
    if (rawHtml.isEmpty) return '';

    // Loại bỏ các phần script và style
    var result = rawHtml.replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>'), '');
    result = result.replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>'), '');

    // Thay thế các thẻ br và p bằng dấu xuống dòng
    result = result.replaceAll(RegExp(r'<br[^>]*>'), '\n');
    result = result.replaceAll(RegExp(r'<p[^>]*>'), '\n');
    result = result.replaceAll(RegExp(r'</p>'), '\n');

    // Loại bỏ tất cả các thẻ HTML khác
    result = result.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode các ký tự HTML entities (như &nbsp;, &lt;, &gt;, etc.)
    result = result.replaceAll('&nbsp;', ' ');
    result = result.replaceAll('&lt;', '<');
    result = result.replaceAll('&gt;', '>');
    result = result.replaceAll('&amp;', '&');
    result = result.replaceAll('&quot;', '"');

    // Loại bỏ khoảng trắng thừa và chuẩn hóa dấu xuống dòng
    result = result.replaceAll(RegExp(r'[ \t]+'), ' ');
    result = result.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

    return result.trim();
  }

  void speak(String text) async {
    await flutterTts.setLanguage("vi-VN");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  Future<void> loadAllContent() async{
    final listHtml = widget.listHtmlFilePath;
    for(var i = 0; i < listHtml.length; i++){
      loadHtmlContent(listHtml[i]['path']!);
    }
  }

  Future<void> loadHtmlContent(String htmlFilePath) async {
    try {
      final rawHtml = await File(htmlFilePath).readAsString();
      // Tách phần thân từ <body> nếu có
      String htmlContent = rawHtml;
      print("RAW HTML:\n$rawHtml");
      final bodyStart = rawHtml.indexOf('<body');
      final bodyEnd = rawHtml.indexOf('</body>');
      if (bodyStart != -1 && bodyEnd != -1) {
        final startTagEnd = rawHtml.indexOf('>', bodyStart) + 1;
        htmlContent = rawHtml.substring(startTagEnd, bodyEnd);
      }

      final plainText = extractTextFromHtml(rawHtml);
      print("Plain text: $plainText");

      setState(() {
        _plainText = plainText;
        _htmlContent.add(htmlContent);
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi load HTML: $e');
      setState(() {
        _plainText = 'Không đọc được nội dung';
        // _htmlContent = '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nội dung chương"),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              speak(_plainText);
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SelectionArea(
            onSelectionChanged: (SelectedContent? content) {
              _selectedContent = content?.plainText ?? '';
            },
            contextMenuBuilder: (context, selectableRegionState) {
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: selectableRegionState.contextMenuAnchors,
                buttonItems: [
                  ContextMenuButtonItem(
                    onPressed: () {
                      selectableRegionState.copySelection(SelectionChangedCause.toolbar);
                    },
                    type: ContextMenuButtonType.copy,
                  ),
                  ContextMenuButtonItem(
                    onPressed: () {
                      selectableRegionState.selectAll(SelectionChangedCause.toolbar);
                    },
                    type: ContextMenuButtonType.selectAll,
                  ),
                  ContextMenuButtonItem(
                    onPressed: () {
                      addMarkdown(_selectedContent);
                    },
                    type: ContextMenuButtonType.custom,
                    label: 'markdown',
                  ),
                ],
              );
            },
              child: Column(
                children: [
                  for ( var i in _htmlContent)
                    Html(
                      data: i,
                      onLinkTap: (url, _, __) {
                        if (url == null) return;
                        final uri = Uri.parse(url);
                        launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {
                          debugPrint("Không mở được link: $e");
                          return false;
                        });
                      },
                    ),
                ],
              ),
            // child: Html(
            //   data: _htmlContent,
            //   onLinkTap: (url, _, __) {
            //     if (url == null) return;
            //     final uri = Uri.parse(url);
            //     launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {
            //       debugPrint("Không mở được link: $e");
            //       return false;
            //     });
            //   },
            // ),
          ),
        ),
      ),
    );
  }
}
