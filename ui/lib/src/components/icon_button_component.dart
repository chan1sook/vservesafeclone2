import 'package:flutter/material.dart';
import 'package:vservesafe/src/utils/color.dart';

class IconButtonComponent extends StatelessWidget {
  const IconButtonComponent({
    super.key,
    required this.icon,
    this.color,
    this.width = 48,
    this.onPressed,
  });

  final IconData icon;
  final Color? color;
  final double width;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Colors.grey;
    final iconColor =
        baseColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 1,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            backgroundColor: baseColor,
            foregroundColor: colorLighten(baseColor, 0.2),
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: width * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
