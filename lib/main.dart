import 'package:agora_video/pages/index.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AgoraApp());
}

class AgoraApp extends StatelessWidget {
  const AgoraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agora App',
      theme: ThemeData(primarySwatch: Colors.purple),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(primarySwatch: Colors.purple),
      home: const IndexPage(),
    );
  }
}
