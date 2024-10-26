import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanCodePage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanCodePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;
  String scanResult = '';

  // Replace with your domain
  final String baseUrl = 'http://esit.or.tz/esit/api/';

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
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!isScanning) return;
      
      isScanning = false;
      controller.pauseCamera();
      
      await processQRCode(scanData.code ?? '');
    });
  }

  Future<void> processQRCode(String qrData) async {
    try {
      // Check QR status
      final response = await checkQRStatus(qrData);
      
      if (response['error'] != null) {
        setState(() {
          scanResult = 'Error: ${response['error']}';
        });
        return;
      }

      if (response['status'] == 'Scanned') {
        setState(() {
          scanResult = 'QR Code already scanned!\n\nDetails:\n' +
              formatDetails(response);
        });
      } else {
        // Update status to 'Scanned'
        final updateResponse = await updateQRStatus(qrData);
        
        if (updateResponse['error'] != null) {
          setState(() {
            scanResult = 'Error updating status: ${updateResponse['error']}';
          });
          return;
        }

        setState(() {
          scanResult = 'Successfully scanned!\n\nDetails:\n' +
              formatDetails(updateResponse);
        });
      }
    } catch (e) {
      setState(() {
        scanResult = 'Error: ${e.toString()}';
      });
    } finally {
      // Reset after 3 seconds and resume scanning
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            isScanning = true;
            controller?.resumeCamera();
          });
        }
      });
    }
  }

  Future<Map<String, dynamic>> checkQRStatus(String qrCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/update_card_status.php?qr_code=$qrCode'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': 'Failed to check QR status'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateQRStatus(String qrCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'qr_code': qrCode}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': 'Failed to update QR status'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  String formatDetails(Map<String, dynamic> data) {
    final excludeKeys = ['error', 'success'];
    return data.entries
        .where((e) => !excludeKeys.contains(e.key))
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}