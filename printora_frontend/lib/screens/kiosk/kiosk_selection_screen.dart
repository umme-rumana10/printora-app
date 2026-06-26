import 'package:flutter/material.dart';

class KioskSelectionScreen extends StatelessWidget {
  const KioskSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Kiosk"),
      ),
      body: const Center(
        child: Text(
          "Kiosk List Coming Soon",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}