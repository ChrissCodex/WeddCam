import 'package:flutter/material.dart';

class ScannedDetailsPage extends StatelessWidget {
  final String cardNumber;
  final String firstName;
  final String lastName;
  final String status;

  ScannedDetailsPage({
    required this.cardNumber,
    required this.firstName,
    required this.lastName,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Navigate back to ScanCodePage
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scanned QR Code Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Card Number:', style: TextStyle(fontSize: 18)),
            Text(cardNumber, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            const Text('Full Name:', style: TextStyle(fontSize: 18)),
            Text('$firstName $lastName', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            const Text('Status:', style: TextStyle(fontSize: 18)),
            Text(status, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Scanner'),
            ),
          ],
        ),
      ),
    );
  }
}
