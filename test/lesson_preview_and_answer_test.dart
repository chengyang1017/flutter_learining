import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_playground/features/lessons/controller/lesson_controller.dart';
import 'package:flutter_ui_playground/features/lessons/data/author_answer_repository.dart';
import 'package:flutter_ui_playground/features/lessons/data/lesson_catalog.dart';
import 'package:flutter_ui_playground/features/lessons/data/lesson_progress_store.dart';
import 'package:flutter_ui_playground/features/lessons/widgets/lesson_preview_panel.dart';
import 'package:flutter_ui_playground/features/lessons/widgets/lesson_result_panel.dart';
import 'package:flutter_ui_playground/features/playground/widgets/device_preview_frame.dart';

void main() {
  final lesson = LessonCatalog.lessons.first;

  testWidgets('UI 步骤预览只显示设备渲染界面', (tester) async {
    final controller = LessonController(
      lesson: lesson,
      store: LessonProgressStore.memory(),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonPreviewPanel(
            currentStep: lesson.steps.first,
            playgroundController: controller.playground,
          ),
        ),
      ),
    );
    expect(find.byType(DevicePreviewFrame), findsOneWidget);
    expect(find.byType(LessonResultPanel), findsNothing);
    expect(find.text('继续完善'), findsNothing);
  });

  testWidgets('非 UI 步骤预览只显示不可视化说明', (tester) async {
    final controller = LessonController(
      lesson: lesson,
      store: LessonProgressStore.memory(),
    );
    addTearDown(controller.dispose);
    await controller.goTo(1);
    await controller.check();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonPreviewPanel(
            currentStep: lesson.steps[1],
            playgroundController: controller.playground,
          ),
        ),
      ),
    );
    expect(find.textContaining('没有可视化界面'), findsOneWidget);
    expect(find.textContaining('请在“结果”中查看'), findsOneWidget);
    expect(find.byType(DevicePreviewFrame), findsNothing);
    expect(find.byType(LessonResultPanel), findsNothing);
    expect(find.text('继续完善'), findsNothing);
  });

  testWidgets('作者 PostService asset 按原文读取并缓存', (tester) async {
    final path = lesson.steps[2].standardAnswerAssets['post_service.dart']!;
    expect(
      path,
      'assets/lessons/create_post/advanced_images/answers/post_service.dart',
    );
    final repository = AuthorAnswerRepository();
    final first = await repository.load(path);
    final second = await repository.load(path);
    expect(first.isAvailable, isTrue);
    expect(identical(first, second), isTrue);
    expect(first.code, contains('Future<void> createPost({'));
    expect(
        first.code, contains('Future<String> _getCurrentAuthorName() async'));
    expect(first.code, contains('// Firestore 写入失败或部分图片上传失败时，清理已经上传的图片。'));
    expect(first.code, contains('rethrow;'));
    expect(first.code, isNot(contains('watchPosts')));
    expect(first.code, isNot(contains('toggleLike')));
    expect(first.code, isNot(contains('deletePost')));
  });

  testWidgets('不存在的作者答案保持尚未录入', (tester) async {
    final answer = await AuthorAnswerRepository().load(
      'assets/lessons/not-recorded.dart',
    );
    expect(answer.status, AuthorAnswerStatus.notRecorded);
    expect(answer.code, isNull);
  });
}
