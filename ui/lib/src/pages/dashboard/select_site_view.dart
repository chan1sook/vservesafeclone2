import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/models/site_data.dart';

class SelectSiteDashboardView extends StatefulWidget {
  const SelectSiteDashboardView({
    super.key,
    required this.settingsController,
    required this.userController,
  });

  final SettingsController settingsController;
  final UserController userController;
  static const routeName = '/select-site';

  @override
  State<SelectSiteDashboardView> createState() =>
      _SiteSettingDashboardViewState();
}

class _SiteSettingDashboardViewState extends State<SelectSiteDashboardView> {
  late Timer _timer;
  List<VserveSiteData> _sites = [];
  VserveSiteData? _selectedSite;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      final newSites = widget.userController.avalaibleSites;
      if (newSites != _sites) {
        _sites = newSites;
        _selectedSite = await widget.userController.loadFirstSiteByPref();
        setState(() {});
      } else {
        final newSelectedSite = widget.userController.selectedSite;
        if (newSelectedSite != _selectedSite) {
          _selectedSite = newSelectedSite;
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      primary: false,
      shrinkWrap: true,
      children: [
        Text(
          AppLocalizations.of(context)!.selectSiteTitle,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth - 28;
          final crossAxisCount = math.max((width ~/ 600).round(), 1).toInt();

          return GridView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: _sites.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: 150,
            ),
            itemBuilder: (context, index) {
              final site = _sites[index];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {},
                  child: Card(
                    color: _selectedSite != null && site.id == _selectedSite?.id
                        ? Colors.blue.shade200
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage: NetworkImage(site.serverLogoUrl),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  site.name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(site.contractEmail.isNotEmpty
                                    ? site.contractEmail
                                    : "-"),
                                const SizedBox(height: 7),
                                ElevatedButton(
                                  onPressed: () {
                                    _onChangeSite(site);
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .selectSiteSelectButton,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        })
      ],
    );
  }

  Future<void> _onChangeSite(VserveSiteData? value) async {
    await widget.userController.updateSelectedSite(value);

    setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
