import 'package:flutter/material.dart';
import '../controllers/current_user_controller.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/language_selector_button.dart';
import '../widgets/checkin_out_buttons.dart';
import '../utils/ui_helpers.dart';

class SettingsButtons extends StatelessWidget {
  final bool mini;
  final Axis axis;

  const SettingsButtons({
    Key? key,
    this.mini = false,
    this.axis = Axis.horizontal,
  }) : super(key: key);

  bool _shouldShowCheckInOut() {
    final currentUser = CurrentUserController.currentUser;
    if (currentUser == null) return false;

    final validRoles = [
      'Jefe de Nata',
      'Jefe de Helados',
      'Trabajador de Nata',
      'Trabajador de Helados',
    ];

    return validRoles.contains(currentUser.rol);
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      if (_shouldShowCheckInOut()) const CheckInOutButtons(),
      if (_shouldShowCheckInOut() && axis == Axis.horizontal)
        UIHelpers.hSpaceTiny
      else if (_shouldShowCheckInOut() && axis == Axis.vertical)
        UIHelpers.vSpaceTiny,
      ThemeToggleButton(mini: mini),
      axis == Axis.horizontal ? UIHelpers.hSpaceTiny : UIHelpers.vSpaceTiny,
      LanguageSelectorButton(mini: mini),
    ];

    return axis == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: children)
        : Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}
