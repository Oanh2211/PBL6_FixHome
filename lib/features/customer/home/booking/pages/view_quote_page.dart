import 'package:flutter/material.dart';

class ViewQuotePage extends StatelessWidget {
  const ViewQuotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Quote')),
      body: Center(
        child: Text(
          'This is the View Quote Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
