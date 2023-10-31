import 'package:flutter/material.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';

import 'src/app.dart';
import 'src/controllers/settings_controller.dart';
import 'src/services/settings_service.dart';

void main() async {
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  final userController = UserController();
  userController.updateUserData(await userController.getUserServer());

  runApp(VserveApp(
    settingsController: settingsController,
    userController: userController,
  ));
}
