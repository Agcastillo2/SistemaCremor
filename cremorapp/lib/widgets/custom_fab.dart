import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? label;
  final bool isExtended;
  final bool mini;
  final Object? heroTag;

  const CustomFAB({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.label,
    this.isExtended = false,
    this.mini = false,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        heroTag: heroTag,
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: foregroundColor ?? Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        label: Text(
          label!,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: Icon(icon),
      );
    }

    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 4,
      highlightElevation: 8,
      mini: mini,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Icon(icon),
    );
  }
}

class SpeedDialFAB extends StatefulWidget {
  final List<SpeedDialItem> actions;
  final IconData? mainIcon;
  final IconData? closeIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final VoidCallback? onPressed;

  const SpeedDialFAB({
    Key? key,
    required this.actions,
    this.mainIcon = Icons.add,
    this.closeIcon = Icons.close,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.onPressed,
  }) : super(key: key);

  @override
  State<SpeedDialFAB> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (widget.onPressed != null) {
      widget.onPressed!();
      return;
    }

    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Speed Dial Actions
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child:
              _isOpen
                  ? Column(
                    key: const ValueKey('open'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:
                        widget.actions.map((action) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (action.label != null)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        action.label!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                CustomFAB(
                                  mini: true,
                                  icon: action.icon,
                                  onPressed: () {
                                    _toggle();
                                    action.onPressed();
                                  },
                                  backgroundColor: action.backgroundColor,
                                  foregroundColor: action.foregroundColor,
                                  heroTag: action.heroTag,
                                  tooltip: action.tooltip,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  )
                  : const SizedBox.shrink(key: ValueKey('closed')),
        ),

        // Main Button
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value * 0.75 * 3.14,
              child: child,
            );
          },
          child: CustomFAB(
            icon: _isOpen ? widget.closeIcon! : widget.mainIcon!,
            onPressed: _toggle,
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            tooltip: widget.tooltip,
          ),
        ),
      ],
    );
  }
}

class SpeedDialItem {
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final Object? heroTag;

  const SpeedDialItem({
    required this.icon,
    required this.onPressed,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.heroTag,
  });
}
