import 'package:flutter/material.dart';
import 'package:vservesafe/src/utils/color.dart';

class GridFormItemComponent extends StatefulWidget {
  const GridFormItemComponent({
    super.key,
    required this.text,
    this.leadColor,
    this.onSelectItem,
  });

  final String text;
  final Color? leadColor;
  final Function()? onSelectItem;

  @override
  State<GridFormItemComponent> createState() => _GridFormItemComponentState();
}

class _GridFormItemComponentState extends State<GridFormItemComponent> {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.leadColor ?? Colors.green;
    final hoverColor = colorLighten(baseColor, 0.25);

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
        onTap: () {
          widget.onSelectItem?.call();
        },
        child: Card(
          child: Row(
            children: [
              AnimatedContainer(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: _isHover ? baseColor : hoverColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(7),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.expand(),
                    child: Center(
                      child: Text(
                        widget.text,
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
