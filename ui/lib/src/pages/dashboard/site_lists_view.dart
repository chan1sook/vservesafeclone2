import 'dart:math' as math;
import 'dart:developer' as developer;

import 'package:collection/collection.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vservesafe/src/components/alert_component.dart';
import 'package:vservesafe/src/components/pagination_component.dart';
import 'package:vservesafe/src/components/status_item_component.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/models/site_data.dart';
import 'package:vservesafe/src/models/site_edit_data.dart';
import 'package:vservesafe/src/models/user_data.dart';
import 'package:vservesafe/src/services/api_service.dart';
import 'package:vservesafe/src/services/settings_service.dart';

class SiteListsDashboardView extends StatefulWidget {
  const SiteListsDashboardView({
    super.key,
    required this.settingsController,
    required this.userController,
  });

  final SettingsController settingsController;
  final UserController userController;
  static const routeName = '/site-lists';

  @override
  State<SiteListsDashboardView> createState() => _SiteListsDashboardViewState();
}

class _SiteListsDashboardViewState extends State<SiteListsDashboardView> {
  bool _isLoadingOpened = false;
  String? _progressText;
  int _pageIndex = 1;
  int _pageSize = 10;

  int? _sortColumnIndex;
  bool _sortAssending = true;

  final List<VserveSiteData> _sites = [];
  final List<VserveUserData> _admins = [];

  @override
  void initState() {
    super.initState();

    _loadSitesData();
    _loadAdminsData();
  }

  @override
  void reassemble() {
    super.reassemble();

    _loadSitesData();
    _loadAdminsData();
  }

  void _loadSitesData() async {
    try {
      final response = await ApiService.dio.get(
        "${ApiService.baseUrlPath}/sites/all",
      );

      List<VserveSiteData> newSites = [];
      final sitesData = response.data["sites"] as List<dynamic>;
      for (final ele in sitesData) {
        if (ele is Map<String, dynamic>) {
          newSites.add(VserveSiteData.parseFromRawData(ele));
        }
      }

      if (mounted) {
        _sites.clear();
        _sites.addAll(newSites);
        _sortSites();

        setState(() {});
      }
    } catch (err) {
      developer.log(err.toString(), name: "Site Lists");
    }
  }

