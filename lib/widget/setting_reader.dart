import 'package:flutter/material.dart';

class SettingReader extends StatefulWidget {
  const SettingReader({super.key});

  @override
  State<SettingReader> createState() => _SettingReaderState();
}

class _SettingReaderState extends State<SettingReader> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 20, left: 15, right: 15),
      controller: scrollController,
      child: Column(

      ),
    );
  }
}
