import 'package:flutter/material.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';

class VsafeExamDashboardView extends StatelessWidget {
  const VsafeExamDashboardView(
      {super.key,
      required this.settingsController,
      required this.userController});

  final SettingsController settingsController;
  final UserController userController;
  static const routeName = '/vsafe-exam';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 21, vertical: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              Wrap(
                spacing: 7,
                runSpacing: 7,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text("Easy Level"),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text("Medium Level"),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text("Hard Level"),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text("Expert Level"),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text("Sanitation"),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text("GHP (Good Hygiene Practice)"),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text("HACCP"),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text("ISO 22000"),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text("Food Supplier"),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text("Food Allergen"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
