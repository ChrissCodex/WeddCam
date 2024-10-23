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
  bool isLoading = false;
  bool isScanning = true; // To control scanner state

  Future<void> _fetchCardDetails(String cardNumber) async {
    // Stop scanning while processing
    setState(() {
      isLoading = true;
      isScanning = false;
    });

    try {
      final response = await http.post(
        Uri.parse('http://esit.or.tz/esit/api/get_card_details.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'card_number': cardNumber}),
      );

      print('Scanned Card Number: $cardNumber');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        
        if (decodedResponse['status'] == 'success') {
          setState(() {
            cardDetails = decodedResponse['data'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${decodedResponse['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _resetScan() {
    setState(() {
      cardDetails = null;
      isScanning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetScan,
          ),
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
          if (isScanning && !isLoading) 
            Expanded(
              child: MobileScanner(
                controller: cameraController,
                onDetect: (barcodeCapture) {
                  final String? code = barcodeCapture.barcodes.first.rawValue;
                  if (code != null && code.isNotEmpty) {
                    _fetchCardDetails(code);
                  }
                },
              ),
            ),
          if (isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Fetching card details...'),
                  ],
                ),
              ),
            ),
          if (cardDetails != null)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card Details',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        DetailRow(label: 'First Name', value: cardDetails!['FirstName']),
                        DetailRow(label: 'Last Name', value: cardDetails!['LastName']),
                        DetailRow(label: 'Card Number', value: cardDetails!['CardNumber']),
                        DetailRow(label: 'Card Type', value: cardDetails!['CardType']),
                        DetailRow(label: 'Status', value: cardDetails!['Status']),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: _resetScan,
                            child: const Text('Scan Another Card'),
                          ),
                        ),
                      ],
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

// Helper widget for displaying details
class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}