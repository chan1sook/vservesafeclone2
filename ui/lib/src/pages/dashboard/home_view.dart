import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/models/site_data.dart';
import 'package:vservesafe/src/services/api_service.dart';

class HomeDashboardView extends StatefulWidget {
  const HomeDashboardView({
    super.key,
    required this.settingsController,
    required this.userController,
  });

  final SettingsController settingsController;
  final UserController userController;
  static const routeName = '/';

  @override
  State<HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<HomeDashboardView> {
  VserveSiteData? _currentSiteData;
  final QuillController _welcomeScreenController = QuillController.basic();
  late Timer _timer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final site = widget.userController.selectedSite;

      if (_currentSiteData?.id != site?.id) {
        _currentSiteData = site;
        _loading = true;
        _loadExtraData();
        setState(() {});
      }
    });
    _loadExtraData();
  }

  void _loadExtraData() async {
    VserveSiteData? homeSiteData = widget.userController.selectedSite;
    if (homeSiteData != null) {
      try {
        final response = await ApiService.dio.get(
          "${ApiService.baseUrlPath}/site/${homeSiteData.id}",
        );

        final usersData = response.data["site"] as Map<String, dynamic>;
        _currentSiteData = VserveSiteData.parseFromRawData(usersData);
      } catch (err) {
        developer.log(err.toString(), name: "Site Full Data");
      }
    }
    _loading = false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _containerWidget(Center(
        child: Text(
          AppLocalizations.of(context)!.loadingDialogText,
          style: const TextStyle(fontSize: 21),
        ),
      ));
    }

    try {
      if (_currentSiteData != null) {
        final lang = widget.settingsController.locale.toLanguageTag();
        _welcomeScreenController.document = Document.fromJson(jsonDecode(
            lang.startsWith("th")
                ? _currentSiteData!.welcomeScreenTh
                : _currentSiteData!.welcomeScreenEn));
      } else {
        return _containerWidget(_defaultHomeWidget());
      }
    } catch (err) {
      developer.log("parse error: _welcomeScreenController", name: "Quill");
      return _containerWidget(_defaultHomeWidget());
    }

    return _containerWidget(QuillProvider(
      configurations: QuillConfigurations(
        controller: _welcomeScreenController,
        sharedConfigurations: const QuillSharedConfigurations(
          locale: Locale("en", "US"),
        ),
      ),
      child: QuillEditor.basic(
        configurations: QuillEditorConfigurations(
          readOnly: true,
          embedBuilders: kIsWeb
              ? FlutterQuillEmbeds.editorWebBuilders()
              : FlutterQuillEmbeds.editorBuilders(),
        ),
      ),
    ));
  }

  Widget _containerWidget(Widget child) {
    return Center(
      child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 21, vertical: 14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: child,
          )),
    );
  }

  Widget _defaultHomeWidget() => Center(
        child: Image.asset(
          "assets/images/home-logo-full.png",
        ),
      );

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
