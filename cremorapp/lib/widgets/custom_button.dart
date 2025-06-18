import 'package:flutter/material.dart';
import '../utils/ui_helpers.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool isOutlined;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.isOutlined = false,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      height: height,
      child:
          isOutlined
              ? OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: buttonColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      UIHelpers.borderRadiusMedium,
                    ),
                  ),
                ),
                onPressed: onPressed,
                child: _buildButtonContent(buttonColor),
              )
              : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: buttonColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      UIHelpers.borderRadiusMedium,
                    ),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: onPressed,
                child: _buildButtonContent(Colors.white),
              ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (icon == null) {
      return Text(
        text,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: textColor),
        UIHelpers.hSpaceSmall,
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
