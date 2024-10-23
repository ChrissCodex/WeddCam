import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({Key? key}) : super(key: key);

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  MobileScannerController cameraController = MobileScannerController();
  Map<String, dynamic>? cardDetails;
  bool isLoading = false; // To manage loading state

  void _fetchCardDetails(String qrCode) async {
    var url = Uri.parse('https://amplepack.co.tz/get_card_details.php');

    try {
      // Debug print the QR code being sent
      print('Sending QR code: $qrCode');
      setState(() {
        isLoading = true; // Start loading
      });

      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'qr_code': qrCode}),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse['status'] == 'success') {
          setState(() {
            cardDetails = decodedResponse['data'];
            isLoading = false; // Stop loading
          });

          if (cardDetails == null || cardDetails!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No card details found in the response')),
            );
          }
        } else {
          setState(() {
            isLoading = false; // Stop loading
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${decodedResponse['message']}')),
          );
        }
      } else {
        print('Failed to fetch card details: ${response.statusCode}');
        setState(() {
          isLoading = false; // Stop loading
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error occurred while fetching card details: $e');
      setState(() {
        isLoading = false; // Stop loading
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popAndPushNamed(context, "/generate");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              onDetect: (barcodeCapture) {
                final String? code = barcodeCapture.barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  _fetchCardDetails(
                      code); // Fetch card details when QR is scanned
                }
              },
            ),
          ),
          if (isLoading) // Show loading indicator if fetching
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
