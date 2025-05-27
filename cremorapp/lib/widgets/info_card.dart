import 'package:flutter/material.dart';
import '../utils/ui_helpers.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIHelpers.borderRadiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIHelpers.borderRadiusLarge),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                backgroundColor ?? (isDark ? Colors.grey[800] : Colors.white),
            borderRadius: BorderRadius.circular(UIHelpers.borderRadiusLarge),
            boxShadow: onTap != null ? UIHelpers.lightShadow : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (iconColor ?? theme.colorScheme.primary)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  trailing ?? const SizedBox.shrink(),
                ],
              ),
              UIHelpers.vSpaceMedium,
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              UIHelpers.vSpaceSmall,
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final bool showTrend;
  final double? trendValue;
  final VoidCallback? onTap;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.showTrend = false,
    this.trendValue,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    Widget? trendIndicator;

    if (showTrend && trendValue != null) {
      final isPositive = trendValue! >= 0;
      final iconData = isPositive ? Icons.trending_up : Icons.trending_down;
      final trendColor = isPositive ? Colors.green : Colors.red;

      trendIndicator = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: trendColor),
          UIHelpers.hSpaceTiny,
          Text(
            '${trendValue!.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: trendColor,
            ),
          ),
        ],
      );
    }

    return InfoCard(
      title: title,
      value: value,
      icon: icon,
      iconColor: cardColor,
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      onTap: onTap,
      trailing: trendIndicator,
    );
  }
}
