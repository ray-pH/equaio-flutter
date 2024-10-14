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
    return MaterialApp(
      title: 'Equaio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          // seedColor: const Color(0xFFEF7B45),
          // primary: const Color(0xFFEF7B45),
          // seedColor: const Color(0xFFFF6600),
          // primary: const Color(0xFFFF6600),
          // seedColor: const Color(0xFFE4552C),
          // primary: const Color(0xFFE4552C),
          seedColor: const Color(0xFFF06A31),
          primary: const Color(0xFFF06A31),
        ),    
      ),
      home: const MainMenu(),
    );
  }
}
