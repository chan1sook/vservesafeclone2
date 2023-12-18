import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vservesafe/src/models/site_data.dart';
import 'package:vservesafe/src/pages/dashboard/admin_accounts_view.dart';
import 'package:vservesafe/src/pages/dashboard/admin_user_management_view.dart';
import 'package:vservesafe/src/pages/dashboard/departments_view.dart';
import 'package:vservesafe/src/pages/dashboard/device_management_view.dart';
import 'package:vservesafe/src/pages/dashboard/form_creation_view.dart';
import 'package:vservesafe/src/pages/dashboard/home_view.dart';
import 'package:vservesafe/src/pages/dashboard/iot_view.dart';
import 'package:vservesafe/src/pages/dashboard/profile_view.dart';
import 'package:vservesafe/src/pages/dashboard/select_site_view.dart';
import 'package:vservesafe/src/pages/dashboard/shecup_analysis_view.dart';
import 'package:vservesafe/src/pages/dashboard/shecup_exam_view.dart';
import 'package:vservesafe/src/pages/dashboard/shedein_creation_view.dart';
import 'package:vservesafe/src/pages/dashboard/shedein_decision_view.dart';
import 'package:vservesafe/src/pages/dashboard/shedein_environment_view.dart';
import 'package:vservesafe/src/pages/dashboard/shedein_foodsafety/shedein_foodsafety_view.dart';
import 'package:vservesafe/src/pages/dashboard/shedein_hygiene_view.dart';
import 'package:vservesafe/src/pages/dashboard/site_lists_view.dart';
import 'package:vservesafe/src/pages/dashboard/site_setting_view.dart';
import 'package:vservesafe/src/pages/dashboard/vsafe_analysis_view.dart';
import 'package:vservesafe/src/pages/dashboard/vsafe_exam_view.dart';

class MenuItemData {
  String key;
  String localizedText = "";
  String? subroute;
  IconData? icon;
  List<MenuItemData> submenu = [];

  MenuItemData({
    this.key = "",
    this.icon,
    this.subroute,
    List<MenuItemData>? submenu,
  }) {
    if (submenu != null) {
      this.submenu = submenu;
    }
  }

  String translatedText(BuildContext context) {
    switch (key) {
      case "home":
        return AppLocalizations.of(context)!.dashboardMenuHome;
      case "vsafe":
        return "VSAFE";
      case "vsafe-exam":
        return "Exam";
      case "vsafe-analysis":
        return "Analysis";
      case "shedein":
        return "SHEDEIN";
      case "shedein-foodsafety":
        return AppLocalizations.of(context)!.dashboardMenuShedeinFoodSafety;
      case "shedein-hygiene":
        return "Occupational Health & Safety";
      case "shedein-environment":
        return "Environment & Sustainability";
      case "shedein-decision":
        return "Decision Intelligence";
      case "shecup":
        return "SHEC UP";
      case "shecup-exam":
        return "Exam";
      case "shecup-analysis":
        return "Analysis";
      case "iot-dashboard":
        return AppLocalizations.of(context)!.dashboardMenuIot;
      case "admin":
        return AppLocalizations.of(context)!.dashboardMenuAdmin;
      case "admin-user-management":
        return AppLocalizations.of(context)!.dashboardMenuUsersManager;
      case "device-management":
        return AppLocalizations.of(context)!.dashboardMenuDeviceManagement;
      case "superadmin":
        return AppLocalizations.of(context)!.dashboardMenuSuperAdmin;
      case "admin-accounts":
        return AppLocalizations.of(context)!.dashboardMenuAdminAccounts;
      case "site-lists":
        return AppLocalizations.of(context)!.dashboardMenuSiteLists;
      case "departments":
        return AppLocalizations.of(context)!.dashboardMenuDepartment;
      case "form-creation":
        return "Form Creation";
      case "shedein-creation":
        return "SHEDEIN Creation";
      case "setting":
        return AppLocalizations.of(context)!.dashboardMenuSetting;
      case "select-site":
        return AppLocalizations.of(context)!.dashboardMenuSelectSite;
      case "site-settings":
        return AppLocalizations.of(context)!.dashboardMenuSiteSetting;
      case "profile":
        return AppLocalizations.of(context)!.dashboardMenuProfile;
    }
    return key;
  }

  static Color getColorByState({
    bool active = false,
    bool isHover = false,
  }) {
    return active
        ? Colors.indigo
        : isHover
            ? Colors.indigo.shade400
            : Colors.grey.shade200;
  }
}

