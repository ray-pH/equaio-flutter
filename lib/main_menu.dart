import 'package:flutter/material.dart';
import 'package:equaio/src/rust/api/equaio_wrapper.dart';
import './worksheet.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equaio')),
      body: Center(
        child:
          ElevatedButton(
            child: const Text('Worksheet'), 
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DefaultWorksheet()));
            }
          )
      ),
    );
  }
}

class DefaultWorksheet extends StatelessWidget {
  const DefaultWorksheet({super.key});
  
  @override
  Widget build(BuildContext context) {
    var worksheet = initAlgebraWorksheet(variables: ['x']);
    worksheet.introduceExpression(expr: generateExpression(str: 'x + 3 = 5'));
    return Scaffold(
      appBar: AppBar(title: const Text('equaio')),
      body: Center(child: Worksheet(worksheet: worksheet)),
    );
  }
}
