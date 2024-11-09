import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QRCodeGenerator(),
    );
  }
}

class QRCodeGenerator extends StatefulWidget {
  @override
  _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  String qrData = "";
  Timer? qrTimer;

  @override
  void initState() {
    super.initState();
    startQrGeneration();
  }

  @override
  void dispose() {
    qrTimer?.cancel();
    super.dispose();
  }

  void startQrGeneration() {
    qrTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      generateAndUploadQr();
    });
    generateAndUploadQr(); // Genera el QR inmediatamente al iniciar
  }

  void generateAndUploadQr() async {
    setState(() {
      qrData = DateTime.now().millisecondsSinceEpoch.toString(); // Datos únicos del QR
    });

    DateTime expirationTime = DateTime.now().add(Duration(minutes: 1));

    // Sube el QR y la hora de expiración a Firebase
    await FirebaseFirestore.instance.collection('qrCodes').doc('currentQr').set({
      'qrData': qrData,
      'expirationTime': expirationTime,
      'scanCount': 0,
    });
  }

  Future<void> validateAndIncrementScan(String scannedQrData) async {
    DocumentSnapshot qrDoc = await FirebaseFirestore.instance.collection('qrCodes').doc('currentQr').get();

    if (qrDoc.exists) {
      DateTime expirationTime = (qrDoc['expirationTime'] as Timestamp).toDate();
      if (DateTime.now().isBefore(expirationTime) && qrDoc['qrData'] == scannedQrData) {
        // Si es válido, incrementa el contador de escaneos
        await FirebaseFirestore.instance.collection('qrCodes').doc('currentQr').update({
          'scanCount': FieldValue.increment(1),
        });
        print("Código QR escaneado correctamente.");
      } else {
        print("QR inválido o expirado.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Generador de QR dinámico")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            qrData.isNotEmpty
                ? QrImage(
                    data: qrData,
                    size: 200,
                    version: QrVersions.auto,
                  )
                : CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              "Código QR generado:\n $qrData",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
