import 'package:flutter/material.dart';

class VserveTabBarComponent extends StatelessWidget {
  const VserveTabBarComponent({
    super.key,
    required this.tabs,
    this.onTap,
    this.controller,
  });

  final List<Widget> tabs;
  final Function(int)? onTap;
  final TabController? controller;

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xff975aff);

    return TabBar(
      controller: controller,
      isScrollable: true,
      onTap: onTap,
      labelColor: baseColor,
      unselectedLabelColor: Colors.grey,
      indicatorColor: baseColor,
      tabs: tabs,
      tabAlignment: TabAlignment.start,
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
