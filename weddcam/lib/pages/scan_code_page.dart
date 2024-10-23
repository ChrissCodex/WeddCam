import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding and decoding

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  String? scannedData;

  // Function to fetch scanned QR code details from the server
  Future<void> _fetchCardDetails(String cardNumber) async {
    var url = Uri.parse(
        'https://theparrot.co.tz/mis.theparrot.co.tz/api/get_card_details.php'); // Your API URL

    try {
      var response = await http.post(
        url,
        body: json.encode({'card_number': cardNumber}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            scannedData = response.body;
          });
        } else {
          setState(() {
            scannedData = 'Card not found';
          });
        }
      } else {
        setState(() {
          scannedData = 'Error fetching data';
        });
      }
    } catch (e) {
      setState(() {
        scannedData = 'Error: $e';
      });
    }
  }

  // Callback for handling scanned QR codes
  void _onBarcodeScanned(BarcodeCapture barcodeCapture) {
    final barcode = barcodeCapture.barcodes.first;
    if (barcode.rawValue != null) {
      String cardNumber = barcode.rawValue!;
      _fetchCardDetails(
          cardNumber); // Fetch the card details based on scanned data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Wedding QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              Navigator.popAndPushNamed(
                  context, "/generate"); // Route to GenerateCodePage
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 300,
            width: 300,
            child: MobileScanner(
              onDetect: _onBarcodeScanned, // Correctly passing the callback
            ),
          ),
          const SizedBox(height: 24),
          if (scannedData != null) ...[
            const Text(
              'Scanned Data:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                scannedData!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
