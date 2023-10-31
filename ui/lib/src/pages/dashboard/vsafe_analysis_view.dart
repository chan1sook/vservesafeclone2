import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vservesafe/src/components/tabs_component.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';

class VSafeAnalysisDashboardView extends StatefulWidget {
  const VSafeAnalysisDashboardView({
    super.key,
    required this.settingsController,
    required this.userController,
  });

  final SettingsController settingsController;
  final UserController userController;
  static const routeName = '/vsafe-analysis';

  @override
  State<VSafeAnalysisDashboardView> createState() =>
      _VSafeAnalysisDashboardViewState();
}

class _VSafeAnalysisDashboardViewState
    extends State<VSafeAnalysisDashboardView> {
  int _pageIndex = 0;

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
              DefaultTabController(
                length: 2,
                child: VserveTabBarComponent(
                  onTap: (i) {
                    setState(() {
                      _pageIndex = i;
                    });
                  },
                  tabs: const [
                    VserveHorizontalTabComponent(
                      label: Text("VSAFE Dashboard"),
                    ),
                    VserveHorizontalTabComponent(
                      label: Text("Analysis"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (_pageIndex == 0) _VsafeDashbaordComponent(),
              if (_pageIndex == 1) _VsafeAnalysisComponent(),
            ],
          ),
        ),
      ),
    );
  }
}

class _VsafeDashbaordComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Key Exam Metrics",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Expanded(
                      child: _AnalysisCard(
                        color: Colors.blue,
                        icon: FaIcon(FontAwesomeIcons.users),
                        number: Text("15"),
                        subtitle: Text("Total Examinee"),
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Expanded(
                      child: _AnalysisCard(
                        color: Colors.green,
                        icon: FaIcon(FontAwesomeIcons.circleCheck),
                        number: Text("9"),
                        subtitle: Text("Total Examined"),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _AnalysisCard(
                        color: Colors.purple.shade200,
                        icon: const FaIcon(FontAwesomeIcons.percent),
                        number: const Text("60"),
                        subtitle: const Text("Level Achievement"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Target & Actual by Location/Department",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 14),
                Placeholder(
                  fallbackHeight: 300,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Monthly progress",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 14),
                Placeholder(
                  fallbackHeight: 300,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({
    required this.icon,
    required this.number,
    required this.subtitle,
    this.color,
  });

  final Widget icon;
  final Widget number;
  final Widget subtitle;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  number,
                  const SizedBox(height: 7),
                  subtitle,
                ],
              ),
            ),
            const SizedBox(width: 14),
            icon
          ],
        ),
      ),
    );
  }
}

class _VsafeAnalysisComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: TextField(
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                labelText: "Filter",
                hintText: "Filter by name",
              ),
              onChanged: (filter) {},
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTabController(
                  length: 4,
                  child: TabBar(
                    labelColor: Colors.blue,
                    tabs: [
                      Tab(
                        text: "Response (0)",
                      ),
                      Tab(
                        text: "Summary",
                      ),
                      Tab(
                        text: "Questions",
                      ),
                      Tab(
                        text: "Individual",
                      ),
                    ],
                  ),
                ),
                Placeholder(
                  fallbackHeight: 300,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
