import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:vservesafe/src/components/alert_component.dart';
import 'package:vservesafe/src/components/dashboard_component.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/pages/dashboard/admin_accounts_view.dart';
import 'package:vservesafe/src/pages/dashboard/admin_user_management_view.dart';
import 'package:vservesafe/src/pages/dashboard/departments_view.dart';
import 'package:vservesafe/src/pages/dashboard/form_creation_view.dart';
import 'package:vservesafe/src/pages/dashboard/profile_view.dart';
import 'package:vservesafe/src/pages/dashboard/select_site_view.dart';
import 'package:vservesafe/src/pages/dashboard/shecup_analysis_view.dart';
import 'package:vservesafe/src/pages/dashboard/shecup_exam_view.dart';
import 'package:vservesafe/src/pages/dashboard/shedein_creation_view.dart';
import 'package:vservesafe/src/pages/dashboard/shedein_decision_view.dart';
import 'package:vservesafe/src/pages/dashboard/shedein_environment_view.dart';
import 'package:vservesafe/src/pages/dashboard/shedein_foodsafety_view.dart';
import 'package:vservesafe/src/pages/dashboard/shedein_hygiene_view.dart';
import 'package:vservesafe/src/pages/dashboard/site_lists_view.dart';
import 'package:vservesafe/src/pages/dashboard/site_setting_view.dart';
import 'package:vservesafe/src/pages/dashboard/vsafe_analysis_view.dart';
import 'package:vservesafe/src/pages/dashboard/vsafe_exam_view.dart';
import 'package:vservesafe/src/pages/dashboard/home_view.dart';
import 'package:vservesafe/src/pages/dashboard/iot_view.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/pages/login_view.dart';
import 'package:vservesafe/src/services/api_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({
    super.key,
    required this.settingsController,
    required this.userController,
    required this.subroute,
    this.arguments,
  });

  final SettingsController settingsController;
  final UserController userController;
  final String subroute;
  final Object? arguments;

  static const routeName = '/dashboard';

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _isLoadingOpened = false;

  @override
  Widget build(BuildContext context) {
    return DashboardComponent(
      settingsController: widget.settingsController,
      userController: widget.userController,
      onMenuAction: _onMenuAction,
      child: Navigator(
        key: _navigatorKey,
        initialRoute: widget.subroute,
        onGenerateRoute: (RouteSettings routeSettings) {
          Map<String, dynamic> args = {};
          if (widget.arguments is Map<String, dynamic>) {
            args.addAll(widget.arguments as Map<String, dynamic>);
          }

          developer.log("${routeSettings.arguments}", name: "NavigatorRoute");

          if (routeSettings.arguments is Map<String, dynamic>) {
            args.addAll(routeSettings.arguments as Map<String, dynamic>);
          }

          return MaterialPageRoute<void>(
            settings: routeSettings,
            builder: (BuildContext context) {
              switch (routeSettings.name) {
                case VsafeExamDashboardView.routeName:
                  return VsafeExamDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case VSafeAnalysisDashboardView.routeName:
                  return VSafeAnalysisDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case ShedeinFoodsafetyDashboardView.routeName:
                  return ShedeinFoodsafetyDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case ShedeinHygieneDashboardView.routeName:
                  return ShedeinHygieneDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case ShedeinEnvironmentDashboardView.routeName:
                  return ShedeinEnvironmentDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case ShedeinDecisionDashboardView.routeName:
                  return ShedeinDecisionDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case ShecupExamDashboardView.routeName:
                  return ShecupExamDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case ShecupAnalysisDashboardView.routeName:
                  return ShecupAnalysisDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case IotDashboardView.routeName:
                  return IotDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case AdminUserManagerDashboardView.routeName:
                  return AdminUserManagerDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case AdminAccountsDashboardView.routeName:
                  return AdminAccountsDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case SiteListsDashboardView.routeName:
                  return SiteListsDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case DepartmentListsDashboardView.routeName:
                  return DepartmentListsDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case FormCreationDashboardView.routeName:
                  return FormCreationDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case ShedeinCreationDashboardView.routeName:
                  return ShedeinCreationDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case SelectSiteDashboardView.routeName:
                  return SelectSiteDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case SiteSettingDashboardView.routeName:
                  return SiteSettingDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
                case ProfileDashboardView.routeName:
                  return ProfileDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                    startPageIndex:
                        args["pageIndex"] is int ? args["pageIndex"] : null,
                  );
                case HomeDashboardView.routeName:
                default:
                  return HomeDashboardView(
                    settingsController: widget.settingsController,
                    userController: widget.userController,
                  );
              }
            },
          );
        },
      ),
    );
  }

  void _onMenuAction(String? action) {
    switch (action) {
      case "admin-accounts":
        _openAdminAccounts();
        break;
      case "site-lists":
        _openSiteLists();
        break;
      case "edit-profile":
        _openEditProfile();
        break;
      case "logout":
        _doLogout();
        break;
    }
  }

  void _openAdminAccounts() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      DashboardView.routeName + AdminAccountsDashboardView.routeName,
      (route) => false,
    );
  }

  void _openSiteLists() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      DashboardView.routeName + SiteListsDashboardView.routeName,
      (route) => false,
    );
  }

  void _openEditProfile() async {
    Navigator.pushNamedAndRemoveUntil(
      context,
      DashboardView.routeName + ProfileDashboardView.routeName,
      (route) => false,
      arguments: {"pageIndex": ProfileDashboardView.editProfilePageIndex},
    );
  }

  void _doLogout() async {
    _showLoadingDialog();

    try {
      await ApiService.dio.post("${ApiService.baseUrlPath}/logout");
      await widget.userController.updateUserData(null);

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (err) {
      developer.log(err.toString(), name: "Logout");

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginView.routeName,
        (route) => false,
        arguments: {"autoLogin": false},
      );
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
}
