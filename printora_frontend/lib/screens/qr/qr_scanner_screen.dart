import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../state/app_state.dart';
import '../upload/upload_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool scanned = false;

  final MobileScannerController controller = MobileScannerController();

  void handleQR(String code) {
    final cleaned = code.trim();

    print("RAW QR: $code");
    print("CLEANED QR: $cleaned");

    if (scanned) return;

    // Check if the QR contains our identifier anywhere
    if (!cleaned.contains("PRINTORA:KIOSK_ID:")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Scanned: $cleaned")),
      );
      return;
    }

    scanned = true;
    controller.stop();

    // Extract kiosk id
    final kioskId = cleaned.substring(
        cleaned.indexOf("PRINTORA:KIOSK_ID:") + "PRINTORA:KIOSK_ID:".length);

    AppState.kioskId = kioskId;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Kiosk Selected: $kioskId")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const UploadScreen(),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          if (scanned) return;

          final barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;

          if (code != null) {
            print("Scanned QR = '$code'");
            handleQR(code);
          }
        },
      ),
    );
  }
}
