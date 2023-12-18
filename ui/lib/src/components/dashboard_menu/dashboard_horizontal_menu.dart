import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vservesafe/src/models/dashboard_menu_item.dart';
import 'package:vservesafe/src/pages/dashboard/home_view.dart';

class MenuHorizontalBarComponent extends StatefulWidget {
  const MenuHorizontalBarComponent({
    super.key,
    this.menuList = const [],
    this.subroute,
    this.onMenuAction,
  });

  final List<MenuItemData> menuList;
  final String? subroute;
  final Function(String)? onMenuAction;

  @override
  State<MenuHorizontalBarComponent> createState() =>
      _MenuHorizontalBarComponentState();
}

class _MenuHorizontalBarComponentState
    extends State<MenuHorizontalBarComponent> {
  @override
  Widget build(BuildContext context) {
    var subroute = HomeDashboardView.routeName;
    if (widget.subroute != null && widget.subroute!.isNotEmpty) {
      subroute = widget.subroute!;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade500, width: 0.5),
        ),
      ),
      height: 52,
      child: ListView.builder(
        primary: false,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        scrollDirection: Axis.horizontal,
        itemCount: widget.menuList.length,
        itemBuilder: (context, index) {
          final item = widget.menuList[index];
          final menuItemWidget = _MenuInnerHorizontalItemComponent(
            item: item,
            withDropdown: item.submenu.isNotEmpty ? false : null,
            extraSpace: item.submenu.isNotEmpty ? 14 : 0,
          );

          return _MenuItemHorizontalComponent(
            onTap: () {
              widget.onMenuAction?.call(item.key);

              setState(() {});
            },
            padding: item.submenu.isNotEmpty
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            active: item.subroute == subroute ||
                item.submenu.firstWhereOrNull(
                        (subitem) => subitem.subroute == subroute) !=
                    null,
            child: item.submenu.isEmpty
                ? menuItemWidget
                : PopupMenuButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 0,
                      maxWidth: MediaQuery.of(context).size.width,
                    ),
                    position: PopupMenuPosition.under,
                    child: menuItemWidget,
                    itemBuilder: (context) {
                      return item.submenu.mapIndexed((subindex, subitem) {
                        return PopupMenuItem(
                          height: 0,
                          padding: EdgeInsets.zero,
                          child: _MenuItemHorizontalComponent(
                            onTap: () {
                              widget.onMenuAction?.call(subitem.key);

                              setState(() {});
                            },
                            active: subitem.subroute == subroute,
                            submenu: true,
                            child: _MenuInnerHorizontalItemComponent(
                              item: subitem,
                              submenu: true,
                            ),
                          ),
                        );
                      }).toList();
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _MenuItemHorizontalComponent extends StatefulWidget {
  const _MenuItemHorizontalComponent({
    required this.child,
    this.active = false,
    this.submenu = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    this.onTap,
  });
  final Widget child;
  final bool active;
  final bool submenu;
  final EdgeInsets padding;
  final Function()? onTap;

  @override
  State<_MenuItemHorizontalComponent> createState() =>
      _MenuItemHorizontalComponentState();
}

class _MenuItemHorizontalComponentState
    extends State<_MenuItemHorizontalComponent> with TickerProviderStateMixin {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor =
        MenuItemData.getColorByState(active: widget.active, isHover: _isHover);

    return MouseRegion(
      onEnter: (event) {
        _isHover = true;
        setState(() {});
      },
      onExit: (event) {
        _isHover = false;
        setState(() {});
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (details) {
          _isHover = true;
          setState(() {});
        },
        onTapUp: (details) {
          _isHover = false;
          setState(() {});
        },
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            border: !widget.submenu
                ? Border(
                    bottom: BorderSide(
                      color: hoverColor,
                      width: 2,
                    ),
                  )
                : Border(
                    left: BorderSide(
                      color: hoverColor,
                      width: 2,
                    ),
                  ),
          ),
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }
}

class _MenuInnerHorizontalItemComponent extends StatefulWidget {
  const _MenuInnerHorizontalItemComponent({
    required this.item,
    this.extraSpace = 0,
    this.submenu = false,
    this.withDropdown,
  });

  final MenuItemData item;
  final double extraSpace;
  final bool submenu;
  final bool? withDropdown;

  @override
  State<_MenuInnerHorizontalItemComponent> createState() =>
      _MenuInnerHorizontalItemComponentState();
}

class _MenuInnerHorizontalItemComponentState
    extends State<_MenuInnerHorizontalItemComponent>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: widget.extraSpace),
        if (widget.item.icon != null) ...[
          Icon(widget.item.icon, size: 21),
          widget.submenu ? const SizedBox(width: 21) : const SizedBox(width: 7),
        ],
        Text(widget.item.translatedText(context)),
        if (widget.withDropdown != null) ...[
          const SizedBox(width: 7),
          widget.withDropdown == true
              ? const Icon(Icons.arrow_drop_up, size: 21)
              : const Icon(Icons.arrow_drop_down, size: 21),
        ]
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
