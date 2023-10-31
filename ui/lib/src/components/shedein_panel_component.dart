import 'package:flutter/material.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';

class ShedeinPanelComponent extends StatefulWidget {
  const ShedeinPanelComponent({
    super.key,
    required this.title,
    required this.settingsController,
    required this.userController,
  });

  final String title;
  final SettingsController settingsController;
  final UserController userController;

  @override
  State<ShedeinPanelComponent> createState() => _ShedeinPanelComponentState();
}

class _ShedeinPanelComponentState extends State<ShedeinPanelComponent>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 21, vertical: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                labelText: "Filter",
                hintText: "Filter by name",
              ),
              onChanged: (filter) {},
            ),
            const SizedBox(height: 14),
            const Placeholder(
              fallbackHeight: 300,
            ),
          ],
        ),
      ),
    );
  }
}
