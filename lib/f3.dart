import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

class EpubContentViewer3 extends StatefulWidget {
  final List<Map<String, String>> listHtmlFilePath;
  final String title;

  const EpubContentViewer3({super.key, required this.listHtmlFilePath, required this.title});

  @override
  State<EpubContentViewer3> createState() => _EpubContentViewer3State();
}

class _EpubContentViewer3State extends State<EpubContentViewer3> {
  final List<String> b = [];
  String _selectedContent = "";
  String _plainText = "";

  // Danh sách chứa nội dung HTML đã tải
  late List<String?> _htmlContent;

  late ScrollController _scrollController;

  bool _isLoading = true;
  double _readingProgress = 0.0;
  int _currentSection = 0;
  double _sectionProgress = 0.0;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _htmlContent = List<String?>.filled(widget.listHtmlFilePath.length, null);
    _loadInitialSections();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _loadInitialSections() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    if(prefs.getDouble('reading_progress_${widget.title}') == null){
      // Xác định các section cần tải ban đầu
      final int startSection = 0;
      await _loadSection(startSection);

      setState(() {
        _currentSection = startSection;
        _isLoading = false;
      });
    }else{
      _readingProgress = prefs.getDouble('reading_progress_${widget.title}') ?? 0.0;
      final sectionLocation = (_readingProgress * widget.listHtmlFilePath.length)/100;
      final currentSection = sectionLocation.toInt() - 1;
      final sectionProgress = sectionLocation - _currentSection;
      await _loadSection(currentSection);
      setState(() {
        _currentSection = currentSection;
        _sectionProgress = sectionProgress;
        print('current section: $_currentSection, section progress: $_sectionProgress');
      });
    }
  }

  Future<void> _loadSection(int index) async {
    try {
      final filePath = widget.listHtmlFilePath[index]['path']!;
      final rawHtml = await File(filePath).readAsString();

      // Tách phần thân từ <body> nếu có
      String htmlContent = rawHtml;
      final bodyStart = rawHtml.indexOf('<body');
      final bodyEnd = rawHtml.indexOf('</body>');
      if (bodyStart != -1 && bodyEnd != -1) {
        final startTagEnd = rawHtml.indexOf('>', bodyStart) + 1;
        htmlContent = rawHtml.substring(startTagEnd, bodyEnd);
      }
      // Cập nhật plainText cho TTS (có thể chỉ lưu phần hiện tại hoặc ghép lại)
      // final plainText = extractTextFromHtml(rawHtml);
      // if (index == _currentSection) {
      //   _plainText = plainText;
      // }

      // Cập nhật nội dung trong state
      setState(() {
        _htmlContent[index] = htmlContent;
      });

    } catch (e) {
      print('Lỗi load HTML tại section $index: $e');
      // Đặt giá trị để tránh tải lại nhiều lần
      setState(() {
        _htmlContent[index] = '<p>Không đọc được nội dung</p>';
      });
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

    // Decode các ký tự HTML entities
    result = result.replaceAll('&nbsp;', ' ');
    result = result.replaceAll('&lt;', '<');
    result = result.replaceAll('&gt;', '>');
    result = result.replaceAll('&amp;', '&');
    result = result.replaceAll('&quot;', '"');

    // Loại bỏ khoảng trắng thừa
    result = result.replaceAll(RegExp(r'[ \t]+'), ' ');
    result = result.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

    return result.trim();
  }

  void addMarkdown(String value) {
    b.add(value);
    for (var i in b) {
      print(i);
    }
  }

  void speak(String text) async {
    await flutterTts.setLanguage("vi-VN");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nội dung chương"),
        actions: [
          Text('${(_sectionProgress*100)} %'),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SelectionArea(
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
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: widget.listHtmlFilePath.length,
          itemBuilder: (context, index) {
            // _itemKeys.putIfAbsent(index, () => GlobalKey());
            return VisibilityDetector(
              key: Key('item-$index'),
              onVisibilityChanged: (VisibilityInfo info) {
                if(info.visibleFraction >= 0.0){
                  if(_htmlContent[index + 1] == null){
                    _loadSection(index + 1);
                    print('Hiện tại đa load section ${index + 1}');
                  }
                  if(_htmlContent[index - 1] == null && index !=0){
                    _loadSection(index -1);
                    print('Hiện tại đa load section ${index + 1}');
                  }

                }
                if (info.visibleFraction > _sectionProgress) {
                  setState(() {
                    _currentSection = index;
                    _sectionProgress = info.visibleFraction;
                  });
                }
              },
              child: _htmlContent[index] == null
                  ? SizedBox(
                height: 600,
                child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    )),
              )
                  : Html(
                // key: _itemKeys[index],
                data: _htmlContent[index]!,
                onLinkTap: (url, _, __) {
                  if (url == null) return;
                  final uri = Uri.parse(url);
                  launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {
                    debugPrint("Không mở được link: $e");
                    return false;
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}