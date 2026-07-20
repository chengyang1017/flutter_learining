import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/lesson_controller.dart';
import '../data/author_answer_repository.dart';

Future<void> showStandardAnswerDialog(
  BuildContext context,
  LessonController controller,
  AuthorAnswerRepository repository,
) async {
  await controller.markAnswerViewed();
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => _StandardAnswerDialog(
      controller: controller,
      repository: repository,
    ),
  );
}

class _StandardAnswerDialog extends StatefulWidget {
  const _StandardAnswerDialog({
    required this.controller,
    required this.repository,
  });

  final LessonController controller;
  final AuthorAnswerRepository repository;

  @override
  State<_StandardAnswerDialog> createState() => _StandardAnswerDialogState();
}

class _StandardAnswerDialogState extends State<_StandardAnswerDialog> {
  late String selectedFile;

  @override
  void initState() {
    super.initState();
    final step =
        widget.controller.lesson.steps[widget.controller.currentStepIndex];
    selectedFile =
        step.standardAnswerAssets.keys.firstOrNull ?? step.currentFile;
  }

  @override
  Widget build(BuildContext context) {
    final step =
        widget.controller.lesson.steps[widget.controller.currentStepIndex];
    final files = step.standardAnswerAssets.isEmpty
        ? step.relatedFiles
        : step.standardAnswerAssets.keys.toList();
    final path = step.standardAnswerAssets[selectedFile];
    final answerFuture = path == null
        ? Future<AuthorAnswer>.value(const AuthorAnswer.notRecorded())
        : widget.repository.load(path);
    return AlertDialog(
      title: const Text('课程作者参考答案'),
      content: SizedBox(
        width: 720,
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('参考答案不是唯一正确答案；检查规则独立于答案代码。'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: files
                  .map(
                    (file) => ChoiceChip(
                      label: Text(file),
                      selected: selectedFile == file,
                      onSelected: (_) => setState(() => selectedFile = file),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<AuthorAnswer>(
                future: answerFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final answer = snapshot.data!;
                  if (!answer.isAvailable) {
                    return const Center(
                      child: Text('该部分标准答案尚未由课程作者录入。'),
                    );
                  }
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        answer.code!,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        FutureBuilder<AuthorAnswer>(
          future: answerFuture,
          builder: (context, snapshot) {
            final answer = snapshot.data;
            final enabled = answer?.isAvailable ?? false;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: enabled
                      ? () =>
                          Clipboard.setData(ClipboardData(text: answer!.code!))
                      : null,
                  icon: const Icon(Icons.copy),
                  label: const Text('复制'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: enabled
                      ? () => _confirmReplace(context, answer!.code!)
                      : null,
                  child: const Text('替换当前文件'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _confirmReplace(BuildContext context, String code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (confirmContext) => AlertDialog(
        title: Text('替换 $selectedFile？'),
        content: const Text('只会替换当前选中的文件，不会运行代码或完成步骤。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(confirmContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(confirmContext, true),
            child: const Text('确认替换'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.controller.replaceFileWithAuthorCode(selectedFile, code);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
