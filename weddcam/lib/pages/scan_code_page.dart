import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanCodePage extends StatefulWidget {
  @override
  _ScanCodePageState createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  final String baseUrl =
      'http://esit.or.tz/esit/api/'; // Replace with your API base URL
  bool isScanning = true;
  String scanResult = '';

  void _onDetect(BarcodeCapture barcodeCapture) async {
    if (!isScanning || barcodeCapture.barcodes.isEmpty) return;

    final String? code = barcodeCapture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() => isScanning = false); // Stop further scans

    final response = await _checkAndUpdateStatus(code);
    setState(() {
      scanResult = response;
    });

    // Resume scanning after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => isScanning = true);
      }
    });
  }

  Future<String> _checkAndUpdateStatus(String qrCode) async {
    try {
      // First, check the current status of the QR code
      final checkResponse = await http.get(
        Uri.parse('$baseUrl/update_card_status.php?qr_code=$qrCode'),
      );

      if (checkResponse.statusCode == 200) {
        final checkData = json.decode(checkResponse.body);

        if (checkData['status'] == 'Scanned') {
          return 'QR Code already scanned!\nDetails:\n${_formatDetails(checkData)}';
        } else {
          // Update the status to 'Scanned'
          final updateResponse = await http.post(
            Uri.parse('$baseUrl/update.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'qr_code': qrCode}),
          );

          if (updateResponse.statusCode == 200) {
            final updateData = json.decode(updateResponse.body);
            return 'Successfully scanned!\nDetails:\n${_formatDetails(updateData)}';
          } else {
            return 'Error updating status';
          }
        }
      } else {
        return 'Failed to check QR status';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  String _formatDetails(Map<String, dynamic> data) {
    final excludeKeys = ['error', 'success'];
    return data.entries
        .where((e) => !excludeKeys.contains(e.key))
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, "/generate"); // Switch to generate page
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
                    scanResult,
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

  @override
  void dispose() {
    super.dispose();
  }
}
