import 'dart:math' as math;
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vservesafe/src/pages/dashboard_view.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: const Color(0xfffbfaff),
              child: CustomPaint(
                painter: _LoginBackgroundPainter(),
              ),
            ),
            Center(
              child: Card(
                margin: const EdgeInsets.all(14),
                elevation: 4,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    MediaQueryData mediaData = MediaQuery.of(context);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      width: math.min(mediaData.size.width, 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Page not found",
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 21),
                          ElevatedButton(
                            onPressed: () {
                              _toDashboardPage(context);
                            },
                            child: Text("Back to Homepage"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toDashboardPage(context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      DashboardView.routeName,
      (route) => false,
    );
  }
}

class _LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint1 = Paint();
    paint1.color = const Color.fromARGB(81, 215, 215, 215);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint1);

    Path path1 = Path();
    path1.moveTo(size.width * 0.5 + 64, 0);
    path1.lineTo(size.width * 0.5 - 64, size.height);
    path1.lineTo(size.width, size.height);
    path1.lineTo(size.width, 0);
    path1.close();

    canvas.drawPath(path1, paint1);

    Paint paint2 = Paint();
    paint2.color = const Color.fromARGB(81, 192, 192, 192);

    Path path2 = Path();
    path2.moveTo(size.width, size.height * 0.5);
    path2.lineTo(size.width - 1200, 0);
    path2.lineTo(size.width, 0);
    path2.close();
    canvas.drawPath(path2, paint1);

    Path path3 = Path();
    path3.moveTo(size.width, size.height * 0.5 - 50);
    path3.lineTo(size.width - 500, 0);
    path3.lineTo(size.width, 0);
    path3.close();
    canvas.drawPath(path3, paint2);

    Path path4 = Path();
    path4.moveTo(size.width, size.height * 0.5 + 100);
    path4.lineTo(size.width - 1500, size.height);
    path4.lineTo(size.width, size.height);
    path4.close();
    canvas.drawPath(path4, paint1);

    Path path5 = Path();
    path5.moveTo(size.width - 400, 0);
    path5.lineTo(size.width - 800, size.height);
    path5.lineTo(size.width, size.height);
    path5.lineTo(size.width, 0);
    path5.close();
    canvas.drawPath(path5, paint2);
  }

  @override
  bool shouldRepaint(_LoginBackgroundPainter oldDelegate) {
    return false;
  }
}