  void _loadAdminsData() async {
    try {
      final response = await ApiService.dio.get(
        "${ApiService.baseUrlPath}/adminusers",
        queryParameters: {
          "with_inactive": false,
          "with_devs": true,
        },
      );

      List<VserveUserData> newUsers = [];
      final sitesData = response.data["users"] as List<dynamic>;
      for (final ele in sitesData) {
        if (ele is Map<String, dynamic>) {
          newUsers.add(VserveUserData.parseFromRawData(ele));
        }
      }

      if (mounted) {
        _admins.clear();
        _admins.addAll(newUsers);
        setState(() {});
      }
    } catch (err) {
      developer.log(err.toString(), name: "User Lists");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: _showNewSiteDialog,
                    child: Text(
                      AppLocalizations.of(context)!.siteListsNewSiteButton,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: ListView(
                  primary: false,
                  shrinkWrap: true,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minWidth: constraints.minWidth),
                          child: DataTable(
                            sortColumnIndex: _sortColumnIndex,
                            sortAscending: _sortAssending,
                            headingTextStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                            columns: [
                              DataColumn(
                                  label: Text(AppLocalizations.of(context)!
                                      .actionTitle)),
                              if (SettingsService.showItemId)
                                DataColumn(
                                  label: Text(
                                      AppLocalizations.of(context)!.idTitle),
                                  onSort: _setSortColumn,
                                ),
                              DataColumn(
                                label: Text(
                                    AppLocalizations.of(context)!.statusTitle),
                                onSort: _setSortColumn,
                              ),
                              DataColumn(
                                label: Text(AppLocalizations.of(context)!
                                    .siteListsNameTitle),
                                onSort: _setSortColumn,
                              ),
                              DataColumn(
                                  label: Text(AppLocalizations.of(context)!
                                      .siteListsNoteTitle)),
                              DataColumn(
                                label: Text(
                                    AppLocalizations.of(context)!.createdTitle),
                                onSort: _setSortColumn,
                              ),
                            ],
                            rows: _filterSites
                                .map((ele) => DataRow(cells: [
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                _showEditSiteDialog(ele);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: const CircleBorder(),
                                                minimumSize: Size.zero,
                                                padding:
                                                    const EdgeInsets.all(18),
                                                backgroundColor: Colors.grey,
                                              ),
                                              child: const Icon(
                                                FontAwesomeIcons.pencil,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                _showDeleteSiteWarning(ele);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: const CircleBorder(),
                                                minimumSize: Size.zero,
                                                padding:
                                                    const EdgeInsets.all(18),
                                                backgroundColor: Colors.orange,
                                              ),
                                              child: const Icon(
                                                FontAwesomeIcons.trash,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (SettingsService.showItemId)
                                        DataCell(Text(ele.id)),
                                      DataCell(
                                        StatusItemComponent(active: ele.active),
                                      ),
                                      DataCell(Text(ele.name)),
                                      DataCell(Text(ele.note)),
                                      DataCell(
                                        Text(
                                          _formatDate(ele.createdAt),
                                        ),
                                      ),
                                    ]))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: PaginationComponent(
                        currentPage: _pageIndex,
                        pageSize: _pageSize,
                        totalElements: _sites.length,
                        onChangePage: (index) {
                          _pageIndex = index;
                          setState(() {});
                        },
                        onPageSizeChange: (size) {
                          _pageSize = size;
                          _pageIndex = 1;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<VserveSiteData> get _filterSites {
    if (_sites.isEmpty) {
      return [];
    }

    int startIndex = _pageSize * (_pageIndex - 1);
    if (_sites.length < startIndex) {
      return [];
    }

    int endIndex = math.min(_pageSize * _pageIndex, _sites.length);
    return _sites.sublist(startIndex, endIndex);
  }

  void _setSortColumn(int columnIndex, bool assending) {
    if (_sortColumnIndex != columnIndex) {
      _sortColumnIndex = columnIndex;
      _sortAssending = assending;
    } else if (_sortAssending == true) {
      _sortAssending = false;
    } else {
      _sortColumnIndex = null;
      _sortAssending = true;
    }

    _sortSites();
    setState(() {});
  }

  String _sortIndexToField(int? index) {
    List<String> fieldHeaders = [
      "",
      if (SettingsService.showItemId) "id",
      "active",
      "name",
      "note",
      "createdAt"
    ];
    if (index != null && index >= 0 && index < fieldHeaders.length) {
      return fieldHeaders[index];
    }

    return "";
  }

  void _sortSites() {
    final column = _sortIndexToField(_sortColumnIndex);
    developer.log("$_sortColumnIndex => $column ($_sortAssending}",
        name: "Sort");

    switch (column) {
      case "id":
        _sites.sort((a, b) =>
            _sortAssending ? a.id.compareTo(b.id) : b.id.compareTo(a.id));
        break;
      case "active":
        _sites.sort((a, b) {
          if (a.active & !b.active) {
            return _sortAssending ? -1 : 1;
          } else if (!a.active & b.active) {
            return _sortAssending ? 1 : -1;
          }
          return 0;
        });
        break;
      case "name":
        _sites.sort((a, b) => _sortAssending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case "note":
        _sites.sort((a, b) => _sortAssending
            ? a.note.compareTo(b.note)
            : b.note.compareTo(a.note));
        break;
      case "createdAt":
        _sites.sort((a, b) => _sortAssending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      default:
        break;
    }
  }

  String _formatDate(DateTime datetime) {
    String head =
        DateFormat.yMd(widget.settingsController.locale.toLanguageTag())
            .format(datetime.toLocal());
    String tail =
        DateFormat.jm(widget.settingsController.locale.toLanguageTag())
            .format(datetime.toLocal());

    return "$head $tail";
  }

  Future<void> _showNewSiteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _SiteFormDialog(
          usersData: _admins,
          onEditSite: _addSite,
        );
      },
    );
  }

  Future<void> _showEditSiteDialog(VserveSiteData siteData) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _SiteFormDialog(
          originalData: siteData,
          usersData: _admins,
          onEditSite: _editSite,
        );
      },
    );
  }

  Future<void> _showDeleteSiteWarning(VserveSiteData siteData) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!
              .siteEditDeleteSiteWarningTitle(siteData.name)),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.confirm),
              onPressed: () {
                _deleteSite(siteData);
              },
            ),
          ],
        );
      },
    );
  }

  void _addSite(VserveEditSiteData editedSiteData) async {
    _showLoadingDialog();

    final uploadLogoProgressText =
        AppLocalizations.of(context)!.siteEditProgressUpdateLogo;
    final addSiteProgressText =
        AppLocalizations.of(context)!.siteEditProgressAddSite;
    final successText =
        AppLocalizations.of(context)!.siteEditAddSiteSuccessfulTitle;
    final failedText = AppLocalizations.of(context)!.siteEditAddSiteFailedTitle;

    try {
      _progressText = addSiteProgressText;
      setState(() {});

      final result = await ApiService.dio.post(
        "${ApiService.baseUrlPath}/site/add",
        data: editedSiteData.toApiData(),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (editedSiteData.newLogoImage != null) {
        _progressText = uploadLogoProgressText;
        setState(() {});
        final imagePath = await _uploadImage(
          result.data["siteData"]["_id"],
          editedSiteData.newLogoImage!,
          true,
        );
        editedSiteData.editedData.logoUrl = imagePath;
      }

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log("Added", name: "Add Site");
      setState(() {});

      await _showSuccessDialog(successText);
    } catch (err) {
      developer.log(err.toString(), name: "Add Site");

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await _showFailedDialog(failedText, err);
    }
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
        data: editedSiteData.toApiData(withId: true),
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

  void _deleteSite(VserveSiteData siteData) async {
    _progressText = null;
    _showLoadingDialog();

    final successText =
        AppLocalizations.of(context)!.siteEditDeleteSiteSuccessfulTitle;
    final failedText =
        AppLocalizations.of(context)!.siteEditDeleteSiteFailedTitle;

    try {
      await ApiService.dio.post(
        "${ApiService.baseUrlPath}/site/delete",
        data: {
          "id": siteData.id,
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log("Deleted", name: "Delete Site");
      setState(() {});

      await _showSuccessDialog(successText);
    } catch (err) {
      developer.log(err.toString(), name: "Delete Site");

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

  Future<void> _showLoadingDialog() async {
    if (_isLoadingOpened) {
      return;
    }

    _isLoadingOpened = true;

    return showDialog<void>(
      context: context,
      barrierDismissible: SettingsController.isDebugMode,
      builder: (BuildContext context) {
        return LoadingAlertDialog(text: _progressText);
      },
    ).then((value) {
      _isLoadingOpened = false;
    });
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
                Navigator.of(context).pop();
                _loadSitesData();
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
}

class _SiteFormDialog extends StatefulWidget {
  const _SiteFormDialog({this.originalData, this.usersData, this.onEditSite});

  final VserveSiteData? originalData;
  final List<VserveUserData>? usersData;
  final Function(VserveEditSiteData)? onEditSite;

  @override
  State<_SiteFormDialog> createState() => _SiteFormDialogState();
}

class _SiteFormDialogState extends State<_SiteFormDialog> {
  final ImagePicker _imagePicker = ImagePicker();

  final VserveEditSiteData _editedSiteData =
      VserveEditSiteData(VserveSiteData());

  final TextEditingController _nameTextFieldCtrl = TextEditingController();
  final TextEditingController _contractEmailTextFieldCtrl =
      TextEditingController();
  final TextEditingController _phoneTextFieldCtrl = TextEditingController();
  final TextEditingController _noteTextFieldCtrl = TextEditingController();

  bool _fullScreen = false;

  @override
  void initState() {
    super.initState();

    if (widget.originalData != null) {
      _editedSiteData.editedData = widget.originalData!.clone();
    }

    _nameTextFieldCtrl.text = _editedSiteData.editedData.name;
    _contractEmailTextFieldCtrl.text = _editedSiteData.editedData.contractEmail;
    _phoneTextFieldCtrl.text = _editedSiteData.editedData.phoneNumber;
    _noteTextFieldCtrl.text = _editedSiteData.editedData.note;
  }

  @override
  Widget build(BuildContext context) {
    const tablePadding = EdgeInsets.symmetric(horizontal: 14, vertical: 7);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: _fullScreen
            ? BorderRadius.zero
            : const BorderRadius.all(Radius.circular(4)),
      ),
      insetPadding: _fullScreen
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 21),
        child: Stack(
          children: [
            ListView(
              children: [
                Text(
                  widget.originalData != null
                      ? AppLocalizations.of(context)!.siteListsEditSiteTitle
                      : AppLocalizations.of(context)!.siteListsNewSiteTitle,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(AppLocalizations.of(context)!
                        .siteListsFormActiveSwitch),
                    const SizedBox(width: 14),
                    Switch(
                      value: _editedSiteData.editedData.active,
                      onChanged: (state) {
                        _editedSiteData.editedData.active = state;
                        setState(() {});
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
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
                              AppLocalizations.of(context)!.siteEditLogoTitle),
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
                                    .siteEditChangeLogoButton),
                              ),
                              if (_editedSiteData.newLogoImage != null)
                                OutlinedButton(
                                  onPressed: _revertPickImage,
                                  child: Text(AppLocalizations.of(context)!
                                      .siteEditRevertLogoButton),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: tablePadding,
                          child: Text(
                              AppLocalizations.of(context)!.siteEditNameTitle),
                        ),
                        Padding(
                          padding: tablePadding,
                          child: TextField(
                            controller: _nameTextFieldCtrl,
                            decoration: const InputDecoration(
                              isDense: true,
                              prefixIcon: Icon(FontAwesomeIcons.suitcase),
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              _editedSiteData.editedData.name = value;
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: tablePadding,
                          child: Text(AppLocalizations.of(context)!
                              .siteEditEmailContractTitle),
                        ),
                        Padding(
                          padding: tablePadding,
                          child: TextField(
                            controller: _contractEmailTextFieldCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              isDense: true,
                              prefixIcon: Icon(FontAwesomeIcons.envelope),
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              _editedSiteData.editedData.contractEmail = value;
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: tablePadding,
                          child: Text(
                              AppLocalizations.of(context)!.siteEditPhoneTitle),
                        ),
                        Padding(
                          padding: tablePadding,
                          child: TextField(
                            controller: _phoneTextFieldCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              isDense: true,
                              prefixIcon: Icon(FontAwesomeIcons.phone),
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              _editedSiteData.editedData.phoneNumber = value;
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: tablePadding,
                          child: Text(AppLocalizations.of(context)!
                              .siteEditAdminsTitle),
                        ),
                        Padding(
                          padding: tablePadding,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MultiSelectDialogField<String>(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                searchable: true,
                                items: (widget.usersData ?? []).map((e) {
                                  return MultiSelectItem(
                                      e.id, "${e.actualName} - ${e.username}");
                                }).toList(),
                                listType: MultiSelectListType.CHIP,
                                chipDisplay: MultiSelectChipDisplay.none(),
                                onConfirm: (values) {
                                  _editedSiteData.editedData.admins = values;
                                  setState(() {});
                                },
                              ),
                              const SizedBox(height: 7),
                              MultiSelectChipDisplay<String>(
                                items:
                                    _editedSiteData.editedData.admins.map((id) {
                                  VserveUserData? target = (widget.usersData ??
                                          [])
                                      .firstWhereOrNull((ele) => ele.id == id);
                                  if (target != null) {
                                    return MultiSelectItem(id,
                                        "${target.actualName} - ${target.username}");
                                  } else {
                                    return MultiSelectItem(id, id);
                                  }
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                            decoration: const InputDecoration(
                              isDense: true,
                              prefixIcon: Icon(FontAwesomeIcons.noteSticky),
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
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
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _editedSiteData.isFormValid
                        ? () {
                            widget.onEditSite?.call(_editedSiteData);
                          }
                        : null,
                    child:
                        Text(AppLocalizations.of(context)!.siteEditSaveButton),
                  ),
                )
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        _fullScreen = !_fullScreen;
                        setState(() {});
                      },
                      child: _fullScreen
                          ? const Icon(Icons.fullscreen_exit)
                          : const Icon(Icons.fullscreen),
                    ),
                  ),
                  const SizedBox(width: 14),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    _editedSiteData.newLogoImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    setState(() => {});
  }

  void _revertPickImage() {
    _editedSiteData.newLogoImage = null;
    setState(() => {});
  }
}
