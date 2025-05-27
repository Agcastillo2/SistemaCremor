import 'package:flutter/material.dart';
import '../utils/ui_helpers.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final List<ChartLegendItem>? legendItems;
  final Widget? action;
  final double height;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final bool showBorder;

  const ChartCard({
    Key? key,
    required this.title,
    required this.chart,
    this.legendItems,
    this.action,
    this.height = 300,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.showBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIHelpers.borderRadiusLarge),
        side:
            showBorder
                ? BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                )
                : BorderSide.none,
      ),
      color: backgroundColor ?? (isDark ? Colors.grey[850] : Colors.white),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                action ?? const SizedBox.shrink(),
              ],
            ),
            UIHelpers.vSpaceMedium,
            SizedBox(height: height, child: chart),
            if (legendItems != null && legendItems!.isNotEmpty) ...[
              UIHelpers.vSpaceMedium,
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children:
                    legendItems!.map((item) => _buildLegendItem(item)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(ChartLegendItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        ),
        UIHelpers.hSpaceSmall,
        Text(
          item.label,
          style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
        ),
      ],
    );
  }
}

class ChartLegendItem {
  final String label;
  final Color color;

  const ChartLegendItem({required this.label, required this.color});
}
