import 'package:flutter/material.dart';

import '../controller/lesson_controller.dart';

class LessonActionBar extends StatelessWidget {
  const LessonActionBar({
    super.key,
    required this.controller,
    required this.onAnswer,
  });
  final LessonController controller;
  final VoidCallback onAnswer;

  @override
  Widget build(BuildContext context) => Material(
        elevation: 8,
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  OutlinedButton(
                      onPressed: controller.currentStepIndex > 0
                          ? () =>
                              controller.goTo(controller.currentStepIndex - 1)
                          : null,
                      child: const Text('上一步')),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                      onPressed: controller.showNextHint,
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text('提示')),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                      onPressed:
                          controller.isChecking ? null : controller.check,
                      icon: const Icon(Icons.fact_check_outlined),
                      label: Text(controller.isChecking ? '检查中…' : '检查')),
                  const SizedBox(width: 8),
                  OutlinedButton(
                      onPressed: onAnswer, child: const Text('标准答案')),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                      onPressed: controller.currentStepIndex <
                              controller.lesson.steps.length - 1
                          ? () =>
                              controller.goTo(controller.currentStepIndex + 1)
                          : null,
                      child: const Text('下一步')),
                ],
              ),
            ),
          ),
        ),
      );
}
