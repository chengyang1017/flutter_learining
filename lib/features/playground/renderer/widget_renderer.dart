import 'package:flutter/material.dart';

import '../models/ui_node.dart';
import 'builders/card_builder.dart';
import 'builders/center_builder.dart';
import 'builders/column_builder.dart';
import 'builders/container_builder.dart';
import 'builders/elevated_button_builder.dart';
import 'builders/icon_builder.dart';
import 'builders/padding_builder.dart';
import 'builders/row_builder.dart';
import 'builders/sized_box_builder.dart';
import 'builders/text_builder.dart';
import 'builders/text_field_builder.dart';
import 'builders/scaffold_builder.dart';
import 'builders/app_bar_builder.dart';
import 'builders/safe_area_builder.dart';
import 'builders/expanded_builder.dart';
import 'builders/flexible_builder.dart';
import 'builders/single_child_scroll_view_builder.dart';
import 'builders/list_view_builder.dart';
import 'builders/list_tile_builder.dart';
import 'builders/divider_builder.dart';
import 'builders/stack_builder.dart';
import 'builders/positioned_builder.dart';
import 'builders/floating_action_button_builder.dart';
import 'widget_registry.dart';

class WidgetRenderer {
  WidgetRenderer({void Function(String)? onWarning})
      : onWarning = onWarning ?? ((_) {}),
        registry = WidgetRegistry({
          'Text': buildText,
          'Container': buildContainer,
          'Center': buildCenter,
          'Padding': buildPadding,
          'SizedBox': buildSizedBox,
          'Row': buildRow,
          'Column': buildColumn,
          'Card': buildCard,
          'Icon': buildIcon,
          'ElevatedButton': buildElevatedButton,
        }) {
    registry.register('TextField', const TextFieldUiBuilder().call);
    registry.register('Scaffold', buildScaffold);
    registry.register('AppBar', buildAppBar);
    registry.register('SafeArea', buildSafeArea);
    registry.register('Expanded', buildExpanded);
    registry.register('Flexible', buildFlexible);
    registry.register('SingleChildScrollView', buildSingleChildScrollView);
    registry.register('ListView', buildListView);
    registry.register('ListTile', buildListTile);
    registry.register('Divider', buildDivider);
    registry.register('Stack', buildStack);
    registry.register('Positioned', buildPositioned);
    registry.register('FloatingActionButton', buildFloatingActionButton);
  }

  final void Function(String) onWarning;
  final WidgetRegistry registry;

  Widget render(BuildContext context, UiNode node) {
    final builder = registry[node.type];
    if (builder == null) return _error('暂不支持 Widget：${node.type}');
    try {
      return builder(context, node, this);
    } catch (error) {
      return _error('渲染失败：$error');
    }
  }

  PreferredSizeWidget? renderPreferred(
    BuildContext context,
    UiNode node,
  ) {
    final widget = render(context, node);
    if (widget is PreferredSizeWidget) return widget;
    onWarning('${node.type} 不能用作 Scaffold.appBar');
    return null;
  }

  Widget _error(String message) => Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(message, style: const TextStyle(color: Colors.red)),
        ),
      );

  void warnUnknown(UiNode node, Set<String> supported) {
    for (final key in node.namedArguments.keys) {
      if (!supported.contains(key)) onWarning('${node.type} 暂不支持属性：$key');
    }
  }
}
