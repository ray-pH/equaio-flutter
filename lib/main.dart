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
    worksheet.introduceExpression(expr: generateExpression(str: 'x + 3 = 5'));
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
    List<ExpressionLine> history =
        seq == null ? [] : seq.getHistory();
    List<TableRow> expressionBlockTableRows = history.mapIndexed((i, line) {
      var (lhs, eq, rhs) = expressionToThreeBlocks(expr: line.expr);
      
      var clickable = i == history.length - 1;
      void callback(Address addr) {
        addressHistory.add(addr);
        if (seq != null) {
          setState(() => possibleActions =
              seq.getPossibleActions(addrVec: addressHistory));
        }
      }
      
      var lhsWidget = lhs == null ? const SizedBox() : ClickableBlock(block: lhs, clickable: clickable, callback: callback);
      var eqWidget = eq == null ? const SizedBox() : ClickableBlock(block: eq, clickable: clickable, callback: callback);
      var rhsWidget = rhs == null ? const SizedBox() : ClickableBlock(block: rhs, clickable: clickable, callback: callback);
      return TableRow(children: [ 
        Align(alignment: Alignment.centerRight, child: lhsWidget),
        eqWidget, 
        Align(alignment: Alignment.centerLeft, child: rhsWidget),
      ]);
    }).toList();
    Widget expressionBlockWidget = Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: expressionBlockTableRows
    );

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

class ClickableBlock extends StatefulWidget {
  final Block block;
  final bool clickable;
  final void Function(Address)? callback;
  const ClickableBlock(
      {required this.block, required this.clickable, this.callback, super.key});
  @override
  State<ClickableBlock> createState() => _ClickableBlock();
}
class _ClickableBlock extends State<ClickableBlock> {
  @override
  Widget build(BuildContext context) {
    return generateBlock(widget.block);
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
    var block = expressionToBlock(expr: widget.expr);
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
                child: ClickableBlock(block: block, clickable: false))
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
