import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding and base64 conversion
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:printing/printing.dart'; // Import the printing package
import 'package:pdf/widgets.dart'
    as pw; // Import pdf widgets for creating the document

class GenerateCodePage extends StatefulWidget {
  const GenerateCodePage({super.key});

  @override
  State<GenerateCodePage> createState() => _GenerateCodePageState();
}

class _GenerateCodePageState extends State<GenerateCodePage> {
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  String cardType = 'Single'; // Default to single card type
  GlobalKey globalKey = GlobalKey(); // GlobalKey to capture the QR code

  // Function to capture QR code as image and convert to base64
  Future<String> _capturePng() async {
    try {
      RenderRepaintBoundary? boundary = globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      // Ensure boundary is not null
      if (boundary == null) {
        print('Boundary is null'); // Debugging line
        return '';
      }

      ui.Image image =
          await boundary.toImage(pixelRatio: 3.0); // Capture the image
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      String base64Image = base64Encode(pngBytes); // Convert to base64 string
      return base64Image;
    } catch (e) {
      print('Error capturing PNG: $e'); // Debugging line
      return '';
    }
  }

  // Function to send data to the server
  Future<void> _sendDataToServer(String cardNumber, String firstName,
      String lastName, String cardType, String base64Image) async {
    var url = Uri.parse(
        'https://theparrot.co.tz/mis.theparrot.co.tz/api/endpoint_api.php'); // Replace with your server's URL

    // Data to send
    var data = {
      'card_number': cardNumber,
      'first_name': firstName,
      'last_name': lastName,
      'card_type': cardType,
      'qr_code_image': base64Image // Add the base64 image here
    };

    try {
      // Send POST request
      var response = await http.post(
        url,
        body: json.encode(data),
        headers: {
          'Content-Type': 'application/json', // Correct Content-Type for JSON
        },
      );

      // Check response status code
      if (response.statusCode == 200) {
        print('Data sent to server successfully');
        print('Response: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data sent successfully!')),
        );
      } else {
        print('Failed to send data: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send data to server')),
        );
      }
    } catch (e) {
      print('Error occurred while sending data: $e'); // Debugging line
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred while sending data: $e')),
      );
    }
  }

  // Function to print the QR code
  Future<void> _printQrCode() async {
    // Use WidgetsBinding to ensure the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final image = await _capturePng(); // Capture QR code image
        if (image.isEmpty) {
          throw Exception(
              'QR code image is empty'); // Ensure the image is not empty
        }

        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async {
            final pdfDocument = pw.Document();

            pdfDocument.addPage(
              pw.Page(
                build: (pw.Context context) => pw.Center(
                  child: pw.Image(pw.MemoryImage(base64Decode(image))),
                ),
              ),
            );

            return pdfDocument.save(); // Return the PDF bytes
          },
        );
      } catch (e) {
        print('Error during printing: $e'); // Debugging line
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during printing: $e')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Wedding QR Code'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popAndPushNamed(
                  context, "/scan"); // Switch to scan page
            },
            icon: const Icon(Icons.qr_code_scanner),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              _printQrCode(); // Call the print function
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: cardNumberController,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: cardType,
              decoration: InputDecoration(
                labelText: 'Card Type',
                border: OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              hint: const Text('Select Card Type'),
              items: ['Single', 'Double'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => cardType = newValue);
                }
              },
            ),

            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: () async {
                if (cardNumberController.text.isNotEmpty &&
                    firstNameController.text.isNotEmpty &&
                    lastNameController.text.isNotEmpty) {
                  // Call setState to rebuild the widget
                  setState(() {}); // Ensure the QR code gets rendered

                  // Add a slight delay to allow the UI to rebuild
                  await Future.delayed(Duration(milliseconds: 100));

                  // Capture the QR code as base64
                  String base64Image = await _capturePng();

                  // If the base64Image is empty, show an error message
                  if (base64Image.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to generate QR code image.'),
                      ),
                    );
                    return;
                  }

                  // Send data to server
                  _sendDataToServer(
                    cardNumberController.text,
                    firstNameController.text,
                    lastNameController.text,
                    cardType,
                    base64Image,
                  );
                } else {
                  // Show error if any input is missing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please fill all fields before generating the QR code.'),
                    ),
                  );
                }
              },
              child: const Text('Generate QR Code'),
            ),
            const SizedBox(height: 8),
            // Conditional display of QR code
            if (cardNumberController.text.isNotEmpty &&
                firstNameController.text.isNotEmpty &&
                lastNameController.text.isNotEmpty) ...[
              RepaintBoundary(
                key: globalKey,
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: QrImageView(
                    data:
                        '${cardNumberController.text},${firstNameController.text},${lastNameController.text},$cardType',
                    version: QrVersions.auto,
                    size: 180.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
