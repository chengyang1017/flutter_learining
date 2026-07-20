import 'package:flutter/material.dart';

import '../controller/lesson_controller.dart';
import '../data/lesson_progress_store.dart';
import '../data/author_answer_repository.dart';
import '../models/lesson.dart';
import '../widgets/lesson_action_bar.dart';
import '../widgets/lesson_code_panel.dart';
import '../widgets/lesson_result_panel.dart';
import '../widgets/lesson_preview_panel.dart';
import '../widgets/lesson_task_panel.dart';
import '../widgets/standard_answer_dialog.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson, required this.store});
  final Lesson lesson;
  final LessonProgressStore store;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final LessonController controller;
  late final AuthorAnswerRepository answerRepository;
  @override
  void initState() {
    super.initState();
    answerRepository = AuthorAnswerRepository();
    controller = LessonController(lesson: widget.lesson, store: widget.store)
      ..addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => controller.isComplete
                ? _LessonCompletionView(controller: controller)
                : constraints.maxWidth < 700
                    ? DefaultTabController(
                        length: 4,
                        child: _CompactLesson(controller: controller))
                    : _WideLesson(controller: controller),
          ),
        ),
        bottomNavigationBar: controller.isComplete
            ? null
            : LessonActionBar(
                controller: controller,
                onAnswer: () => showStandardAnswerDialog(
                  context,
                  controller,
                  answerRepository,
                ),
              ),
      );
}

class _LessonCompletionView extends StatelessWidget {
  const _LessonCompletionView({required this.controller});
  final LessonController controller;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Icon(
                Icons.emoji_events,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '课程完成：${controller.lesson.title}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: SelectableText(
                    'TextField / 发布按钮\n→ _publishPost()\n→ PostService.createPost()\n→ Firebase Auth、Storage、Firestore',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'monospace', height: 1.7),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
  children: [
    Expanded(
      child: OutlinedButton.icon(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back),
        label: const Text('返回课程列表'),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: FilledButton.icon(
        onPressed: controller.restartLesson,
        icon: const Icon(Icons.replay),
        label: const Text('重新学习'),
      ),
    ),
  ],
),
            ],
          ),
        ),
      );
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.controller});
  final LessonController controller;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: Row(children: [
          IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back)),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(controller.lesson.title,
                    style: Theme.of(context).textTheme.titleLarge),
                Text(
                    '步骤 ${controller.currentStepIndex + 1}/${controller.lesson.steps.length} · 已完成 ${controller.completedSteps.length}'),
              ])),
          SizedBox(
              width: 96,
              child: LinearProgressIndicator(
                  value: controller.completedSteps.length /
                      controller.lesson.steps.length)),
        ]),
      );
}

class _CompactLesson extends StatelessWidget {
  const _CompactLesson({required this.controller});
  final LessonController controller;
  @override
  Widget build(BuildContext context) => Column(
        key: const ValueKey('compact-lesson-layout'),
        children: [
          _LessonHeader(controller: controller),
          const TabBar(isScrollable: true, tabs: [
            Tab(text: '任务'),
            Tab(text: '代码'),
            Tab(text: '预览'),
            Tab(text: '结果')
          ]),
          Expanded(
              child: TabBarView(children: [
            LessonTaskPanel(controller: controller),
            LessonCodePanel(
              controller: controller,
              onRun: () async {
                final succeeded = await controller.runCurrentUi();
                if (!context.mounted) return;
                DefaultTabController.of(context).animateTo(succeeded ? 2 : 3);
              },
            ),
            LessonPreviewPanel(
              currentStep: controller.lesson.steps[controller.currentStepIndex],
              playgroundController: controller.playground,
            ),
            LessonResultPanel(controller: controller),
          ])),
        ],
      );
}

class _WideLesson extends StatelessWidget {
  const _WideLesson({required this.controller});
  final LessonController controller;
  @override
  Widget build(BuildContext context) => Column(
        key: const ValueKey('wide-lesson-layout'),
        children: [
          _LessonHeader(controller: controller),
          Expanded(
              child: Row(children: [
            Expanded(
                flex: 6,
                child: Column(children: [
                  SizedBox(
                      height: 220,
                      child: LessonTaskPanel(controller: controller)),
                  const Divider(height: 1),
                  Expanded(child: LessonCodePanel(controller: controller)),
                  SizedBox(
                      height: 170,
                      child: LessonResultPanel(controller: controller)),
                ])),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 4,
              child: LessonPreviewPanel(
                currentStep:
                    controller.lesson.steps[controller.currentStepIndex],
                playgroundController: controller.playground,
              ),
            ),
          ])),
        ],
      );
}
