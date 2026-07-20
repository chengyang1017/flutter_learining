import 'package:flutter/material.dart';

import '../../playground/widgets/code_editor_panel.dart';
import '../controller/lesson_controller.dart';
import '../models/lesson_step.dart';

class LessonCodePanel extends StatelessWidget {
  const LessonCodePanel({
    super.key,
    required this.controller,
    this.onRun,
  });

  final LessonController controller;
  final Future<void> Function()? onRun;

  @override
  Widget build(BuildContext context) {
    final isUiStep =
        controller.lesson.steps[controller.currentStepIndex].stepType ==
            LessonStepType.ui;
    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    itemCount: controller.availableFiles.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final file = controller.availableFiles[index];
                      return ChoiceChip(
                        label: Text(file),
                        selected: controller.currentFile == file,
                        onSelected: (_) => controller.switchFile(file),
                      );
                    },
                  ),
                ),
                if (isUiStep)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilledButton.icon(
                      key: const ValueKey('lesson-run-button'),
                      onPressed: controller.isRunning
                          ? null
                          : () => (onRun ??
                              () async {
                                await controller.runCurrentUi();
                              })(),
                      icon: controller.isRunning
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(controller.isRunning ? '渲染中…' : '运行'),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(child: CodeEditorPanel(controller: controller.playground)),
      ],
    );
  }
}
