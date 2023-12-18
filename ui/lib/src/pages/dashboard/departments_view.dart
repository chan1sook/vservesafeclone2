import 'dart:async';
import 'dart:math' as math;
import 'dart:developer' as developer;

import 'package:collection/collection.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:vservesafe/src/components/icon_button_component.dart';
import 'package:vservesafe/src/components/pagination_component.dart';
import 'package:vservesafe/src/components/scrollable_container.dart';
import 'package:vservesafe/src/components/status_item_component.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/models/department_data.dart';
import 'package:vservesafe/src/models/department_edit_data.dart';
import 'package:vservesafe/src/services/api_service.dart';
import 'package:vservesafe/src/services/settings_service.dart';
import 'package:vservesafe/src/utils/alert_dialog.dart';

class DepartmentListsDashboardView extends StatefulWidget {
  const DepartmentListsDashboardView({
    super.key,
    required this.settingsController,
    required this.userController,
  });

  final SettingsController settingsController;
  final UserController userController;
  static const routeName = '/departments';

  @override
  State<DepartmentListsDashboardView> createState() =>
      _DepartmentListsDashboardViewState();
}

class _DepartmentListsDashboardViewState
    extends State<DepartmentListsDashboardView> {
  late Timer _timer;
  bool _isLoadingOpened = false;
  String? _progressText;
  int _pageIndex = 1;
  int _pageSize = 10;

  int? _sortColumnIndex;
  bool _sortAscending = true;

  final List<VserveDepartmentData> _departments = [];
  String? _siteId;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final site = widget.userController.selectedSiteId;
      if (_siteId != site) {
        _siteId = site;
        _loadDepartmentsData();
      }
    });

    _loadDepartmentsData();
  }

  @override
  void reassemble() {
    super.reassemble();

    _loadDepartmentsData();
  }

  void _loadDepartmentsData() async {
    if (_siteId == null) {
      return;
    }

    try {
      final response = await ApiService.dio.get(
        "${ApiService.baseUrlPath}/departments/site/${_siteId!}",
      );

      List<VserveDepartmentData> newDepartments = [];
      final departmentsData = response.data["departments"] as List<dynamic>;
      for (final ele in departmentsData) {
        if (ele is Map<String, dynamic>) {
          newDepartments.add(VserveDepartmentData.parseFromRawData(ele));
        }
      }

      if (mounted) {
        _departments.clear();
        _departments.addAll(newDepartments);
        _sortDepartments();
        setState(() {});
      }
    } catch (err) {
      developer.log(err.toString(), name: "Department Lists");
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
                    onPressed: () {
                      _showAddDepartmentDialog();
                    },
                    child: Text(
                      AppLocalizations.of(context)!
                          .departmentsNewDepartmentButton,
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
                            sortAscending: _sortAscending,
                            headingTextStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                            columns: [
                              DataColumn(
                                label: Text(
                                    AppLocalizations.of(context)!.actionTitle),
                                tooltip:
                                    AppLocalizations.of(context)!.actionTitle,
                              ),
                              if (SettingsService.showItemId)
                                DataColumn(
                                  label: Text(
                                      AppLocalizations.of(context)!.idTitle),
                                  tooltip:
                                      AppLocalizations.of(context)!.idTitle,
                                  onSort: _setSortColumn,
                                ),
                              DataColumn(
                                label: Text(
                                    AppLocalizations.of(context)!.statusTitle),
                                tooltip:
                                    AppLocalizations.of(context)!.statusTitle,
                                onSort: _setSortColumn,
                              ),
                              DataColumn(
                                label: Text(AppLocalizations.of(context)!
                                    .departmentsNameTitle),
                                tooltip: AppLocalizations.of(context)!
                                    .departmentsNameTitle,
                                onSort: _setSortColumn,
                              ),
                              DataColumn(
                                label: Text(AppLocalizations.of(context)!
                                    .departmentsNoteTitle),
                                tooltip: AppLocalizations.of(context)!
                                    .departmentsNoteTitle,
                              ),
                              DataColumn(
                                label: Text(
                                    AppLocalizations.of(context)!.createdTitle),
                                tooltip:
                                    AppLocalizations.of(context)!.createdTitle,
                                onSort: _setSortColumn,
                              ),
                            ],
                            rows: _filterDepartments
                                .map((ele) => DataRow(cells: [
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: widget.userController
                                                      .userData?.id ==
                                                  ele.id
                                              ? []
                                              : [
                                                  IconButtonComponent(
                                                    icon:
                                                        FontAwesomeIcons.pencil,
                                                    color: Colors.orange,
                                                    width: 32,
                                                    onPressed: () {
                                                      _showEditDepartmentDialog(
                                                          ele);
                                                    },
                                                  ),
                                                  const SizedBox(width: 7),
                                                  IconButtonComponent(
                                                    icon:
                                                        FontAwesomeIcons.trash,
                                                    width: 32,
                                                    onPressed: () {
                                                      _showDeleteDepartmentWarning(
                                                          ele);
                                                    },
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
                        totalElements: _departments.length,
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

  List<VserveDepartmentData> get _filterDepartments {
    if (_departments.isEmpty) {
      return [];
    }

    int startIndex = _pageSize * (_pageIndex - 1);
    if (_departments.length < startIndex) {
      return [];
    }

    int endIndex = math.min(_pageSize * _pageIndex, _departments.length);
    return _departments.sublist(startIndex, endIndex);
  }

  void _setSortColumn(int columnIndex, bool assending) {
    if (_sortColumnIndex != columnIndex) {
      _sortColumnIndex = columnIndex;
      _sortAscending = assending;
    } else if (_sortAscending == true) {
      _sortAscending = false;
    } else {
      _sortColumnIndex = null;
      _sortAscending = true;
    }

    _sortDepartments();
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

  void _sortDepartments() {
    final column = _sortIndexToField(_sortColumnIndex);
    developer.log("$_sortColumnIndex => $column ($_sortAscending)",
        name: "Sort");

    switch (column) {
      case "id":
        _departments.sort((a, b) =>
            _sortAscending ? a.id.compareTo(b.id) : b.id.compareTo(a.id));
        break;
      case "active":
        _departments.sort((a, b) {
          if (a.active & !b.active) {
            return _sortAscending ? -1 : 1;
          } else if (!a.active & b.active) {
            return _sortAscending ? 1 : -1;
          }
          return 0;
        });
        break;
      case "name":
        _departments.sort((a, b) => _sortAscending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case "createdAt":
        _departments.sort((a, b) => _sortAscending
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

  Future<void> _showAddDepartmentDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _DepartmentFormDialog(
          onEditDepartment: _addDepartment,
        );
      },
    );
  }

  Future<void> _showEditDepartmentDialog(
      VserveDepartmentData departmentData) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _DepartmentFormDialog(
          originalData: departmentData,
          onEditDepartment: _editDepartment,
        );
      },
    );
  }

  Future<void> _showDeleteDepartmentWarning(
      VserveDepartmentData departmentData) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!
              .departmentEditDeleteDepartmentWarningTitle(departmentData.name)),
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
                _deleteDepartment(departmentData);
              },
            ),
          ],
        );
      },
    );
  }

  void _addDepartment(VserveEditDepartmentData editedDepartmentData) async {
    if (_siteId == null) {
      return;
    }

    _showLoadingDialog();

    final uploadLogoProgressText =
        AppLocalizations.of(context)!.departmentEditProgressUpdateLogo;
    final addSiteProgressText =
        AppLocalizations.of(context)!.departmentEditProgressAddDepartment;
    final successText = AppLocalizations.of(context)!
        .departmentEditAddDepartmentSuccessfulTitle;
    final failedText =
        AppLocalizations.of(context)!.departmentEditAddDepartmentFailedTitle;

    try {
      _progressText = addSiteProgressText;
      setState(() {});

      final result = await ApiService.dio.post(
        "${ApiService.baseUrlPath}/department/add",
        data: editedDepartmentData.toApiData(_siteId!),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (editedDepartmentData.newLogoImage != null) {
        _progressText = uploadLogoProgressText;
        setState(() {});
        final imagePath = await _uploadImage(
          result.data["siteData"]["_id"],
          editedDepartmentData.newLogoImage!,
          true,
        );
        editedDepartmentData.editedData.logoUrl = imagePath;
      }

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log("Added", name: "Add Department");
      setState(() {});

      await _showSuccessDialog(successText);
    } catch (err) {
      developer.log(err.toString(), name: "Add Department");

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await _showFailedDialog(failedText, err);
    }
  }

  void _editDepartment(VserveEditDepartmentData editedDepartmentData) async {
    if (_siteId == null) {
      return;
    }

    _showLoadingDialog();

    final uploadLogoProgressText =
        AppLocalizations.of(context)!.departmentEditProgressUpdateLogo;
    final editSiteProgressText =
        AppLocalizations.of(context)!.departmentEditProgressEditDepartment;
    final successText = AppLocalizations.of(context)!
        .departmentEditEditDepartmentSuccessfulTitle;
    final failedText =
        AppLocalizations.of(context)!.departmentEditEditDepartmentFailedTitle;

    try {
      if (editedDepartmentData.newLogoImage != null) {
        _progressText = uploadLogoProgressText;
        setState(() {});
        final imagePath = await _uploadImage(
          editedDepartmentData.editedData.id,
          editedDepartmentData.newLogoImage!,
        );
        editedDepartmentData.editedData.logoUrl = imagePath;
      }

      _progressText = editSiteProgressText;
      setState(() {});

      await ApiService.dio.post(
        "${ApiService.baseUrlPath}/department/edit",
        data: editedDepartmentData.toApiData(_siteId!, withId: true),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log("Edited", name: "Edit Department");
      setState(() {});

      await _showSuccessDialog(successText);
    } catch (err) {
      developer.log(err.toString(), name: "Edit Department");

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await _showFailedDialog(failedText, err);
    }
  }

  void _deleteDepartment(VserveDepartmentData departmentData) async {
    _showLoadingDialog();

    final successText =
        AppLocalizations.of(context)!.siteEditDeleteSiteSuccessfulTitle;
    final failedText =
        AppLocalizations.of(context)!.siteEditDeleteSiteFailedTitle;

    try {
      await ApiService.dio.post(
        "${ApiService.baseUrlPath}/department/delete",
        data: {
          "id": departmentData.id,
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log("Deleted", name: "Delete Department");
      setState(() {});

      await _showSuccessDialog(successText);
    } catch (err) {
      developer.log(err.toString(), name: "Delete Department");

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await _showFailedDialog(failedText, err);
    }
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
      "${ApiService.baseUrlPath}/department-logo/update",
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
                Navigator.of(context).pop();
                _loadDepartmentsData();
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
    super.dispose();
    _timer.cancel();
  }
}

class _DepartmentFormDialog extends StatefulWidget {
  const _DepartmentFormDialog({
    this.originalData,
    this.onEditDepartment,
  });

  final VserveDepartmentData? originalData;
  final Function(VserveEditDepartmentData)? onEditDepartment;

  @override
  State<_DepartmentFormDialog> createState() => _DepartmentFormDialogState();
}

class _DepartmentFormDialogState extends State<_DepartmentFormDialog> {
  final ImagePicker _imagePicker = ImagePicker();

  final VserveEditDepartmentData _editedDepartmentData =
      VserveEditDepartmentData(VserveDepartmentData());
  final TextEditingController _nameTextFieldCtrl = TextEditingController();
  final TextEditingController _contractEmailTextFieldCtrl =
      TextEditingController();
  final TextEditingController _phoneTextFieldCtrl = TextEditingController();
  final TextEditingController _locationTextFieldCtrl = TextEditingController();
  final TextEditingController _noteTextFieldCtrl = TextEditingController();

  bool _fullScreen = false;

  @override
  void initState() {
    super.initState();

    if (widget.originalData != null) {
      _editedDepartmentData.editedData = widget.originalData!.clone();
    }

    _nameTextFieldCtrl.text = _editedDepartmentData.editedData.name;
    _contractEmailTextFieldCtrl.text =
        _editedDepartmentData.editedData.contractEmail;
    _phoneTextFieldCtrl.text = _editedDepartmentData.editedData.phoneNumber;
    _noteTextFieldCtrl.text = _editedDepartmentData.editedData.note;
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
                      ? AppLocalizations.of(context)!
                          .departmentsEditDepartmentTitle
                      : AppLocalizations.of(context)!
                          .departmentsNewDepartmentTitle,
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
                        .departmentsFormActiveSwitch),
                    const SizedBox(width: 14),
                    Switch(
                      value: _editedDepartmentData.editedData.active,
                      onChanged: (state) {
                        _editedDepartmentData.editedData.active = state;
                        setState(() {});
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                ScrollableContainerComponent(
                  child: Table(
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
                            child: Text(AppLocalizations.of(context)!
                                .departmentEditLogoTitle),
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
                                  child:
                                      _editedDepartmentData.newLogoImage != null
                                          ? CircleAvatar(
                                              backgroundImage: XFileImage(
                                                  _editedDepartmentData
                                                      .newLogoImage!),
                                            )
                                          : CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  _editedDepartmentData
                                                      .editedData
                                                      .serverLogoUrl),
                                            ),
                                ),
                                OutlinedButton(
                                  onPressed: _pickImage,
                                  child: Text(AppLocalizations.of(context)!
                                      .departmentEditChangeLogoButton),
                                ),
                                if (_editedDepartmentData.newLogoImage != null)
                                  OutlinedButton(
                                    onPressed: _revertPickImage,
                                    child: Text(AppLocalizations.of(context)!
                                        .departmentEditRevertLogoButton),
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
                            child: Text(AppLocalizations.of(context)!
                                .departmentEditNameTitle),
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
                                _editedDepartmentData.editedData.name = value;
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
                                .departmentEditContractEmailTitle),
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
                                _editedDepartmentData.editedData.contractEmail =
                                    value;
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
                                .departmentEditPhoneTitle),
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
                                _editedDepartmentData.editedData.phoneNumber =
                                    value;
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
                                .departmentEditLocationsTitle),
                          ),
                          Padding(
                            padding: tablePadding,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _locationTextFieldCtrl,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          prefixIcon: const Icon(
                                              FontAwesomeIcons.mapLocation),
                                          border: const OutlineInputBorder(),
                                          errorText: _locationTextFieldCtrl
                                                  .text.isNotEmpty
                                              ? null
                                              : AppLocalizations.of(context)!
                                                  .departmentEditLocationInvalidTitle,
                                        ),
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        textInputAction: TextInputAction.next,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size.zero,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 12),
                                      ),
                                      onPressed: _locationTextFieldCtrl
                                              .text.isNotEmpty
                                          ? () {
                                              _editedDepartmentData
                                                  .editedData.locations
                                                  .add(_locationTextFieldCtrl
                                                      .text);
                                              _locationTextFieldCtrl.text = "";
                                              setState(() {});
                                            }
                                          : null,
                                      child: const Icon(Icons.add),
                                    )
                                  ],
                                ),
                                ReorderableListView(
                                  shrinkWrap: true,
                                  onReorder: ((oldIndex, newIndex) {
                                    final oldValue = _editedDepartmentData
                                        .editedData.locations[oldIndex];
                                    _editedDepartmentData
                                            .editedData.locations[oldIndex] =
                                        _editedDepartmentData
                                            .editedData.locations[newIndex];
                                    _editedDepartmentData.editedData
                                        .locations[newIndex] = oldValue;
                                    setState(() {});
                                  }),
                                  children: _editedDepartmentData
                                      .editedData.locations
                                      .mapIndexed(
                                        (index, location) => ListTile(
                                          key: Key("order-$index"),
                                          title: Text(location),
                                          leading: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () {
                                                _editedDepartmentData
                                                    .editedData.locations
                                                    .remove(location);
                                                setState(() {});
                                              },
                                              child: const Icon(
                                                  FontAwesomeIcons.minus),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
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
                            child: Text(AppLocalizations.of(context)!
                                .departmentEditNotesTitle),
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
                                _editedDepartmentData.editedData.note = value;
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _editedDepartmentData.isFormValid
                        ? () {
                            widget.onEditDepartment
                                ?.call(_editedDepartmentData);
                          }
                        : null,
                    child: Text(
                        AppLocalizations.of(context)!.departmentEditSaveButton),
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
    _editedDepartmentData.newLogoImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    setState(() => {});
  }

  void _revertPickImage() {
    _editedDepartmentData.newLogoImage = null;
    setState(() => {});
  }
}
