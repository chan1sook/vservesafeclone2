import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vservesafe/src/components/dashboard_menu/dashboard_horizontal_menu.dart';
import 'package:vservesafe/src/components/dashboard_menu/site_selected_component.dart';
import 'package:vservesafe/src/models/dashboard_menu_item.dart';
import 'package:vservesafe/src/components/dashboard_menu/dashboard_vertical_menu.dart';
import 'package:vservesafe/src/components/langswitch_component.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/models/site_data.dart';

class DashboardComponent extends StatefulWidget {
  const DashboardComponent({
    super.key,
    required this.userController,
    required this.settingsController,
    this.subroute,
    this.onMenuAction,
    this.child,
  });

  final UserController userController;
  final SettingsController settingsController;
  final String? subroute;
  final Function(String)? onMenuAction;
  final Widget? child;

  @override
  State<DashboardComponent> createState() => _DashboardComponentState();
}

class _DashboardComponentState extends State<DashboardComponent> {
  late Timer _timer;
  bool _activeMenu = false;
  List<VserveSiteData> _sites = [];
  VserveSiteData? _selectedSite;

  @override
  void initState() {
    super.initState();

    _sites = widget.userController.avalaibleSites;
    _selectedSite = widget.userController.selectedSite;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      final newSites = widget.userController.avalaibleSites;
      if (newSites != _sites) {
        _sites = newSites;
        _selectedSite = await widget.userController.loadFirstSiteByPref();
        setState(() {});
      } else {
        final newSelectedSite = widget.userController.selectedSite;
        if (newSelectedSite == null && _sites.isNotEmpty) {
          _selectedSite = await widget.userController.loadFirstSiteByPref();
          widget.userController.updateSelectedSite(_selectedSite);
          setState(() {});
        } else if (newSelectedSite != _selectedSite) {
          _selectedSite = newSelectedSite;
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuList = dashboardMenuListFrom(
        selectedSite: _selectedSite,
        role: widget.userController.userData?.role);
    const minimumWidth = 1000;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: true,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade500, width: 0.5),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final logoWidget = Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 7),
                      child: _HeaderLogoComponent(),
                    );

                    if (width < minimumWidth) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _MenuIconComponent(
                            active: _activeMenu,
                            onClick: () {
                              _activeMenu = !_activeMenu;
                              setState(() {});
                            },
                          ),
                          Expanded(
                            child: logoWidget,
                          ),
                          _UserMenuComponentDropdown(
                            userController: widget.userController,
                            onMenuAction: widget.onMenuAction,
                            child: _UserAvatarComponent(
                              userController: widget.userController,
                              collasped: true,
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        logoWidget,
                        const SizedBox(width: 14),
                        Flexible(
                          flex: 3,
                          fit: FlexFit.loose,
                          child: SiteSelectedComponent(
                            sites: _sites,
                            selectedSite: _selectedSite,
                            onChangeSite: _onChangeSite,
                          ),
                        ),
                        const Spacer(),
                        DashboardLanguageSwitchComponent(
                          selectedLocale: widget.settingsController.locale,
                          onSwitchLanguage: _onSwitchLanguage,
                        ),
                        const SizedBox(width: 14),
                        _AlertComponent(),
                        const SizedBox(width: 14),
                        _UserMenuComponentDropdown(
                          userController: widget.userController,
                          onMenuAction: widget.onMenuAction,
                          child: _UserAvatarComponent(
                            userController: widget.userController,
                            collasped: false,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return LayoutBuilder(builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    return width < minimumWidth
                        ? _activeMenu
                            ? MenuVerticalBarComponent(
                                menuList: menuList,
                                subroute: widget.subroute,
                                onMenuAction: widget.onMenuAction,
                                header: Row(
                                  children: [
                                    Expanded(
                                      child: SiteSelectedComponent(
                                        sites: _sites,
                                        selectedSite: _selectedSite,
                                        onChangeSite: _onChangeSite,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    DashboardLanguageSwitchComponent(
                                      selectedLocale:
                                          widget.settingsController.locale,
                                      onSwitchLanguage: _onSwitchLanguage,
                                    ),
                                  ],
                                ),
                              )
                            : Container()
                        : MenuHorizontalBarComponent(
                            menuList: menuList,
                            subroute: widget.subroute,
                            onMenuAction: widget.onMenuAction,
                          );
                  });
                },
                childCount: 1,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return widget.child ?? Container();
                },
                childCount: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSwitchLanguage(Locale locale) async {
    await widget.settingsController.updateLocale(locale);
    setState(() {});
  }

  Future<void> _onChangeSite(VserveSiteData? siteData) async {
    await widget.userController.updateSelectedSite(siteData);
    setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class _HeaderLogoComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/home-logo-full.png",
      height: 48,
    );
  }
}

class _UserMenuComponentDropdown extends StatelessWidget {
  const _UserMenuComponentDropdown({
    required this.userController,
    required this.child,
    this.onMenuAction,
  });
  final UserController userController;
  final Widget child;
  final Function(String)? onMenuAction;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: "User",
      onSelected: (action) {
        onMenuAction?.call(action);
      },
      position: PopupMenuPosition.under,
      offset: const Offset(0, 14),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: "edit-profile",
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.penToSquare,
                  color: Theme.of(context).textTheme.labelMedium?.color,
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
                  color: Theme.of(context).textTheme.labelMedium?.color,
                ),
                const SizedBox(width: 14),
                Text(AppLocalizations.of(context)!.dashboardLogoutDropdownMenu),
              ],
            ),
          ),
        ];
      },
      child: child,
    );
  }
}

class _UserAvatarComponent extends StatelessWidget {
  const _UserAvatarComponent({
    this.collasped = false,
    required this.userController,
  });
  final UserController userController;
  final bool collasped;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 14, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!collasped) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  userController.userData!.username,
                ),
                Text(
                  (userController.userData!.role).toUpperCase(),
                  style: const TextStyle(color: Colors.black45),
                ),
              ],
            ),
            const SizedBox(width: 14),
          ],
          CircleAvatar(
            backgroundImage: userController.userData?.serverAvatarUrl != null
                ? NetworkImage(userController.userData!.serverAvatarUrl)
                : null,
          ),
        ],
      ),
    );
  }
}

class _AlertComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
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
    );
  }
}

class _MenuIconComponent extends StatefulWidget {
  const _MenuIconComponent({
    this.active = false,
    this.onClick,
  });
  final bool active;
  final Function()? onClick;

  @override
  State<_MenuIconComponent> createState() => _MenuIconComponentState();
}

class _MenuIconComponentState extends State<_MenuIconComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.active) {
      _controller.animateTo(1);
    } else {
      _controller.animateBack(0);
    }

    return IconButton(
      onPressed: widget.onClick,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      icon: AnimatedIcon(
        progress: Tween<double>(begin: 0, end: 1).animate(_controller),
        icon: AnimatedIcons.menu_close,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
