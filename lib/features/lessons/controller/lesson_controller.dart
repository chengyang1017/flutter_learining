import 'package:flutter/foundation.dart';

import '../../playground/controllers/playground_controller.dart';
import '../checking/lesson_checker.dart';
import '../data/lesson_progress_store.dart';
import '../models/lesson.dart';
import '../models/lesson_check_result.dart';
import '../models/lesson_step.dart';

class LessonController extends ChangeNotifier {
  LessonController(
      {required this.lesson, required this.store, LessonChecker? checker})
      : checker = checker ?? LessonChecker(),
        playground = PlaygroundController() {
    playground.addListener(_relay);
    _restore();
  }
  final Lesson lesson;
  final LessonProgressStore store;
  final LessonChecker checker;
  final PlaygroundController playground;
  int currentStepIndex = 0;
  int visibleHintCount = 0;
  int attempts = 0;
  bool viewedAnswer = false;
  bool isRunning = false;
  bool isChecking = false;
  Set<String> completedSteps = {};
  Map<String, String> lastCode = {};
  Map<String, String> fileCodes = {};
  late String currentFile;
  LessonCheckResult? checkResult;
  bool get isComplete =>
      lesson.steps.isNotEmpty &&
      lesson.steps.every((step) => completedSteps.contains(step.id));

  void _relay() => notifyListeners();
  void _restore() {
    final data = store.load(lesson.id);
    currentStepIndex =
        (data['currentStep'] as int?)?.clamp(0, lesson.steps.length - 1) ?? 0;
    completedSteps =
        Set<String>.from(data['completedSteps'] as List? ?? const []);
    lastCode = Map<String, String>.from(data['lastCode'] as Map? ?? const {});
    fileCodes = Map<String, String>.from(data['fileCodes'] as Map? ?? const {});
    attempts = data['attempts'] as int? ?? 0;
    viewedAnswer = data['viewedAnswer'] as bool? ?? false;
    _loadStep();
  }

  void _loadStep() {
    final step = lesson.steps[currentStepIndex];
    currentFile = step.currentFile;
    final code =
        fileCodes[currentFile] ?? lastCode[step.id] ?? step.starterCode;
    fileCodes.putIfAbsent(currentFile, () => code);
    playground.textController.text = code;
    _refreshPreview();
    visibleHintCount = 0;
    checkResult = null;
  }

  Future<void> _save() => store.save(lesson.id, {
        'currentStep': currentStepIndex,
        'completedSteps': completedSteps.toList(),
        'lastCode': lastCode,
        'fileCodes': fileCodes,
        'attempts': attempts,
        'viewedAnswer': viewedAnswer,
      });
  Future<void> check() async {
    if (isChecking) return;
    isChecking = true;
    notifyListeners();
    attempts++;
    _captureCode();
    try {
      checkResult = checker.checkStep(
        playground.code,
        lesson.steps[currentStepIndex],
      );
      if (checkResult!.passed) {
        completedSteps.add(lesson.steps[currentStepIndex].id);
      }
      await _save();
    } finally {
      isChecking = false;
      notifyListeners();
    }
  }

  Future<bool> runCurrentUi() async {
    if (isRunning ||
        lesson.steps[currentStepIndex].stepType != LessonStepType.ui) {
      return false;
    }
    isRunning = true;
    notifyListeners();
    try {
      await Future<void>.delayed(Duration.zero);
      playground.runCode();
      return playground.error == null;
    } finally {
      isRunning = false;
      notifyListeners();
    }
  }

  void showNextHint() {
    final max = lesson.steps[currentStepIndex].hints.length;
    if (visibleHintCount < max) visibleHintCount++;
    notifyListeners();
  }

  Future<void> markAnswerViewed() async {
    viewedAnswer = true;
    await _save();
    notifyListeners();
  }

  Future<void> replaceFileWithAuthorCode(String file, String code) async {
    _captureCode();
    currentFile = file;
    fileCodes[file] = code;
    playground.textController.text = code;
    lastCode[lesson.steps[currentStepIndex].id] = code;
    await _save();
    notifyListeners();
  }

  List<String> get availableFiles => const [
        'create_post_page.dart',
        'post_service.dart',
      ];

  Future<void> switchFile(String file) async {
    if (file == currentFile || !availableFiles.contains(file)) return;
    _captureCode();
    currentFile = file;
    playground.textController.text = fileCodes[file] ?? '';
    _refreshPreview();
    await _save();
    notifyListeners();
  }

  void _captureCode() {
    final code = playground.code;
    fileCodes[currentFile] = code;
    lastCode[lesson.steps[currentStepIndex].id] = code;
  }

  void _refreshPreview() {
    if (lesson.steps[currentStepIndex].stepType == LessonStepType.ui) {
      playground.runCode();
    } else {
      playground.root = null;
      playground.error = null;
    }
  }

  Future<void> goTo(int index) async {
    if (index < 0 || index >= lesson.steps.length) return;
    _captureCode();
    currentStepIndex = index;
    _loadStep();
    await _save();
    notifyListeners();
  }

  @override
  void dispose() {
    playground.removeListener(_relay);
    playground.dispose();
    super.dispose();
  }
}
