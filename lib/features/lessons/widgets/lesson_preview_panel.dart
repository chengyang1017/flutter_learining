import 'package:flutter/material.dart';

import '../../playground/controllers/playground_controller.dart';
import '../../playground/widgets/preview_panel.dart';
import '../models/lesson_step.dart';

class LessonPreviewPanel extends StatelessWidget {
  const LessonPreviewPanel({
    super.key,
    required this.currentStep,
    required this.playgroundController,
  });

  final LessonStep currentStep;
  final PlaygroundController playgroundController;

  @override
  Widget build(BuildContext context) {
    if (currentStep.stepType == LessonStepType.ui) {
      return PreviewPanel(controller: playgroundController);
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          margin: const EdgeInsets.all(24),
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_tree_outlined, size: 48),
                SizedBox(height: 16),
                Text(
                  '当前步骤是逻辑或数据层代码，没有可视化界面。\n请在“结果”中查看代码检查结果。',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  '_publishPost()\n→ PostService.createPost()\n→ Firebase',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'monospace', height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
