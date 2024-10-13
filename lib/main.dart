import 'package:flutter/material.dart';
import 'package:equaio/src/rust/frb_generated.dart';
import './main_menu.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Equaio',
      home: MainMenu(),
    );
  }
}
