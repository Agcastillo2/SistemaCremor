import 'package:flutter/material.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/language_selector_button.dart';
import '../utils/ui_helpers.dart';

class SettingsButtons extends StatelessWidget {
  final bool mini;
  final Axis axis;

  const SettingsButtons({
    Key? key,
    this.mini = false,
    this.axis = Axis.horizontal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = [
      ThemeToggleButton(mini: mini),
      axis == Axis.horizontal ? UIHelpers.hSpaceTiny : UIHelpers.vSpaceTiny,
      LanguageSelectorButton(mini: mini),
    ];

    return axis == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: children)
        : Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}
