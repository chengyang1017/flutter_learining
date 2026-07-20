import 'package:flutter/material.dart';

import '../controllers/playground_controller.dart';

class CodeEditorPanel extends StatefulWidget {
  const CodeEditorPanel({super.key, required this.controller});
  final PlaygroundController controller;

  @override
  State<CodeEditorPanel> createState() => _CodeEditorPanelState();
}

class _CodeEditorPanelState extends State<CodeEditorPanel> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _editorVerticalController = ScrollController();
  final ScrollController _lineNumberController = ScrollController();

  @override
  void initState() {
    super.initState();
    _editorVerticalController.addListener(_syncLineNumbers);
  }

  void _syncLineNumbers() {
    if (!_lineNumberController.hasClients) return;
    final offset = _editorVerticalController.offset.clamp(
      0.0,
      _lineNumberController.position.maxScrollExtent,
    );
    if ((_lineNumberController.offset - offset).abs() > .5) {
      _lineNumberController.jumpTo(offset);
    }
  }

  @override
  void dispose() {
    _editorVerticalController.removeListener(_syncLineNumbers);
    _horizontalController.dispose();
    _editorVerticalController.dispose();
    _lineNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 700;
    final fontSize = isCompact ? 14.0 : 16.0;
    final inset = isCompact ? 12.0 : 16.0;
    final lineCount = '\n'.allMatches(widget.controller.code).length + 1;
    final codeWidth = isCompact ? 820.0 : 1000.0;

    return ColoredBox(
      color: const Color(0xff17202b),
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 48,
              child: SingleChildScrollView(
                controller: _lineNumberController,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: inset, right: 8),
                child: Text(
                  List.generate(lineCount, (index) => '${index + 1}')
                      .join('\n'),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: fontSize,
                    height: 1.45,
                    color: Colors.white38,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _horizontalController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  key: const ValueKey('code-horizontal-scroll'),
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: codeWidth,
                    child: TextField(
                      controller: widget.controller.textController,
                      scrollController: _editorVerticalController,
                      onChanged: widget.controller.updateCode,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      autocorrect: false,
                      enableSuggestions: false,
                      smartDashesType: SmartDashesType.disabled,
                      smartQuotesType: SmartQuotesType.disabled,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: fontSize,
                        height: 1.45,
                        color: const Color(0xffe6edf3),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(inset),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
