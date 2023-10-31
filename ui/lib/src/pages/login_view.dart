import 'dart:math' as math;
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vservesafe/src/components/alert_component.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/models/login_data.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/models/user_data.dart';
import 'package:vservesafe/src/pages/dashboard_view.dart';
import 'package:vservesafe/src/services/api_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    super.key,
    required this.settingsController,
    required this.userController,
    this.autoLogin = true,
  });

  final SettingsController settingsController;
  final UserController userController;
  final bool autoLogin;

  static const routeName = '/login';

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  VserveLoginData _loginData = VserveLoginData();
  bool _isLoadingOpened = false;

  @override
  void initState() {
    super.initState();

    _loginData.rememberLogin = widget.settingsController.isRememberLogin;
    Future.delayed(const Duration(seconds: 0), _doRememberLogin);
  }

  Future<void> _doRememberLogin() async {
    if (widget.autoLogin && widget.settingsController.isRememberLogin) {
      _showLoadingDialog();

      final userData = await widget.userController.getUserServer();
      await widget.userController.updateUserData(userData);

      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted && widget.userController.userData != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
                  final sideComponent = _LoginSideComponent(
                    loginData: _loginData,
                    locked: _isLoadingOpened,
                    onDataChanged: _onDataChanged,
                    onLogin: _onLogin,
                  );

                  if (mediaData.size.width >= 990) {
                    return SizedBox(
                      width: 760,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Container(
                                color: const Color(0xfff5f5f5),
                                child: Image.asset(
                                  "assets/images/login.png",
                                  height: 200,
                                  cacheHeight: 200,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 14),
                                child: sideComponent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      width: math.min(mediaData.size.width, 400),
                      child: sideComponent,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    _doRememberLogin();
  }

  void _onDataChanged(VserveLoginData newLoginData) {
    setState(() {
      _loginData = newLoginData;
    });
  }

  void _onLogin(VserveLoginData loginData) async {
    VserveUserData userData = VserveUserData(username: "dev@sensesiot.net");
    _showLoadingDialog();

    try {
      final response = await ApiService.dio.post(
        "${ApiService.baseUrlPath}/login",
        data: loginData.toApiData(),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      userData = VserveUserData.parseFromRawData(response.data["userData"]);
      await widget.userController.updateUserData(userData);
      await widget.settingsController
          .updateRememberUser(_loginData.rememberLogin);

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName,
          (route) => false,
        );
      }
    } catch (err) {
      developer.log(err.toString(), name: "Login");

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context).pop();
      }

      if (err is DioException) {
        developer.log("${err.response?.data.toString()}", name: "Login");

        await _showLoginFailedDialog(
          baseText: AppLocalizations.of(context)!.loginFailedAuthFailed,
          reason: err.toString(),
        );
      } else {
        await _showLoginFailedDialog(
          baseText: AppLocalizations.of(context)!.loginFailedOtherErrorProblem,
          reason: err.toString(),
        );
      }
    }
  }

  Future<void> _showLoadingDialog() async {
    if (_isLoadingOpened) {
      return;
    }

    _isLoadingOpened = true;

    return showDialog<void>(
      context: context,
      barrierDismissible: SettingsController.isDebugMode,
      builder: (BuildContext context) {
        return const LoadingAlertDialog();
      },
    ).then((value) {
      _isLoadingOpened = false;
    });
  }

  Future<void> _showLoginFailedDialog({
    String? baseText,
    String? reason,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.loginFailedTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(baseText ??
                    AppLocalizations.of(context)!.loginFailedAuthFailed),
                if (reason != null)
                  Text(
                    AppLocalizations.of(context)!.errorReason(reason),
                    style: const TextStyle(fontSize: 10),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _LoginSideComponent extends StatelessWidget {
  const _LoginSideComponent({
    required this.loginData,
    this.onDataChanged,
    this.onLogin,
    this.locked = false,
  });

  final VserveLoginData loginData;
  final Function(VserveLoginData)? onDataChanged;
  final Function(VserveLoginData)? onLogin;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          AppLocalizations.of(context)!.loginViewTitle,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        Text(AppLocalizations.of(context)!.loginWelcomeText),
        const SizedBox(height: 21),
        TextField(
          readOnly: locked,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            labelText: AppLocalizations.of(context)!.loginEmailTitle,
            hintText: AppLocalizations.of(context)!.loginEmailHint,
          ),
          textInputAction: TextInputAction.next,
          onChanged: (email) {
            VserveLoginData newLoginData = loginData.clone();
            newLoginData.username = email;
            onDataChanged?.call(newLoginData);
          },
        ),
        const SizedBox(height: 14),
        TextField(
          readOnly: locked,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            labelText: AppLocalizations.of(context)!.loginPasswordTitle,
            hintText: AppLocalizations.of(context)!.loginPasswordHint,
          ),
          obscureText: true,
          textInputAction: TextInputAction.next,
          onChanged: (password) {
            VserveLoginData newLoginData = loginData.clone();
            newLoginData.password = password;
            onDataChanged?.call(newLoginData);
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Checkbox(
              value: loginData.rememberLogin,
              onChanged: !locked
                  ? (state) {
                      if (state != null) {
                        VserveLoginData newLoginData = loginData.clone();
                        newLoginData.rememberLogin = state;
                        onDataChanged?.call(newLoginData);
                      }
                    }
                  : null,
            ),
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    VserveLoginData newLoginData = loginData.clone();
                    newLoginData.rememberLogin = !loginData.rememberLogin;
                    onDataChanged?.call(newLoginData);
                  },
                  child: Text(AppLocalizations.of(context)!.loginRememberMe),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 21),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 14),
          ),
          onPressed: !locked && loginData.isFormValid
              ? () {
                  onLogin?.call(loginData.clone());
                }
              : null,
          child: Text(AppLocalizations.of(context)!.loginAction),
        )
      ],
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
