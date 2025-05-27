import 'package:flutter/material.dart';
import '../utils/ui_helpers.dart';

class ListCard extends StatelessWidget {
  final String title;
  final List<ListItem> items;
  final Widget? action;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final double borderRadius;
  final bool showDividers;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ListCard({
    Key? key,
    required this.title,
    required this.items,
    this.action,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderRadius = UIHelpers.borderRadiusLarge,
    this.showDividers = true,
    this.physics,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
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
            ListView.separated(
              shrinkWrap: shrinkWrap,
              physics: physics ?? const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder:
                  (context, index) =>
                      showDividers
                          ? Divider(
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                            height: 1,
                          )
                          : const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(
                    UIHelpers.borderRadiusSmall,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        if (item.leading != null) ...[
                          item.leading!,
                          UIHelpers.hSpaceMedium,
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (item.subtitle != null) ...[
                                UIHelpers.vSpaceTiny,
                                Text(
                                  item.subtitle!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (item.trailing != null) item.trailing!,
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ListItem {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ListItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });
}
