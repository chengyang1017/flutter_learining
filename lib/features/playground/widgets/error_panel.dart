import 'package:flutter/material.dart';

import '../controllers/playground_controller.dart';

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({
    super.key,
    required this.controller,
    required this.maxHeight,
  });

  final PlaygroundController controller;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    if (controller.error == null && controller.warnings.isEmpty) {
      return const SizedBox.shrink();
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Material(
        color: Theme.of(context).colorScheme.errorContainer,
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Icon(
            controller.error == null
                ? Icons.warning_amber
                : Icons.error_outline,
            color: controller.error == null ? Colors.orange : Colors.red,
          ),
          title: Text(
            controller.error == null
                ? '警告 (${controller.warnings.length})'
                : '解析错误',
          ),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight - 56),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  controller.error ?? controller.warnings.join('\n'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
