import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vservesafe/src/models/dashboard_menu_item.dart';
import 'package:vservesafe/src/pages/dashboard/home_view.dart';

class MenuVerticalBarComponent extends StatefulWidget {
  const MenuVerticalBarComponent({
    super.key,
    this.header,
    this.menuList = const [],
    this.subroute,
    this.onMenuAction,
  });

  final Widget? header;
  final List<MenuItemData> menuList;
  final String? subroute;
  final Function(String)? onMenuAction;

  @override
  State<MenuVerticalBarComponent> createState() =>
      _MenuVerticalBarComponentState();
}

class _MenuVerticalBarComponentState extends State<MenuVerticalBarComponent>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final Map<int, bool> _expandedIndex = {};

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
      child: ListView.builder(
        primary: false,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        scrollDirection: Axis.vertical,
        itemCount: widget.menuList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _headerWidget;
          }

          final item = widget.menuList[index - 1];
          final menuItemWidget = _MenuInnerVerticalItemComponent(
            item: item,
            withDropdown: item.submenu.isNotEmpty
                ? _expandedIndex.containsKey(index) &&
                    _expandedIndex[index] == true
                : null,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _MenuItemVerticalComponent(
                onTap: () {
                  if (_expandedIndex.containsKey(index)) {
                    _expandedIndex[index] = !_expandedIndex[index]!;
                  } else {
                    _expandedIndex[index] = true;
                  }

                  widget.onMenuAction?.call(item.key);

                  setState(() {});
                },
                active: item.subroute == subroute ||
                    item.submenu.firstWhereOrNull(
                            (subitem) => subitem.subroute == subroute) !=
                        null,
                child: menuItemWidget,
              ),
              if (item.submenu.isNotEmpty &&
                  _expandedIndex.containsKey(index) &&
                  _expandedIndex[index] == true)
                ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: item.submenu.length,
                  itemBuilder: (context, subindex) {
                    final subitem = item.submenu[subindex];
                    return _MenuItemVerticalComponent(
                      onTap: () {
                        widget.onMenuAction?.call(subitem.key);

                        setState(() {});
                      },
                      active: subitem.subroute == subroute,
                      child: _MenuInnerVerticalItemComponent(
                        item: subitem,
                      ),
                    );
                  },
                )
            ],
          );
        },
      ),
    );
  }

  Widget get _headerWidget {
    return widget.header != null
        ? Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade500, width: 0.5),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: widget.header,
          )
        : Container();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _MenuItemVerticalComponent extends StatefulWidget {
  const _MenuItemVerticalComponent({
    required this.child,
    this.active = false,
    this.onTap,
  });
  final Widget child;
  final bool active;
  final Function()? onTap;

  @override
  State<_MenuItemVerticalComponent> createState() =>
      _MenuItemVerticalComponentState();
}

class _MenuItemVerticalComponentState extends State<_MenuItemVerticalComponent>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHover = false;

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
            border: Border(
              left: BorderSide(
                color: MenuItemData.getColorByState(
                    active: widget.active, isHover: _isHover),
                width: 2,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _MenuInnerVerticalItemComponent extends StatefulWidget {
  const _MenuInnerVerticalItemComponent({
    required this.item,
    this.withDropdown,
  });

  final MenuItemData item;
  final bool? withDropdown;

  @override
  State<_MenuInnerVerticalItemComponent> createState() =>
      _MenuInnerVerticalItemComponentState();
}

class _MenuInnerVerticalItemComponentState
    extends State<_MenuInnerVerticalItemComponent>
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
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.item.icon != null) ...[
          Icon(widget.item.icon, size: 21),
          const SizedBox(width: 7),
        ],
        Expanded(
          child: Text(
            widget.item.translatedText(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
