import 'package:flutter/material.dart';
import 'package:equaio/src/rust/api/equaio_wrapper.dart';
import './worksheet.dart';

const categories = [
  Category(name: 'Algebra (Step by Step)', worksheet: [
    WorksheetData(
        label: 'Solve for x',
        sublabel: 'x + 3 = 5',
        rule: 'algebra',
        variables: ['x'],
        initialExpressions: ['x + 3 = 5']),
    WorksheetData(
        label: 'Solve for x',
        sublabel: '2x - 1 = 3',
        rule: 'algebra',
        variables: ['x'],
        initialExpressions: ['(2 * x) - 1 = 3']),
    WorksheetData(
        label: 'Simplify the expression',
        rule: 'algebra',
        variables: ['x'],
        initialExpressions: ['(6 * x) + (-4) + (3 * x) + 1']),
    WorksheetData(
        label: 'SLETV example',
        rule: 'algebra',
        variables: ['x', 'y'],
        initialExpressions: ['x + y = 3', 'x - y = 1']),
  ]),
  Category(name: 'Algebra', worksheet: [
    WorksheetData(
        label: 'Solve for x',
        sublabel: 'x + 3 = 5',
        rule: 'algebra_simplify',
        variables: ['x'],
        initialExpressions: ['x + 3 = 5']),
    WorksheetData(
        label: 'Solve for x',
        sublabel: '2x - 1 = 3',
        rule: 'algebra_simplify',
        variables: ['x'],
        initialExpressions: ['(2*x) - 1 = 3']),
    WorksheetData(
        label: 'SLETV example',
        rule: 'algebra_simplify',
        variables: ['x', 'y'],
        initialExpressions: ['x + y = 3', 'x - y = 1']),
  ]),
  Category(name: 'Logic', worksheet: [
    WorksheetData(
        label: 'Simplify the expression',
        rule: 'algebra_simplify',
        variables: ['P', 'Q'],
        initialExpressions: ['(~P | Q) & (P | Q)']),
  ]),
];

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Equaio')),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: buildCategories(context),
        ));
  }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Equaio')),
  //     body: Center(
  //         child: ElevatedButton(
  //             child: const Text('Worksheet'),
  //             onPressed: () {
  //               Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                       builder: (context) => const DefaultWorksheet()));
  //             })),
  //   );
  // }

  Widget buildCategories(BuildContext context) {
    List<Widget> categoriesWidgets =
        categories.map((c) => buildCategory(context, c)).toList();
    return Column(children: categoriesWidgets);
  }

  Widget buildCategory(BuildContext context, Category category) {
    Widget header = Text(category.name);
    List<Widget> worksheets = category.worksheet.map((wsData) {
      Widget label = Text(wsData.label);
      Widget sublabel =
          wsData.sublabel != null ? Text(wsData.sublabel!) : Container();
      return FilledButton.tonal(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        WorksheetContainer(worksheetData: wsData)));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [label, sublabel]),
          ));
    }).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(children: [header, ...worksheets]),
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
