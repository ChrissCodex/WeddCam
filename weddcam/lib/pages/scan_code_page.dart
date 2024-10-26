import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanCodePage extends StatefulWidget {
  @override
  _ScanCodePageState createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  bool isScanning = true;
  String scanResult = '';

  void _onDetect(BarcodeCapture barcodeCapture) {
    if (!isScanning || barcodeCapture.barcodes.isEmpty) return;

    final String? code = barcodeCapture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      isScanning = false; // Stop further scans
      scanResult = code;  // Store the scanned QR code value
    });

    // Resume scanning after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => isScanning = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, "/generate"); // Switch to scan page
            },
            icon: const Icon(Icons.qr_code_scanner),
          ),
          
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: MobileScanner(
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Text(
                    scanResult.isEmpty ? 'Scan a QR code' : 'Scanned Result:\n$scanResult',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
