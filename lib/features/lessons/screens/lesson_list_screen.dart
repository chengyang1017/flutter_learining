import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/lesson_catalog.dart';
import '../data/lesson_progress_store.dart';
import 'lesson_screen.dart';

class LessonListScreen extends StatelessWidget {
  const LessonListScreen({super.key, this.store});
  final LessonProgressStore? store;

  @override
  Widget build(BuildContext context) {
    final progressStore =
        store ?? LessonProgressStore(Hive.box<dynamic>('lesson_progress'));
    return Scaffold(
      appBar: AppBar(title: const Text('教材模式')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: LessonCatalog.lessons.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final lesson = LessonCatalog.lessons[index];
            final progress = progressStore.load(lesson.id);
            final completed =
                (progress['completedSteps'] as List?)?.length ?? 0;
            return Card(
              child: InkWell(
                onTap: lesson.comingSoon
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => LessonScreen(
                                lesson: lesson, store: progressStore),
                          ),
                        ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    CircleAvatar(child: Text('${index + 1}')),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Row(children: [
                            Expanded(
                                child: Text(lesson.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium)),
                            if (lesson.comingSoon)
                              const Chip(label: Text('即将推出'))
                          ]),
                          const SizedBox(height: 4),
                          Text(lesson.description),
                          const SizedBox(height: 8),
                          Text(
                              '${lesson.category} · ${lesson.difficulty} · ${lesson.estimatedMinutes} 分钟 · ${lesson.steps.length} 步 · $completed/${lesson.steps.length} 已完成'),
                          const SizedBox(height: 8),
                          Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: lesson.tags
                                  .map((tag) => Chip(
                                      label: Text(tag),
                                      visualDensity: VisualDensity.compact))
                                  .toList()),
                        ])),
                    const Icon(Icons.chevron_right),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
