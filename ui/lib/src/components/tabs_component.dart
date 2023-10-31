import 'package:flutter/material.dart';

class VserveTabBarComponent extends StatelessWidget {
  const VserveTabBarComponent({
    super.key,
    required this.tabs,
    this.onTap,
  });

  final List<Widget> tabs;
  final Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xff975aff);

    return TabBar(
      isScrollable: true,
      onTap: onTap,
      labelColor: baseColor,
      unselectedLabelColor: Colors.grey,
      indicatorColor: baseColor,
      tabs: tabs,
    );
  }
}

class VserveHorizontalTabComponent extends StatelessWidget {
  const VserveHorizontalTabComponent({
    super.key,
    this.icon,
    required this.label,
    this.padding,
  });

  final Widget? icon;
  final Widget label;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 21, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 14),
          ],
          label,
        ],
      ),
    );
  }
}
