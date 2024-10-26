// // database_helper.dart
// import 'package:mysql1/mysql1.dart';

// class DatabaseHelper {
//   static DatabaseHelper? _instance;
//   static MySqlConnection? _connection;
  
//   final ConnectionSettings settings = ConnectionSettings(
//     host: 'your_host',
//     port: 3306,
//     user: 'your_username',
//     password: 'your_password',
//     db: 'your_database_name'
//   );

//   DatabaseHelper._();

//   static DatabaseHelper get instance {
//     _instance ??= DatabaseHelper._();
//     return _instance!;
//   }

//   Future<MySqlConnection> get connection async {
//     if (_connection == null) {
//       _connection = await MySqlConnection.connect(settings);
//     }
//     return _connection!;
//   }

//   Future<Map<String, dynamic>> checkQRStatus(String qrCode) async {
//     try {
//       final conn = await connection;
//       var results = await conn.query(
//         'SELECT * FROM qr_codes WHERE qr_code = ?',
//         [qrCode]
//       );
      
//       if (results.isEmpty) {
//         return {'error': 'QR Code not found'};
//       }

//       var row = results.first;
//       return {
//         'id': row['id'],
//         'qr_code': row['qr_code'],
//         'status': row['status'],
//         'details': row['details'],
//         'scan_time': row['scan_time']?.toString(),
//         // Add other fields as needed
//       };
//     } catch (e) {
//       return {'error': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> updateQRStatus(String qrCode) async {
//     try {
//       final conn = await connection;
//       await conn.query(
//         'UPDATE qr_codes SET status = ?, scan_time = NOW() WHERE qr_code = ?',
//         ['Scanned', qrCode]
//       );
      
//       // Fetch updated record
//       return await checkQRStatus(qrCode);
//     } catch (e) {
//       return {'error': e.toString()};
//     }
//   }

//   Future<void> closeConnection() async {
//     await _connection?.close();
//     _connection = null;
//   }
// }

// // scan_page.dart
// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'database_helper.dart';

// class ScanPage extends StatefulWidget {
//   @override
//   _ScanPageState createState() => _ScanPageState();
// }

// class _ScanPageState extends State<ScanPage> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;
//   bool isScanning = true;
//   String scanResult = '';
//   final dbHelper = DatabaseHelper.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('QR Scanner'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             flex: 5,
//             child: QRView(
//               key: qrKey,
//               onQRViewCreated: _onQRViewCreated,
//             ),
//           ),
//           Expanded(
//             flex: 2,
//             child: Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: SingleChildScrollView(
//                   child: Text(
//                     scanResult,
//                     style: TextStyle(fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) async {
//       if (!isScanning) return;
      
//       isScanning = false;
//       controller.pauseCamera();
      
//       await processQRCode(scanData.code ?? '');
//     });
//   }

//   Future<void> processQRCode(String qrData) async {
//     try {
//       // Check QR status
//       final response = await dbHelper.checkQRStatus(qrData);
      
//       if (response['error'] != null) {
//         setState(() {
//           scanResult = 'Error: ${response['error']}';
//         });
//         return;
//       }

//       if (response['status'] == 'Scanned') {
//         setState(() {
//           scanResult = 'QR Code already scanned!\n\nDetails:\n' +
//               formatDetails(response);
//         });
//       } else {
//         // Update status to 'Scanned'
//         final updateResponse = await dbHelper.updateQRStatus(qrData);
        
//         if (updateResponse['error'] != null) {
//           setState(() {
//             scanResult = 'Error updating status: ${updateResponse['error']}';
//           });
//           return;
//         }

//         setState(() {
//           scanResult = 'Successfully scanned!\n\nDetails:\n' +
//               formatDetails(updateResponse);
//         });
//       }
//     } catch (e) {
//       setState(() {
//         scanResult = 'Error: ${e.toString()}';
//       });
//     } finally {
//       // Reset after 3 seconds and resume scanning
//       Future.delayed(Duration(seconds: 3), () {
//         if (mounted) {
//           setState(() {
//             isScanning = true;
//             controller?.resumeCamera();
//           });
//         }
//       });
//     }
//   }

//   String formatDetails(Map<String, dynamic> data) {
//     final excludeKeys = ['error', 'success'];
//     return data.entries
//         .where((e) => !excludeKeys.contains(e.key))
//         .map((e) => '${e.key}: ${e.value}')
//         .join('\n');
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     dbHelper.closeConnection();
//     super.dispose();
//   }
// }