import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vservesafe/src/components/langswitch_component.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
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
import 'package:vservesafe/src/pages/dashboard/shedein_hygiene_view.dart';
import 'package:vservesafe/src/pages/dashboard/site_setting_view.dart';
import 'package:vservesafe/src/pages/dashboard/vsafe_analysis_view.dart';
import 'package:vservesafe/src/pages/dashboard/vsafe_exam_view.dart';
import 'package:vservesafe/src/pages/dashboard/shedein_foodsafety_view.dart';
import 'package:vservesafe/src/pages/dashboard_view.dart';
import 'package:vservesafe/src/pages/dashboard/iot_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';

class DashboardComponent extends StatefulWidget {
  const DashboardComponent({
    super.key,
    required this.settingsController,
    required this.userController,
    this.onMenuAction,
    required this.child,
  });

  final SettingsController settingsController;
  final UserController userController;
  final Function(String?)? onMenuAction;
  final Widget child;

  @override
  State<DashboardComponent> createState() => _DashboardComponentState();
}

class _DashboardComponentState extends State<DashboardComponent>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaData = MediaQuery.of(context);

    return Scaffold(
      drawer: mediaData.size.width < 768
          ? Hero(
              tag: "menu-side",
              child: Drawer(
                semanticLabel: "Menu",
                child: _SideDashboardComponent(
                  userController: widget.userController,
                  onMenuAction: _onMenuAction,
                ),
              ),
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          MediaQueryData mediaData = MediaQuery.of(context);

          return Row(
            children: [
              Hero(
                tag: "menu1",
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 100),
                  alignment: Alignment.centerLeft,
                  child: Drawer(
                    elevation: 0,
                    width: mediaData.size.width >= 760 ? 300 : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                      ),
                      child: _SideDashboardComponent(
                        userController: widget.userController,
                        onMenuAction: _onMenuAction,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopDashboardComponent(
                      settingsController: widget.settingsController,
                      userController: widget.userController,
                      onMenuAction: _onMenuAction,
                      onSwitchLanguage: _onSwitchLanguage,
                    ),
                    Expanded(
                      child: widget.child,
                    ),
                    const Text(
                      "Vservesafe",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onMenuAction(String? action) {
    switch (action) {
      case "home":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + DashboardView.routeName,
          (route) => false,
        );
        break;
      case "vsafe-exam":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + VsafeExamDashboardView.routeName,
          (route) => false,
        );
        break;
      case "vsafe-analysis":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + VSafeAnalysisDashboardView.routeName,
          (route) => false,
        );
        break;
      case "shedein-foodsafety":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + ShedeinFoodsafetyDashboardView.routeName,
          (route) => false,
        );
        break;
      case "shedein-hygiene":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + ShedeinHygieneDashboardView.routeName,
          (route) => false,
        );
        break;
      case "shedein-environment":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + ShedeinEnvironmentDashboardView.routeName,
          (route) => false,
        );
        break;
      case "shedein-decision":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + ShedeinDecisionDashboardView.routeName,
          (route) => false,
        );
        break;
      case "shecup-exam":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + ShecupExamDashboardView.routeName,
          (route) => false,
        );
        break;
      case "shecup-analysis":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + ShecupAnalysisDashboardView.routeName,
          (route) => false,
        );
        break;
      case "iot":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + IotDashboardView.routeName,
          (route) => false,
        );
        break;
      case "admin-user-management":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + AdminUserManagerDashboardView.routeName,
          (route) => false,
        );
        break;
      case "departments":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + DepartmentListsDashboardView.routeName,
          (route) => false,
        );
        break;
      case "form-creation":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + FormCreationDashboardView.routeName,
          (route) => false,
        );
        break;
      case "shedein-creation":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + ShedeinCreationDashboardView.routeName,
          (route) => false,
        );
        break;
      case "select-site":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + SelectSiteDashboardView.routeName,
          (route) => false,
        );
        break;
      case "site-settings":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + SiteSettingDashboardView.routeName,
          (route) => false,
        );
        break;
      case "profile":
        Navigator.pushNamedAndRemoveUntil(
          context,
          DashboardView.routeName + ProfileDashboardView.routeName,
          (route) => false,
        );
        break;
      default:
        widget.onMenuAction?.call(action);
        break;
    }
  }

  Future<void> _onSwitchLanguage(Locale locale) async {
    await widget.settingsController.updateLocale(locale);
  }
}

class _TopDashboardComponent extends StatefulWidget {
  const _TopDashboardComponent({
    required this.settingsController,
    required this.userController,
    this.onMenuAction,
    this.onSwitchLanguage,
  });

  final SettingsController settingsController;
  final UserController userController;
  final Function(String?)? onMenuAction;
  final Function(Locale)? onSwitchLanguage;

  @override
  State<_TopDashboardComponent> createState() => _TopDashboardComponentState();
}

