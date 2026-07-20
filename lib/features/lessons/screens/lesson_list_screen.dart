import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/lesson_catalog.dart';
import '../data/lesson_progress_store.dart';
import 'lesson_screen.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({
    super.key,
    this.store,
  });

  final LessonProgressStore? store;

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  late final LessonProgressStore _progressStore;

  @override
  void initState() {
    super.initState();

    // 优先使用外部传入的 Store。
    // 没有传入时，使用 Hive 中的 lesson_progress Box。
    _progressStore = widget.store ??
        LessonProgressStore(
          Hive.box<dynamic>('lesson_progress'),
        );
  }

  Future<void> _openLesson(int index) async {
    final lesson = LessonCatalog.lessons[index];

    if (lesson.comingSoon) {
      return;
    }

    // 等待用户退出课程页面。
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => LessonScreen(
          lesson: lesson,
          store: _progressStore,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    // 课程页面可能完成了步骤，或者执行了“重新学习”。
    // 返回后重新 build，从 Hive 读取最新进度。
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('教材模式'),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: LessonCatalog.lessons.length,
          separatorBuilder: (context, index) {
            return const SizedBox(height: 8);
          },
          itemBuilder: (context, index) {
            final lesson = LessonCatalog.lessons[index];

            // 每次重新构建时，从 Hive 读取这门课程的最新进度。
            final progress = _progressStore.load(lesson.id);

            final completedSteps =
                (progress['completedSteps'] as List?) ?? const [];

            // 防止旧数据或重复数据导致显示超过总步骤数。
            final completed = completedSteps.length.clamp(
              0,
              lesson.steps.length,
            );

            return Card(
              child: InkWell(
                onTap: lesson.comingSoon
                    ? null
                    : () => _openLesson(index),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lesson.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                ),
                                if (lesson.comingSoon)
                                  const Chip(
                                    label: Text('即将推出'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(lesson.description),
                            const SizedBox(height: 8),
                            Text(
                              '${lesson.category} · '
                              '${lesson.difficulty} · '
                              '${lesson.estimatedMinutes} 分钟 · '
                              '${lesson.steps.length} 步 · '
                              '$completed/${lesson.steps.length} 已完成',
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: lesson.tags
                                  .map(
                                    (tag) => Chip(
                                      label: Text(tag),
                                      visualDensity:
                                          VisualDensity.compact,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}