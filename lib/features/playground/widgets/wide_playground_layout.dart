import 'package:flutter/material.dart';

import '../controllers/playground_controller.dart';
import 'code_editor_panel.dart';
import 'error_panel.dart';
import 'preview_panel.dart';

class WidePlaygroundLayout extends StatelessWidget {
  const WidePlaygroundLayout({
    super.key,
    required this.controller,
    required this.toolbar,
  });

  final PlaygroundController controller;
  final Widget toolbar;

  @override
  Widget build(BuildContext context) => Column(
        key: const ValueKey('wide-playground-layout'),
        children: [
          SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Flutter UI Playground',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          ),
          toolbar,
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: LayoutBuilder(
                    builder: (context, constraints) => Column(
                      children: [
                        Expanded(
                          child: CodeEditorPanel(controller: controller),
                        ),
                        ErrorPanel(
                          controller: controller,
                          maxHeight: constraints.maxHeight * .3,
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 4,
                  child: PreviewPanel(controller: controller),
                ),
              ],
            ),
          ),
        ],
      );
}
