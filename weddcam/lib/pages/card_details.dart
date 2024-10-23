

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanDetailPage extends StatelessWidget {
  final Map<String, dynamic> cardDetails; // Details from the scan

  const ScanDetailPage({Key? key, required this.cardDetails}) : super(key: key);

  // Function to confirm the scan by sending an update request
  Future<void> _confirmScan(BuildContext context) async {
    var url = Uri.parse('http://esit.or.tz/esit/api/update_card_status.php'); // Replace with your actual update API URL

    try {
      // Sending a POST request to update the card status
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'card_number': cardDetails['CardNumber'], // Unique card identifier
          'status': 'Scanned', // Status to update to
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scan confirmed successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${decodedResponse['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // Navigate back to the ScanCodePage
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('First Name: ${cardDetails['FirstName'] ?? "N/A"}'),
            Text('Last Name: ${cardDetails['LastName'] ?? "N/A"}'),
            Text('Card Number: ${cardDetails['CardNumber'] ?? "N/A"}'),
            Text('Card Type: ${cardDetails['CardType'] ?? "N/A"}'),
            Text('Status: ${cardDetails['Status'] ?? "N/A"}'),
            const SizedBox(height: 30), // Space between details and button
            ElevatedButton(
              onPressed: () {
                _confirmScan(context); // Confirm scan when button is pressed
              },
              child: const Text('Confirm Scan'),
            ),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';

// class ScanDetailPage extends StatelessWidget {
//   final Map<String, dynamic> cardDetails; // Details from the scan

//   const ScanDetailPage({Key? key, required this.cardDetails}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan Details'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.qr_code_scanner),
//             onPressed: () {
//               // Navigate back to the ScanCodePage
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('First Name: ${cardDetails['FirstName'] ?? "N/A"}'),
//             Text('Last Name: ${cardDetails['LastName'] ?? "N/A"}'),
//             Text('Card Number: ${cardDetails['CardNumber'] ?? "N/A"}'),
//             Text('Card Type: ${cardDetails['CardType'] ?? "N/A"}'),
//             Text('Status: ${cardDetails['Status'] ?? "N/A"}'),
//             const SizedBox(height: 30), // Space between details and button
//             ElevatedButton(
//               onPressed: () {
//                 // Confirmation logic can go here
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Scan confirmed!')),
//                 );
//               },
//               child: const Text('Confirm Scan'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
