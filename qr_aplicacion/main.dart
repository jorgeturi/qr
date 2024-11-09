import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hola Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Mi Primera App Flutter'),
        ),
        body: Center(
          child: Text(
            '¡Hola, Flutter!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
