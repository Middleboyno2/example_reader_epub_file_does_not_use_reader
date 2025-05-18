import 'package:flutter/material.dart';


class AppbarCustom extends StatefulWidget {
  final String title;
  final double progress;
  const AppbarCustom({super.key, required this.title, required this.progress});

  @override
  State<AppbarCustom> createState() => _AppbarCustomState();
}

class _AppbarCustomState extends State<AppbarCustom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15)
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      height: 190,
      child: Row(
        children: [
          // table of content
          IconButton(
            onPressed: (){},
            icon: Icon(Icons.table_rows_rounded )
          ),
          // tittle
          Text('data')
          // progress
          // setting
        ],
      ),
    );
  }
}
