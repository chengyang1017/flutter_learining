import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ui_node.dart';
import '../parser/flutter_ui_parser.dart';

enum PreviewDevice { androidPhone, smallPhone, tablet, responsive }

class PlaygroundController extends ChangeNotifier {
  PlaygroundController() {
    textController = TextEditingController(text: exampleCode);
    runCode();
  }
  static const exampleCode = """Container(
  color: Colors.white,
  padding: EdgeInsets.all(24),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(Icons.language, size: 64, color: Colors.blue),
      SizedBox(height: 16),
      Text('万文社', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black)),
      SizedBox(height: 8),
      Text('Glyphora', style: TextStyle(fontSize: 18, color: Colors.grey)),
      SizedBox(height: 24),
      ElevatedButton(onPressed: null, child: Text('开始探索')),
    ],
  ),
)""";
  late final TextEditingController textController;
  final _parser = FlutterUiParser();
  Timer? _debounce;
  UiNode? root;
  String? error;
  List<String> warnings = [];
  bool isParsing = false, autoRun = false, darkPreview = false;
  PreviewDevice device = PreviewDevice.androidPhone;
  String get code => textController.text;
  void updateCode(String value) {
    if (autoRun) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), runCode);
    }
    notifyListeners();
  }

  void runCode() {
    _debounce?.cancel();
    isParsing = true;
    error = null;
    warnings = [];
    notifyListeners();
    if (code.trim().isEmpty) {
      root = null;
      isParsing = false;
      notifyListeners();
      return;
    }
    try {
      root = _parser.parse(code);
    } catch (e) {
      error = e.toString();
    }
    isParsing = false;
    notifyListeners();
  }

  void clearCode() {
    textController.clear();
    root = null;
    error = null;
    warnings = [];
    notifyListeners();
  }

  void resetExample() {
    textController.text = exampleCode;
    runCode();
  }

  void toggleAutoRun() {
    autoRun = !autoRun;
    notifyListeners();
  }

  void changeDevice(PreviewDevice value) {
    device = value;
    notifyListeners();
  }

  void togglePreviewTheme() {
    darkPreview = !darkPreview;
    notifyListeners();
  }

  void addWarning(String value) {
    if (!warnings.contains(value)) {
      warnings.add(value);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    textController.dispose();
    super.dispose();
  }
}
