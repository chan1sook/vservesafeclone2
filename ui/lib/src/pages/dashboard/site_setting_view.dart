import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cross_file_image/cross_file_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vservesafe/src/components/langswitch_component.dart';
import 'package:vservesafe/src/components/quill_editor_component.dart';
import 'package:vservesafe/src/components/scrollable_container.dart';
import 'package:vservesafe/src/components/tabs_component.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/models/site_data.dart';
import 'package:vservesafe/src/models/site_edit_data.dart';
import 'package:vservesafe/src/services/api_service.dart';
import 'package:vservesafe/src/utils/alert_dialog.dart';

class SiteSettingDashboardView extends StatefulWidget {
  const SiteSettingDashboardView({
    super.key,
    required this.settingsController,
    required this.userController,
  });

  final SettingsController settingsController;
  final UserController userController;
  static const routeName = '/site-settings';

  @override
  State<SiteSettingDashboardView> createState() =>
      _SiteSettingDashboardViewState();
}

class _SiteSettingDashboardViewState extends State<SiteSettingDashboardView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Timer _timer;
  String? _progressText;
  bool _isLoadingSite = true;
  bool _isLoadingOpened = false;
  VserveSiteData? _siteData;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final site = widget.userController.selectedSite;

      if (_siteData?.id != site?.id) {
        _siteData = site;
        _isLoadingSite = true;
        _loadFullSiteData();
        setState(() {});
      }
    });

    _tabController = TabController(length: 2, vsync: this);
    _siteData = widget.userController.selectedSite;

    _loadFullSiteData();
  }

  void _loadFullSiteData() async {
    VserveSiteData? fullData = _siteData;

    if (_siteData != null) {
      try {
        final response = await ApiService.dio.get(
          "${ApiService.baseUrlPath}/site/${_siteData!.id}",
        );

        final usersData = response.data["site"] as Map<String, dynamic>;
        fullData = VserveSiteData.parseFromRawData(usersData);
        _siteData = fullData;
      } catch (err) {
        developer.log(err.toString(), name: "Site Full Data");
      }
    }

    _isLoadingSite = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Card(
          child: _isLoadingSite
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.loadingDialogText,
                    style: const TextStyle(fontSize: 21),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    VserveTabBarComponent(
                      tabs: [
                        VserveHorizontalTabComponent(
                          icon: const FaIcon(FontAwesomeIcons.pencil),
                          label: Text(AppLocalizations.of(context)!
                              .siteSettingGeneralTab),
                        ),
                        VserveHorizontalTabComponent(
                          icon: const FaIcon(FontAwesomeIcons.book),
                          label: Text(AppLocalizations.of(context)!
                              .siteSettingCatergoryTab),
                        ),
                      ],
                      controller: _tabController,
                      onTap: (index) {
                        _tabController.index = index;
                        setState(() {});
                      },
                    ),
                    if (_tabController.index == 0)
                      _SiteSettingTabView(
                        userController: widget.userController,
                        siteData: _siteData,
                        onSubmitForm: _editSite,
                      ),
                    if (_tabController.index == 1)
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: Text("TODO: Catergory"),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _showLoadingDialog() async {
    if (_isLoadingOpened) {
      return;
    }

    _isLoadingOpened = true;

    return showLoadingDialog(
      context,
      () {
        _isLoadingOpened = false;
        setState(() {});
      },
      _progressText,
    );
  }

  void _editSite(VserveEditSiteData editedSiteData) async {
    _showLoadingDialog();

    final uploadLogoProgressText =
        AppLocalizations.of(context)!.siteEditProgressUpdateLogo;
    final editSiteProgressText =
        AppLocalizations.of(context)!.siteEditProgressEditSite;
    final successText =
        AppLocalizations.of(context)!.siteEditEditSiteSuccessfulTitle;
    final failedText =
        AppLocalizations.of(context)!.siteEditEditSiteFailedTitle;

    try {
      if (editedSiteData.newLogoImage != null) {
        _progressText = uploadLogoProgressText;
        setState(() {});
        final imagePath = await _uploadImage(
          editedSiteData.editedData.id,
          editedSiteData.newLogoImage!,
        );
        editedSiteData.editedData.logoUrl = imagePath;
      }

      _progressText = editSiteProgressText;
      setState(() {});

      await ApiService.dio.post(
        "${ApiService.baseUrlPath}/site/edit",
        data: editedSiteData.toApiData(withId: true, noAdmins: true),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log("Edited", name: "Edit Site");
      setState(() {});

      await _showSuccessDialog(successText);
    } catch (err) {
      developer.log(err.toString(), name: "Edit Site");

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await _showFailedDialog(failedText, err);
    }
  }

  Future<String> _uploadImage(String id, XFile imageFile,
      [replaceImage = false]) async {
    late FormData formData;
    if (kIsWeb) {
      formData = FormData.fromMap({
        'logo': MultipartFile.fromBytes(await imageFile.readAsBytes(),
            filename: imageFile.path,
            contentType: imageFile.mimeType != null
                ? MediaType.parse(imageFile.mimeType!)
                : null),
        "id": id,
        "replace": replaceImage,
      });
    } else {
      formData = FormData.fromMap({
        'logo': await MultipartFile.fromFile(imageFile.path),
        "id": id,
        "replace": replaceImage,
      });
    }

    final result = await ApiService.dio.post(
      "${ApiService.baseUrlPath}/site-logo/update",
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
      ),
    );

    developer.log(result.data["path"], name: "Logo Path");

    return result.data["path"];
  }

  Future<void> _showSuccessDialog(String title) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFailedDialog(String title, Object err) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    AppLocalizations.of(context)!.errorMessage(err.toString())),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class _SiteSettingTabView extends StatefulWidget {
  const _SiteSettingTabView({
    required this.userController,
    this.siteData,
    this.onSubmitForm,
  });

  final UserController userController;
  final VserveSiteData? siteData;
  final Function(VserveEditSiteData)? onSubmitForm;

  @override
  State<_SiteSettingTabView> createState() => _SiteSettingTabViewState();
}

class _SiteSettingTabViewState extends State<_SiteSettingTabView> {
  final ImagePicker _imagePicker = ImagePicker();
  late VserveEditSiteData _editedSiteData;
  final TextEditingController _noteTextFieldCtrl = TextEditingController();

  final QuillController _welcomeScreenEnController = QuillController.basic();
  final QuillController _welcomeScreenThController = QuillController.basic();

  Locale _selectedLocale = SettingsController.supportedLocales[0];
  StreamSubscription? _welcomeEnSubscription;
  StreamSubscription? _welcomeThSubscription;

  @override
  void initState() {
    super.initState();
    _editedSiteData = VserveEditSiteData(widget.siteData ?? VserveSiteData());
    _noteTextFieldCtrl.text = _editedSiteData.editedData.note;

    try {
      _welcomeScreenEnController.document = Document.fromJson(
          jsonDecode(_editedSiteData.editedData.welcomeScreenEn));
    } catch (err) {
      developer.log("parse error: _welcomeScreenEnController", name: "Quill");
    }

    try {
      _welcomeScreenThController.document = Document.fromJson(
          jsonDecode(_editedSiteData.editedData.welcomeScreenTh));
    } catch (err) {
      developer.log("parse error: _welcomeScreenThController", name: "Quill");
    }

    _welcomeEnSubscription =
        _welcomeScreenEnController.document.changes.listen((event) {
      _editedSiteData.editedData.welcomeScreenEn =
          jsonEncode(_welcomeScreenEnController.document.toDelta().toJson());
    });
    _welcomeThSubscription =
        _welcomeScreenThController.document.changes.listen((event) {
      _editedSiteData.editedData.welcomeScreenTh =
          jsonEncode(_welcomeScreenThController.document.toDelta().toJson());
    });
  }

  @override
  Widget build(BuildContext context) {
    const tablePadding = EdgeInsets.symmetric(horizontal: 14, vertical: 7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 14),
      child: ScrollableContainerComponent(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Table(
              columnWidths: const {0: IntrinsicColumnWidth()},
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: const TableBorder(
                horizontalInside: BorderSide(color: Colors.black12),
                verticalInside: BorderSide(color: Colors.black12),
              ),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: tablePadding,
                      child: Text(
                          AppLocalizations.of(context)!.profileEditAvatarTitle),
                    ),
                    Padding(
                      padding: tablePadding,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 7,
                        spacing: 7,
                        children: [
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: _editedSiteData.newLogoImage != null
                                ? CircleAvatar(
                                    backgroundImage: XFileImage(
                                        _editedSiteData.newLogoImage!),
                                  )
                                : CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        _editedSiteData
                                            .editedData.serverLogoUrl),
                                  ),
                          ),
                          OutlinedButton(
                            onPressed: _pickImage,
                            child: Text(AppLocalizations.of(context)!
                                .profileEditChangeAvatarButton),
                          ),
                          if (_editedSiteData.newLogoImage != null)
                            OutlinedButton(
                              onPressed: _revertPickImage,
                              child: Text(AppLocalizations.of(context)!
                                  .profileEditRevertAvatarButton),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                TableRow(children: [
                  Padding(
                    padding: tablePadding,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppLocalizations.of(context)!
                            .siteEditWelcomeScreenTitle),
                        const SizedBox(height: 14),
                        DashboardLanguageSwitchComponent(
                          selectedLocale: _selectedLocale,
                          onSwitchLanguage: (locale) {
                            _selectedLocale = locale;
                            setState(() {});
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 500,
                    padding: tablePadding,
                    decoration: const BoxDecoration(),
                    clipBehavior: Clip.hardEdge,
                    child: QuillEditorComponent(
                      controller: _welcomeCtrlLocale(),
                    ),
                  ),
                ]),
                TableRow(
                  children: [
                    Padding(
                      padding: tablePadding,
                      child: Text(
                          AppLocalizations.of(context)!.siteEditNotesTitle),
                    ),
                    Padding(
                      padding: tablePadding,
                      child: TextField(
                        controller: _noteTextFieldCtrl,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                          isDense: true,
                          prefixIcon: Icon(FontAwesomeIcons.noteSticky),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _editedSiteData.editedData.note = value;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Center(
              child: ElevatedButton(
                onPressed: _editedSiteData.isFormValid
                    ? () {
                        widget.onSubmitForm?.call(_editedSiteData);
                      }
                    : null,
                child: Text(AppLocalizations.of(context)!.siteEditSaveButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    _editedSiteData.newLogoImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  void _revertPickImage() {
    _editedSiteData.newLogoImage = null;
    setState(() {});
  }

  QuillController _welcomeCtrlLocale() {
    if (_selectedLocale.languageCode.startsWith("th")) {
      return _welcomeScreenThController;
    }
    return _welcomeScreenEnController;
  }

  @override
  void dispose() {
    _welcomeEnSubscription?.cancel();
    _welcomeThSubscription?.cancel();
    super.dispose();
  }
}