class _TopDashboardComponentState extends State<_TopDashboardComponent> {
  late Timer _timer;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _avatarUrl = widget.userController.userData?.serverAvatarUrl;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final newUrl = widget.userController.userData?.serverAvatarUrl;
      if (_avatarUrl != newUrl) {
        _avatarUrl = newUrl;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 150),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  value: "Site1",
                  onChanged: (value) {},
                  items: ["Site1", "Site2", "Site3"].map((site) {
                    return DropdownMenuItem<String>(
                      value: site,
                      child: Text(
                        site,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
          actions: [
            DashboardLanguageSwitchComponent(
              settingsController: widget.settingsController,
              onSwitchLanguage: widget.onSwitchLanguage,
            ),
            IconButton(
              tooltip: "Notification",
              onPressed: () {},
              icon: Stack(
                children: [
                  const FaIcon(FontAwesomeIcons.bell),
                  Transform.translate(
                    offset: const Offset(10, -10),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 18,
                      height: 18,
                      child: Center(
                        child: Text(
                          "1",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.computeLuminance() >= 0.5
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (constraints.maxWidth >= 768) const SizedBox(width: 14),
            if (widget.userController.userData != null)
              PopupMenuButton<String>(
                tooltip: "User",
                onSelected: widget.onMenuAction,
                position: PopupMenuPosition.under,
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: "edit-profile",
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.penToSquare,
                            color:
                                Theme.of(context).textTheme.labelMedium?.color,
                          ),
                          const SizedBox(width: 14),
                          Text(AppLocalizations.of(context)!
                              .dashboardEditProfileDropdownMenu),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: "logout",
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.logout,
                            color:
                                Theme.of(context).textTheme.labelMedium?.color,
                          ),
                          const SizedBox(width: 14),
                          Text(AppLocalizations.of(context)!
                              .dashboardLogoutDropdownMenu),
                        ],
                      ),
                    ),
                  ];
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 14, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (constraints.maxWidth >= 768)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.userController.userData!.username,
                            ),
                            Text(
                              (widget.userController.userData!.role)
                                  .toUpperCase(),
                              style: const TextStyle(color: Colors.black45),
                            ),
                          ],
                        ),
                      if (constraints.maxWidth >= 768)
                        const SizedBox(width: 14),
                      CircleAvatar(
                        backgroundImage: _avatarUrl != null
                            ? NetworkImage(_avatarUrl!)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();

    super.dispose();
  }
}

class _SideDashboardComponent extends StatelessWidget {
  const _SideDashboardComponent(
      {required this.userController, this.onMenuAction});

  final UserController userController;
  final Function(String?)? onMenuAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      primary: false,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo-dark.png",
              height: 56,
            ),
            Image.asset(
              "assets/images/logo-full1.png",
              height: 56,
            )
          ],
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            onMenuAction?.call("home");
          },
        ),
        ExpansionTile(
          leading: const Icon(Icons.shield),
          title: const Text('VSAFE'),
          children: <Widget>[
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.book),
              title: const Text('Exam'),
              onTap: () {
                onMenuAction?.call("vsafe-exam");
              },
            ),
            ListTile(
              leading: const Icon(Icons.line_axis),
              title: const Text('Analysis'),
              onTap: () {
                onMenuAction?.call("vsafe-analysis");
              },
            ),
          ],
        ),
        ExpansionTile(
          leading: const FaIcon(FontAwesomeIcons.getPocket),
          title: const Text('SHEDEIN'),
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.shield),
              title: const Text('Food Safety Management'),
              onTap: () {
                onMenuAction?.call("shedein-foodsafety");
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.faceSmile),
              title: const Text('Occupational Health & Safety'),
              onTap: () {
                onMenuAction?.call("shedein-hygiene");
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.flask),
              title: const Text('Environment & Sustainability'),
              onTap: () {
                onMenuAction?.call("shedein-environment");
              },
            ),
            ListTile(
              leading: const Icon(Icons.tv),
              title: const Text('Decision Intelligence'),
              onTap: () {
                onMenuAction?.call("shedein-decision");
              },
            ),
          ],
        ),
        ExpansionTile(
          leading: const Icon(Icons.check_circle),
          title: const Text('SHEC UP'),
          children: <Widget>[
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.book),
              title: const Text('Exam'),
              onTap: () {
                onMenuAction?.call("shecup-exam");
              },
            ),
            ListTile(
              leading: const Icon(Icons.line_axis),
              title: const Text('Analysis'),
              onTap: () {
                onMenuAction?.call("shecup-analysis");
              },
            ),
          ],
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.microchip),
          title: const Text('IoT Device'),
          onTap: () {
            onMenuAction?.call("iot");
          },
        ),
        ExpansionTile(
          leading: const FaIcon(FontAwesomeIcons.server),
          title: const Text('Administator'),
          children: <Widget>[
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.users),
              title: const Text('Users Managements'),
              onTap: () {
                onMenuAction?.call("admin-user-management");
              },
            ),
          ],
        ),
        if (["superadmin", "developer"].contains(userController.userData?.role))
          ExpansionTile(
            leading: const FaIcon(FontAwesomeIcons.signsPost),
            title: Text(AppLocalizations.of(context)!.dashboardMenuSuperAdmin),
            children: <Widget>[
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.users),
                title: Text(
                    AppLocalizations.of(context)!.dashboardMenuAdminAccounts),
                onTap: () {
                  onMenuAction?.call("admin-accounts");
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.suitcase),
                title:
                    Text(AppLocalizations.of(context)!.dashboardMenuSiteLists),
                onTap: () {
                  onMenuAction?.call("site-lists");
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.bagShopping),
                title: const Text('Department'),
                onTap: () {
                  onMenuAction?.call("departments");
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Form Creation'),
                onTap: () {
                  onMenuAction?.call("form-creation");
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.getPocket),
                title: const Text('SHEDEIN Creation'),
                onTap: () {
                  onMenuAction?.call("shedein-creation");
                },
              ),
            ],
          ),
        ExpansionTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          children: <Widget>[
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.suitcase),
              title: const Text('Select Site'),
              onTap: () {
                onMenuAction?.call("select-site");
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.sliders),
              title: const Text('Site Settings'),
              onTap: () {
                onMenuAction?.call("site-setting");
              },
            ),
          ],
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.user),
          title: Text(AppLocalizations.of(context)!.dashboardMenuProfile),
          onTap: () {
            onMenuAction?.call("profile");
          },
        ),
      ],
    );
  }
}
