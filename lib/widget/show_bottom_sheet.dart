import 'package:flutter/material.dart';

void showLanguageSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        // size_sheet/screen
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 1,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Translate',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const Text("SUGGESTED", style: TextStyle(color: Colors.grey)),
                    ListTile(title: Text('English (US)')),
                    ListTile(title: Text('Dutch')),
                    const SizedBox(height: 16),
                    const Text("OTHER LANGUAGES", style: TextStyle(color: Colors.grey)),
                    ListTile(title: Text('Arabic')),
                    ListTile(title: Text('Chinese (Mandarin, Simplified)')),
                    ListTile(title: Text('Chinese (Mandarin, Traditional)')),
                    ListTile(title: Text('Vietnamese')),
                    ListTile(title: Text('Korean')),
                    ListTile(title: Text('Japanese')),
                    // ... thêm ngôn ngữ nếu muốn
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );
}