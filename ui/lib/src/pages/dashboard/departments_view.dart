import 'package:flutter/material.dart';
import 'package:vservesafe/src/components/shedein_panel_component.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';

class DepartmentListsDashboardView extends StatelessWidget {
  const DepartmentListsDashboardView({
    super.key,
    required this.settingsController,
    required this.userController,
  });

  final SettingsController settingsController;
  final UserController userController;
  static const routeName = '/departments';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      child: ShedeinPanelComponent(
        title: "Departments",
        settingsController: settingsController,
        userController: userController,
      ),
    );
  }
}
