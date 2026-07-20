import 'package:flutter/material.dart';

import '../controller/lesson_controller.dart';
import '../models/lesson_step.dart';

class LessonResultPanel extends StatelessWidget {
  const LessonResultPanel({super.key, required this.controller});
  final LessonController controller;

  @override
  Widget build(BuildContext context) {
    final result = controller.checkResult;
    if (controller.playground.error != null &&
        controller.lesson.steps[controller.currentStepIndex].stepType ==
            LessonStepType.ui) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('代码解析失败', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SelectableText(controller.playground.error!),
        ],
      );
    }
    if (result == null) {
      return const Center(child: Text('点击“检查”查看每项要求的结果。'));
    }
    if (result.parseError != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('代码解析失败', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SelectableText(result.parseError!),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          result.passed ? '本步骤完成' : '继续完善',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        ...result.results.map(
          (item) => ListTile(
            leading: Icon(
              item.passed ? Icons.check_circle : Icons.cancel,
              color: item.passed ? Colors.green : Colors.red,
            ),
            title: Text(item.requirement.description),
          ),
        ),
      ],
    );
  }
}
