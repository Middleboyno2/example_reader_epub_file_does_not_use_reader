import 'dart:io';

  import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class EpubContentViewer extends StatelessWidget {
  final String htmlFilePath;
  final String a;

  const EpubContentViewer({super.key, required this.htmlFilePath, required this.a});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nội dung chương")),
      body: FutureBuilder<String>(
        future: File(htmlFilePath).readAsString(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Lỗi đọc nội dung'));
            }

            String rawHtml = snapshot.data ?? '';


            final bodyStart = rawHtml.indexOf('<body');
            final bodyEnd = rawHtml.indexOf('</body>');

            String htmlContent = '';
            if (bodyStart != -1 && bodyEnd != -1) {
              // lấy từ dấu ">" sau <body ...> đến </body>
              final startTagEnd = rawHtml.indexOf('>', bodyStart) + 1;
              htmlContent = rawHtml.substring(startTagEnd, bodyEnd);
            } else {
              htmlContent = rawHtml; // fallback nếu không tìm thấy body
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child:  Html(
                  data: htmlContent,
                  onLinkTap: (url, _, __) {
                    if (url == null) return;
                    final uri = Uri.parse(url);
                    print(uri);
                    launchUrl(uri, mode: LaunchMode.externalApplication)
                        .catchError((e) {
                      debugPrint("Không mở được link: $e");
                      return false;
                    });
                  },
                )
              )

            );

          }
      ),
    );
  }
}