List<MenuItemData> dashboardMenuListFrom(
    {VserveSiteData? selectedSite, String? role}) {
  final defaultRole = role ?? "user";
  final isAdminRole = defaultRole == "admin";
  final isSuperAdminRole = defaultRole == "superadmin";
  final isDeveloper = defaultRole == "developer";

  final superAdminLevel = isSuperAdminRole || isDeveloper;
  final adminLevel = isAdminRole || superAdminLevel;
  return [
    MenuItemData(
        key: "home", subroute: HomeDashboardView.routeName, icon: Icons.home),
    MenuItemData(
      key: "vsafe",
      icon: Icons.shield,
      submenu: [
        MenuItemData(
            key: "vsafe-exam",
            subroute: VsafeExamDashboardView.routeName,
            icon: FontAwesomeIcons.book),
        MenuItemData(
            key: "vsafe-analysis",
            subroute: VSafeAnalysisDashboardView.routeName,
            icon: Icons.line_axis),
      ],
    ),
    MenuItemData(
      key: "shedein",
      icon: FontAwesomeIcons.getPocket,
      submenu: [
        MenuItemData(
            key: "shedein-foodsafety",
            subroute: ShedeinFoodsafetyDashboardView.routeName,
            icon: Icons.shield),
        MenuItemData(
            key: "shedein-hygiene",
            subroute: ShedeinHygieneDashboardView.routeName,
            icon: FontAwesomeIcons.faceSmile),
        MenuItemData(
            key: "shedein-environment",
            subroute: ShedeinEnvironmentDashboardView.routeName,
            icon: FontAwesomeIcons.flask),
        MenuItemData(
            key: "shedein-decision",
            subroute: ShedeinDecisionDashboardView.routeName,
            icon: Icons.tv),
      ],
    ),
    MenuItemData(
      key: "shecup",
      icon: Icons.check_circle,
      submenu: [
        MenuItemData(
            key: "shecup-exam",
            subroute: ShecupExamDashboardView.routeName,
            icon: FontAwesomeIcons.book),
        MenuItemData(
            key: "shecup-analysis",
            subroute: ShecupAnalysisDashboardView.routeName,
            icon: Icons.line_axis),
      ],
    ),
    if (selectedSite != null)
      MenuItemData(
          key: "iot-dashboard",
          subroute: IotDashboardView.routeName,
          icon: FontAwesomeIcons.microchip),
    if (adminLevel && selectedSite != null)
      MenuItemData(
        key: "admin",
        icon: FontAwesomeIcons.server,
        submenu: [
          MenuItemData(
              key: "admin-user-management",
              subroute: AdminUserManagerDashboardView.routeName,
              icon: FontAwesomeIcons.users),
          MenuItemData(
              key: "device-management",
              subroute: DeviceManagementDashboardView.routeName,
              icon: FontAwesomeIcons.microchip),
        ],
      ),
    if (superAdminLevel)
      MenuItemData(
        key: "superadmin",
        icon: FontAwesomeIcons.signsPost,
        submenu: [
          MenuItemData(
              key: "admin-accounts",
              subroute: AdminAccountsDashboardView.routeName,
              icon: FontAwesomeIcons.users),
          MenuItemData(
              key: "site-lists",
              subroute: SiteListsDashboardView.routeName,
              icon: FontAwesomeIcons.suitcase),
          MenuItemData(
              key: "departments",
              subroute: DepartmentListsDashboardView.routeName,
              icon: FontAwesomeIcons.bagShopping),
          MenuItemData(
              key: "form-creation",
              subroute: FormCreationDashboardView.routeName,
              icon: FontAwesomeIcons.list),
          MenuItemData(
              key: "shedein-creation",
              subroute: ShedeinCreationDashboardView.routeName,
              icon: FontAwesomeIcons.getPocket),
        ],
      ),
    if (selectedSite != null)
      MenuItemData(
        key: "setting",
        icon: Icons.settings,
        submenu: [
          MenuItemData(
              key: "select-site",
              subroute: SelectSiteDashboardView.routeName,
              icon: FontAwesomeIcons.suitcase),
          if (adminLevel)
            MenuItemData(
                key: "site-settings",
                subroute: SiteSettingDashboardView.routeName,
                icon: FontAwesomeIcons.sliders),
        ],
      ),
    MenuItemData(
        key: "profile",
        subroute: ProfileDashboardView.routeName,
        icon: FontAwesomeIcons.user),
  ];
}
