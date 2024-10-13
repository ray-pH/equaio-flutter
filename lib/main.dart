import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:equaio/src/rust/api/equaio_wrapper.dart';
import 'package:equaio/src/rust/api/equaio_type.dart';
import 'package:equaio/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var worksheet = initAlgebraWorksheet(variables: ['x']);
    worksheet.introduceExpression(expr: generateExpression(str: '=(+(x,3),5)'));
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('equaio')),
        body: Center(child: Worksheet(worksheet: worksheet)),
      ),
    );
  }
}

class Worksheet extends StatefulWidget {
  final WorksheetWrapper worksheet;
  const Worksheet({required this.worksheet, super.key});
  @override
  State<Worksheet> createState() => _Worksheet();
}

class _Worksheet extends State<Worksheet> {
  @override
  Widget build(BuildContext context) {
    var seq0 =
        widget.worksheet.getWorkableExpressionSequence(index: BigInt.from(0));
    return ExpressionSequence(seq: seq0);
  }
}

class ExpressionSequence extends StatefulWidget {
  final WorkableExpressionSequenceWrapper? seq;
  const ExpressionSequence({required this.seq, super.key});
  @override
  State<ExpressionSequence> createState() => _ExpressionSequence();
}

class _ExpressionSequence extends State<ExpressionSequence> {
  List<Address> addressHistory = [];
  List<(String, ExpressionWrapper)> possibleActions = [];
  bool _isShowPossibleActions = true;

  @override
  Widget build(BuildContext context) {
    var seq = widget.seq;
    List<(String, ExpressionWrapper)> history =
        seq == null ? [] : seq.getHistory();
    List<Widget> expressionBlockWidgets = history.mapIndexed((i, entry) {
      var (_, expr) = entry;
      return ExpressionBlock(
          expr: expr,
          clickable: i == history.length - 1,
          callback: (Address addr) {
            addressHistory.add(addr);
            if (seq != null) {
              setState(() => possibleActions =
                  seq.getPossibleActions(addrVec: addressHistory));
            }
          });
    }).toList();
    Widget expressionBlockWidget = Column(children: expressionBlockWidgets);

    List<Widget> possibleActionButtons =
        possibleActions.mapIndexed((index, entry) {
      var (actionStr, expr) = entry;
      return PossibleActionButton(
          actionStr: actionStr,
          expr: expr,
          onTap: () {
            bool success = widget.seq?.tryApplyActionByIndex(
                    addrVec: addressHistory, index: BigInt.from(index)) ??
                false;
            if (success) {
              addressHistory.clear();
              possibleActions.clear();
            }
            setState(() => {});
          });
    }).toList();
    Widget possibleActionWidget = Visibility(
        visible: _isShowPossibleActions,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(children: possibleActionButtons),
        ));

    return Column(children: [expressionBlockWidget, possibleActionWidget]);
  }
}

class ExpressionBlock extends StatefulWidget {
  final ExpressionWrapper expr;
  final bool clickable;
  final void Function(Address)? callback;
  const ExpressionBlock(
      {required this.expr, required this.clickable, this.callback, super.key});
  @override
  State<ExpressionBlock> createState() => _ExpressionBlock();
}

class _ExpressionBlock extends State<ExpressionBlock> {
  @override
  Widget build(BuildContext context) {
    var block = expressionToBlock(expr: widget.expr);
    return generateBlock(block);
  }

  Widget generateBlock(Block block) {
    switch (block.blockType) {
      case BlockType.symbol:
        if (widget.clickable) {
          return BlockButton(
            text: block.symbol!,
            onTap: () {
              if (widget.callback != null) {
                widget.callback!(block.address);
              } else {
                print(block.address.path);
                print(block.address.sub);
              }
            },
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Text(block.symbol!),
          );
        }
      case BlockType.fractionContainer:
      case BlockType.horizontalContainer:
        var children = block.children!;
        var childrenWidget = children.map((e) => generateBlock(e)).toList();
        return Row(mainAxisSize: MainAxisSize.min, children: childrenWidget);
    }
  }
}

class PossibleActionButton extends StatefulWidget {
  final String actionStr;
  final ExpressionWrapper expr;
  final VoidCallback onTap;
  const PossibleActionButton(
      {required this.actionStr,
      required this.expr,
      required this.onTap,
      super.key});
  @override
  State<PossibleActionButton> createState() => _PossibleActionButton();
}

class _PossibleActionButton extends State<PossibleActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: Colors.black.withOpacity(0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                padding: const EdgeInsets.all(8),
                child: Text(widget.actionStr)),
            Container(
                padding: const EdgeInsets.all(8),
                child: ExpressionBlock(expr: widget.expr, clickable: false))
          ],
        ),
        // child: AnimatedContainer(
        //   duration: const Duration(milliseconds: 200),
        //   padding: const EdgeInsets.all(8),
        //   decoration: BoxDecoration(
        //     color:
        //         _isHovered ? Colors.black.withOpacity(0.1) : Colors.transparent,
        //     borderRadius: BorderRadius.circular(4),
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Container(
        //           padding: const EdgeInsets.all(8),
        //           child: Text(widget.actionStr)),
        //       Container(
        //           padding: const EdgeInsets.all(8),
        //           child: ExpressionBlock(expr: widget.expr, clickable: false))
        //     ],
        //   ),
        // ),
      ),
    );
  }
}

class BlockButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const BlockButton({required this.text, required this.onTap, super.key});
  @override
  State<BlockButton> createState() => _BlockButton();
}

class _BlockButton extends State<BlockButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                _isHovered ? Colors.black.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
