import 'package:flutter/material.dart';
import 'package:vservesafe/src/components/alert_component.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';

Future<void> showLoadingDialog(
  BuildContext context,
  Function()? afterClose, [
  String? text,
]) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: SettingsController.isDebugMode,
    builder: (BuildContext context) {
      return LoadingAlertDialog(text: text);
    },
  ).whenComplete(() {
    afterClose?.call();
  });
}
