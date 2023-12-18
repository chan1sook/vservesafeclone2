import 'dart:math' as math;

import 'package:flutter/material.dart';

class ScrollableContainerComponent extends StatelessWidget {
  const ScrollableContainerComponent({
    super.key,
    this.minWidth = 600,
    this.heightPadding = 200,
    this.child,
  });

  final double minWidth;
  final double heightPadding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double height = MediaQuery.of(context).size.height - heightPadding;
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height),
        child: SingleChildScrollView(
          primary: false,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: minWidth,
                maxWidth: math.max(minWidth, constraints.maxWidth),
              ),
              child: child,
            ),
          ),
        ),
      );
    });
  }
}
