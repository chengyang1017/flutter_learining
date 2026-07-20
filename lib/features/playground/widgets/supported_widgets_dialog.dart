import 'package:flutter/material.dart';

class SupportedWidgetsDialog extends StatelessWidget {
  const SupportedWidgetsDialog({super.key});
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('支持的组件'),
        content: const SingleChildScrollView(
          child: Text(
            'Text · Container · Center · Padding · SizedBox · Row · Column · Card · Icon · ElevatedButton\n\n支持颜色、EdgeInsets、布局枚举、TextStyle，以及嵌套 Widget 与 Widget 列表。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      );
}
