import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScannedDetailsPage extends StatelessWidget {
  final String scannedData;

  const ScannedDetailsPage({super.key, required this.scannedData});

  // Function to update the status in the database
  Future<void> _updateStatus(String cardNumber) async {
    var url = Uri.parse(
        'http://esit.or.tz/esit/api/get_card_details'); // Replace with your API endpoint

    var data = {
      'card_number': cardNumber,
      'status': 'Scanned', // The new status to set
    };

    try {
      var response = await http.post(
        url,
        body: json.encode(data),
        headers: {
          'Content-Type': 'application/json', // Correct Content-Type for JSON
        },
      );

      if (response.statusCode == 200) {
        print('Status updated successfully');
        // You can show a success message here
      } else {
        print('Failed to update status: ${response.statusCode}, ${response.body}');
        // Handle error, maybe show a message to the user
      }
    } catch (e) {
      print('Error occurred while updating status: $e');
      // Handle network errors
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> details = scannedData.split(',');

    String cardNumber = details.isNotEmpty ? details[0] : 'N/A';
    String firstName = details.length > 1 ? details[1] : 'N/A';
    String lastName = details.length > 2 ? details[2] : 'N/A';
    String cardType = details.length > 3 ? details[3] : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName("/scan"));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_box), // Change icon as needed
            onPressed: () {
              Navigator.pushNamed(context, "/generate");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scanned Data',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Card Number: $cardNumber', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('First Name: $firstName', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Last Name: $lastName', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Card Type: $cardType', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _updateStatus(cardNumber); // Update the status
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Status updated to "Scanned"!')),
                      );
                      Navigator.pop(context); // Optionally navigate back
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
