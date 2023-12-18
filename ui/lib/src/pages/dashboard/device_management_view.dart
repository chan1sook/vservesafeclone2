import 'dart:async';
import 'dart:math' as math;
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vservesafe/src/components/icon_button_component.dart';
import 'package:vservesafe/src/components/pagination_component.dart';
import 'package:vservesafe/src/components/scrollable_container.dart';
import 'package:vservesafe/src/components/status_item_component.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/models/iot_device.dart';
import 'package:vservesafe/src/models/iot_device_edit.dart';
import 'package:vservesafe/src/services/api_service.dart';
import 'package:vservesafe/src/services/settings_service.dart';
import 'package:vservesafe/src/utils/alert_dialog.dart';

class DeviceManagementDashboardView extends StatefulWidget {
  const DeviceManagementDashboardView({
    super.key,
    required this.settingsController,
    required this.userController,
  });

  final SettingsController settingsController;
  final UserController userController;
  static const routeName = '/device-management';

  @override
  State<DeviceManagementDashboardView> createState() =>
      _DeviceManagementDashboardViewState();
}

class _DeviceManagementDashboardViewState
    extends State<DeviceManagementDashboardView> {
  late Timer _timer;
  bool _isLoadingOpened = false;
  String? _progressText;
  int _pageIndex = 1;
  int _pageSize = 10;

  int? _sortColumnIndex;
  bool _sortAscending = true;

  final List<VserveIoTDeviceData> _devices = [];
  String? _siteId;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final site = widget.userController.selectedSiteId;

      if (_siteId != site) {
        _siteId = site;
        _loadDevicesData();
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();

    _loadDevicesData();
  }

  void _loadDevicesData() async {
    try {
      final response = await ApiService.dio
          .get("${ApiService.baseUrlPath}/devices/all", queryParameters: {
        "site_id": _siteId,
      });

      List<VserveIoTDeviceData> newDevices = [];
      final devicesData = response.data["devices"] as List<dynamic>;
      for (final ele in devicesData) {
        if (ele is Map<String, dynamic>) {
          newDevices.add(VserveIoTDeviceData.parseFromRawData(ele));
        }
      }

      if (mounted) {
        _devices.clear();
        _devices.addAll(newDevices);
        _sortDevices();

        setState(() {});
      }
    } catch (err) {
      developer.log(err.toString(), name: "Device Lists");
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
                    onPressed: _showNewDeviceDialog,
                    child: Text(
                      AppLocalizations.of(context)!.iotDeviceNewDeviceButton,
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
                                    .iotDeviceMacAddressTitle),
                                tooltip: AppLocalizations.of(context)!
                                    .iotDeviceMacAddressTitle,
                                onSort: _setSortColumn,
                              ),
                              DataColumn(
                                label: Text(AppLocalizations.of(context)!
                                    .iotDeviceNameTitle),
                                tooltip: AppLocalizations.of(context)!
                                    .iotDeviceNameTitle,
                                onSort: _setSortColumn,
                              ),
                              DataColumn(
                                label: Text(AppLocalizations.of(context)!
                                    .iotDeviceNoteTitle),
                                tooltip: AppLocalizations.of(context)!
                                    .iotDeviceNoteTitle,
                              ),
                              DataColumn(
                                label: Text(
                                    AppLocalizations.of(context)!.createdTitle),
                                tooltip:
                                    AppLocalizations.of(context)!.createdTitle,
                                onSort: _setSortColumn,
                              ),
                            ],
                            rows: _filterSites
                                .map((ele) => DataRow(cells: [
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButtonComponent(
                                              icon: FontAwesomeIcons.pencil,
                                              color: Colors.orange,
                                              width: 32,
                                              onPressed: () {
                                                _showDeviceSiteDialog(ele);
                                              },
                                            ),
                                            const SizedBox(width: 7),
                                            IconButtonComponent(
                                              icon: FontAwesomeIcons.trash,
                                              width: 32,
                                              onPressed: () {
                                                _showDeleteDeviceWarning(ele);
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
                                      DataCell(Text(ele.macAddress)),
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
                        totalElements: _devices.length,
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

  List<VserveIoTDeviceData> get _filterSites {
    if (_devices.isEmpty) {
      return [];
    }

    int startIndex = _pageSize * (_pageIndex - 1);
    if (_devices.length < startIndex) {
      return [];
    }

    int endIndex = math.min(_pageSize * _pageIndex, _devices.length);
    return _devices.sublist(startIndex, endIndex);
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

    _sortDevices();
    setState(() {});
  }

  String _sortIndexToField(int? index) {
    List<String> fieldHeaders = [
      "",
      if (SettingsService.showItemId) "id",
      "active",
      "macaddress",
      "name",
      "note",
      "createdAt"
    ];
    if (index != null && index >= 0 && index < fieldHeaders.length) {
      return fieldHeaders[index];
    }

    return "";
  }

  void _sortDevices() {
    final column = _sortIndexToField(_sortColumnIndex);
    developer.log("$_sortColumnIndex => $column ($_sortAscending)",
        name: "Sort");

    switch (column) {
      case "id":
        _devices.sort((a, b) =>
            _sortAscending ? a.id.compareTo(b.id) : b.id.compareTo(a.id));
        break;
      case "active":
        _devices.sort((a, b) {
          if (a.active & !b.active) {
            return _sortAscending ? -1 : 1;
          } else if (!a.active & b.active) {
            return _sortAscending ? 1 : -1;
          }
          return 0;
        });
        break;
      case "macaddress":
        _devices.sort((a, b) => _sortAscending
            ? a.macAddress.compareTo(b.macAddress)
            : b.macAddress.compareTo(a.macAddress));
        break;
      case "name":
        _devices.sort((a, b) => _sortAscending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case "note":
        _devices.sort((a, b) => _sortAscending
            ? a.note.compareTo(b.note)
            : b.note.compareTo(a.note));
        break;
      case "createdAt":
        _devices.sort((a, b) => _sortAscending
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

  Future<void> _showNewDeviceDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _DeviceFormDialog(
          onEditDevice: _addDevice,
        );
      },
    );
  }

  Future<void> _showDeviceSiteDialog(VserveIoTDeviceData deviceData) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _DeviceFormDialog(
          originalData: deviceData,
          onEditDevice: _editDevice,
        );
      },
    );
  }

  Future<void> _showDeleteDeviceWarning(VserveIoTDeviceData deviceData) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!
              .iotDeviceEditDeleteDeviceWarningTitle(deviceData.name)),
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
                _deleteDevice(deviceData);
              },
            ),
          ],
        );
      },
    );
  }

  void _addDevice(VserveEditIoTDeviceData editedDeviceData) async {
    if (_siteId == null) {
      return;
    }

    _showLoadingDialog();

    final successText =
        AppLocalizations.of(context)!.iotDeviceEditAddDeviceSuccessfulTitle;
    final failedText =
        AppLocalizations.of(context)!.iotDeviceEditAddDeviceFailedTitle;

    try {
      await ApiService.dio.post(
        "${ApiService.baseUrlPath}/device/add",
        data: editedDeviceData.toApiData(_siteId!),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log("Added", name: "Add Device");
      setState(() {});

      await _showSuccessDialog(successText);
    } catch (err) {
      developer.log(err.toString(), name: "Add Device");

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await _showFailedDialog(failedText, err);
    }
  }

  void _editDevice(VserveEditIoTDeviceData editedDeviceData) async {
    if (_siteId == null) {
      return;
    }

    _showLoadingDialog();

    final successText =
        AppLocalizations.of(context)!.iotDeviceEditEditDeviceSuccessfulTitle;
    final failedText =
        AppLocalizations.of(context)!.iotDeviceEditEditDeviceFailedTitle;

    try {
      await ApiService.dio.post(
        "${ApiService.baseUrlPath}/device/edit",
        data: editedDeviceData.toApiData(_siteId!, withId: true),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log("Edited", name: "Edit Device");
      setState(() {});

      await _showSuccessDialog(successText);
    } catch (err) {
      developer.log(err.toString(), name: "Edit Device");

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await _showFailedDialog(failedText, err);
    }
  }

  void _deleteDevice(VserveIoTDeviceData deviceData) async {
    _progressText = null;
    _showLoadingDialog();

    final successText =
        AppLocalizations.of(context)!.iotDeviceEditDeleteDeviceSuccessfulTitle;
    final failedText =
        AppLocalizations.of(context)!.iotDeviceEditDeleteDeviceFailedTitle;

    try {
      await ApiService.dio.post(
        "${ApiService.baseUrlPath}/device/delete",
        data: {
          "id": deviceData.id,
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log("Deleted", name: "Delete Device");
      setState(() {});

      await _showSuccessDialog(successText);
    } catch (err) {
      developer.log(err.toString(), name: "Delete Device");

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
                _loadDevicesData();
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

class _DeviceFormDialog extends StatefulWidget {
  const _DeviceFormDialog({this.originalData, this.onEditDevice});

  final VserveIoTDeviceData? originalData;
  final Function(VserveEditIoTDeviceData)? onEditDevice;

  @override
  State<_DeviceFormDialog> createState() => _DeviceFormDialogState();
}

class _DeviceFormDialogState extends State<_DeviceFormDialog> {
  final bool _isCustom = false;

  final VserveEditIoTDeviceData _editedDeviceData =
      VserveEditIoTDeviceData(VserveIoTDeviceData());

  final TextEditingController _nameTextFieldCtrl = TextEditingController();
  final TextEditingController _macAddressTextFieldCtrl =
      TextEditingController();
  final TextEditingController _typeTextFieldCtrl = TextEditingController();
  final TextEditingController _noteTextFieldCtrl = TextEditingController();

  bool _fullScreen = false;

  @override
  void initState() {
    super.initState();

    if (widget.originalData != null) {
      _editedDeviceData.editedData = widget.originalData!.clone();
    }
    if (_editedDeviceData.editedData.type.isEmpty) {
      _editedDeviceData.editedData.type = VserveIoTDeviceData.defaultTypes[0];
    }

    _nameTextFieldCtrl.text = _editedDeviceData.editedData.name;
    _macAddressTextFieldCtrl.text = _editedDeviceData.editedData.macAddress;
    _typeTextFieldCtrl.text = _editedDeviceData.editedData.type;
    _noteTextFieldCtrl.text = _editedDeviceData.editedData.note;
  }

  @override
  Widget build(BuildContext context) {
    const tablePadding = EdgeInsets.symmetric(horizontal: 14, vertical: 7);
    var actualList = List.from(VserveIoTDeviceData.defaultTypes);
    if (!actualList.contains(_editedDeviceData.editedData.type)) {
      actualList.add(_editedDeviceData.editedData.type);
    }

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
                      ? AppLocalizations.of(context)!.iotDeviceEditDeviceTitle
                      : AppLocalizations.of(context)!.iotDeviceNewDeviceTitle,
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
                      value: _editedDeviceData.editedData.active,
                      onChanged: (state) {
                        _editedDeviceData.editedData.active = state;
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
                                .iotDeviceEditMacAddressTitle),
                          ),
                          Padding(
                            padding: tablePadding,
                            child: TextField(
                              controller: _macAddressTextFieldCtrl,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                isDense: true,
                                prefixIcon: Icon(FontAwesomeIcons.globe),
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                _editedDeviceData.editedData.macAddress = value;
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
                                .iotDeviceEditNameTitle),
                          ),
                          Padding(
                            padding: tablePadding,
                            child: TextField(
                              controller: _nameTextFieldCtrl,
                              decoration: const InputDecoration(
                                isDense: true,
                                prefixIcon: Icon(FontAwesomeIcons.microchip),
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                _editedDeviceData.editedData.name = value;
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
                                .iotDeviceEditTypeTitle),
                          ),
                          Padding(
                            padding: tablePadding,
                            child: _isCustom
                                ? Padding(
                                    padding: tablePadding,
                                    child: TextField(
                                      controller: _typeTextFieldCtrl,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        prefixIcon:
                                            Icon(FontAwesomeIcons.microchip),
                                        border: OutlineInputBorder(),
                                      ),
                                      textInputAction: TextInputAction.next,
                                      onChanged: (value) {
                                        _editedDeviceData.editedData.type =
                                            value;
                                        setState(() {});
                                      },
                                    ),
                                  )
                                : DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                    value: _editedDeviceData.editedData.type,
                                    onChanged: (value) {
                                      if (value != null) {
                                        _editedDeviceData.editedData.type =
                                            value;
                                        _typeTextFieldCtrl.text = value;
                                        setState(() {});
                                      }
                                    },
                                    items: actualList.map((type) {
                                      return DropdownMenuItem<String>(
                                        value: type,
                                        child: Text(
                                          type,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: tablePadding,
                            child: Text(AppLocalizations.of(context)!
                                .iotDeviceEditNoteTitle),
                          ),
                          Padding(
                            padding: tablePadding,
                            child: TextField(
                              controller: _noteTextFieldCtrl,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                isDense: true,
                                prefixIcon: Icon(FontAwesomeIcons.noteSticky),
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                _editedDeviceData.editedData.macAddress = value;
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
                    onPressed: _editedDeviceData.isFormValid
                        ? () {
                            widget.onEditDevice?.call(_editedDeviceData);
                          }
                        : null,
                    child: Text(
                        AppLocalizations.of(context)!.iotDeviceEditSaveButton),
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
}
