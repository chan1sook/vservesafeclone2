import 'package:flutter/material.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';

class ShecupExamDashboardView extends StatelessWidget {
  ShecupExamDashboardView(
      {super.key,
      required this.settingsController,
      required this.userController});

  final SettingsController settingsController;
  final UserController userController;
  static const routeName = '/shecup-exam';

  final List<String> _examsList = [
    "Annual Health check-up for employees",
    "Calibration",
    "Exhaust hood cleaning",
    "Fire extinguisher",
    "Food analysis verification/validation",
    "Food analysis verification/validation",
    "Supplier Perfomance Review Register",
    "Internal audit/Monty audit",
    "Supplier Perfomance Review Register",
    "Internal audit/Monty audit",
  ];

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
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: GridView.builder(
                    itemCount: _examsList.length,
                    shrinkWrap: true,
                    primary: false,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 4),
                    itemBuilder: (context, index) {
                      return Card(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.only(left: 14),
                          ),
                          onPressed: () {},
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(7),
                              ),
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints.expand(),
                              child: Center(
                                child: Text(_examsList[index]),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
