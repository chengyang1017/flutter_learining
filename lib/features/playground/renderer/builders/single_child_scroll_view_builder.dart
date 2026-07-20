import 'package:flutter/material.dart';

import '../../../../core/utils/edge_insets_parser.dart';
import '../../../../core/utils/enum_parser.dart';
import '../../../../core/utils/value_parser.dart';
import '../../models/ui_node.dart';
import '../widget_renderer.dart';
import 'builder_utils.dart';

Widget buildSingleChildScrollView(
  BuildContext context,
  UiNode node,
  WidgetRenderer renderer,
) {
  renderer.warnUnknown(node, {
    'child',
    'scrollDirection',
    'reverse',
    'padding',
    'primary',
    'physics',
  });
  if (node.namedArguments.containsKey('physics')) {
    renderer.onWarning('SingleChildScrollView.physics 暂未支持，已忽略。');
  }
  return SingleChildScrollView(
    scrollDirection:
        _axis(EnumParser.id(node.namedArguments['scrollDirection'])),
    reverse: ValueParser.boolean(node.namedArguments['reverse']) ?? false,
    padding: node.namedArguments.containsKey('padding')
        ? EdgeInsetsParser.parse(node.namedArguments['padding'])
        : null,
    primary: ValueParser.boolean(node.namedArguments['primary']),
    child: child(context, node.namedArguments['child'], renderer),
  );
}

Axis _axis(String? value) =>
    value == 'Axis.horizontal' ? Axis.horizontal : Axis.vertical;
