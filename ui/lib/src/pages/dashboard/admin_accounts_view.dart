import 'dart:math' as math;
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:password_generator/src/password_generator.dart';
import 'package:vservesafe/src/components/alert_component.dart';
import 'package:vservesafe/src/components/pagination_component.dart';
import 'package:vservesafe/src/components/status_item_component.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/models/admin_user_edit_data.dart';
import 'package:vservesafe/src/models/user_data.dart';
import 'package:vservesafe/src/services/api_service.dart';
import 'package:vservesafe/src/services/settings_service.dart';

class AdminAccountsDashboardView extends StatefulWidget {
  const AdminAccountsDashboardView({
    super.key,
    required this.settingsController,
    required this.userController,
  });

  final SettingsController settingsController;
  final UserController userController;
  static const routeName = '/admin-accounts';

  @override
  State<AdminAccountsDashboardView> createState() =>
      _AdminAccountsDashboardViewState();
}

class _AdminAccountsDashboardViewState
    extends State<AdminAccountsDashboardView> {
  bool _isLoadingOpened = false;
  String? _progressText;
  int _pageIndex = 1;
  int _pageSize = 10;

  int? _sortColumnIndex;
  bool _sortAssending = true;

  final List<VserveUserData> _users = [];

  @override
  void initState() {
    super.initState();

    _loadAdminsData();
  }

  @override
  void reassemble() {
    super.reassemble();

    _loadAdminsData();
  }

  void _loadAdminsData() async {
    try {
      final response = await ApiService.dio.get(
        "${ApiService.baseUrlPath}/adminusers",
        queryParameters: {
          "with_inactive": true,
          "with_devs": widget.userController.userData?.role == "developer",
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
        _users.clear();
        _users.addAll(newUsers);
        _sortUsers();
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
                    onPressed: () {
                      _showAddAdminUserDialog();
                    },
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
                                    .adminAccountsNameTitle),
                                onSort: _setSortColumn,
                              ),
                              DataColumn(
                                label: Text(AppLocalizations.of(context)!
                                    .adminAccountsRoleTitle),
                                onSort: _setSortColumn,
                              ),
                              DataColumn(
                                label: Text(AppLocalizations.of(context)!
                                    .adminAccountsEmailTitle),
                                onSort: _setSortColumn,
                              ),
                              DataColumn(
                                label: Text(
                                    AppLocalizations.of(context)!.createdTitle),
                                onSort: _setSortColumn,
                              ),
                            ],
                            rows: _filterUsers
                                .map((ele) => DataRow(cells: [
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: widget.userController
                                                      .userData?.id ==
                                                  ele.id
                                              ? []
                                              : [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      _showEditAdminUserDialog(
                                                          ele);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          const CircleBorder(),
                                                      minimumSize: Size.zero,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              18),
                                                      backgroundColor:
                                                          Colors.grey,
                                                    ),
                                                    child: const Icon(
                                                      FontAwesomeIcons.pencil,
                                                      color: Colors.white,
                                                      size: 14,
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      _showDeleteAdminUserWarning(
                                                          ele);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          const CircleBorder(),
                                                      minimumSize: Size.zero,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              18),
                                                      backgroundColor:
                                                          Colors.orange,
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
                                      DataCell(Text(ele.actualName)),
                                      DataCell(Text(
                                          _translatedRole(context, ele.role))),
                                      DataCell(Text(ele.username)),
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
                        totalElements: _users.length,
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

  List<VserveUserData> get _filterUsers {
    if (_users.isEmpty) {
      return [];
    }

    int startIndex = _pageSize * (_pageIndex - 1);
    if (_users.length < startIndex) {
      return [];
    }

    int endIndex = math.min(_pageSize * _pageIndex, _users.length);
    return _users.sublist(startIndex, endIndex);
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

    _sortUsers();
    setState(() {});
  }

  String _sortIndexToField(int? index) {
    List<String> fieldHeaders = [
      "",
      if (SettingsService.showItemId) "id",
      "active",
      "actualName",
      "role",
      "username",
      "createdAt"
    ];
    if (index != null && index >= 0 && index < fieldHeaders.length) {
      return fieldHeaders[index];
    }

    return "";
  }

  String _translatedRole(BuildContext context, String actualRole) {
    switch (actualRole) {
      case "user":
        return AppLocalizations.of(context)!.roleUser;
      case "manager":
        return AppLocalizations.of(context)!.roleManager;
      case "admin":
        return AppLocalizations.of(context)!.roleAdmin;
      case "superadmin":
        return AppLocalizations.of(context)!.roleSuperadmin;
      case "developer":
        return AppLocalizations.of(context)!.roleDeveloper;
      default:
        return actualRole;
    }
  }

  void _sortUsers() {
    final column = _sortIndexToField(_sortColumnIndex);
    developer.log("$_sortColumnIndex => $column ($_sortAssending}",
        name: "Sort");

    switch (column) {
      case "id":
        _users.sort((a, b) =>
            _sortAssending ? a.id.compareTo(b.id) : b.id.compareTo(a.id));
        break;
      case "active":
        _users.sort((a, b) {
          if (a.active & !b.active) {
            return _sortAssending ? -1 : 1;
          } else if (!a.active & b.active) {
            return _sortAssending ? 1 : -1;
          }
          return 0;
        });
        break;
      case "actualName":
        _users.sort((a, b) => _sortAssending
            ? a.actualName.compareTo(b.actualName)
            : b.actualName.compareTo(a.actualName));
        break;
      case "role":
        final roles = ["developer", "superadmin", "admin"];
        _users.sort((a, b) => _sortAssending
            ? roles.indexOf(a.role) - roles.indexOf(b.role)
            : roles.indexOf(b.role) - roles.indexOf(a.role));
        break;
      case "username":
        _users.sort((a, b) => _sortAssending
            ? a.username.compareTo(b.username)
            : b.username.compareTo(a.username));
        break;
      case "createdAt":
        _users.sort((a, b) => _sortAssending
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

  Future<void> _showAddAdminUserDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _AdminUserFormDialog(
          onEditAdminUser: _addAdminUser,
        );
      },
    );
  }

  Future<void> _showEditAdminUserDialog(VserveUserData userData) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _AdminUserFormDialog(
          originalData: userData,
          onEditAdminUser: _editAdminUser,
        );
      },
    );
  }

  Future<void> _showDeleteAdminUserWarning(VserveUserData userData) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!
              .adminAccountsDeleteUserWarningTitle(userData.username)),
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
                _deleteAdminUser(userData);
              },
            ),
          ],
        );
      },
    );
  }

  void _addAdminUser(VserveEditAdminUserData editedUserData) async {
    _showLoadingDialog();

    final successText =
        AppLocalizations.of(context)!.adminAccountsAddUserSuccessfulTitle;
    final failedText =
        AppLocalizations.of(context)!.adminAccountsAddUserFailedTitle;

    try {
      await ApiService.dio.post(
        "${ApiService.baseUrlPath}/adminuser/add",
        data: editedUserData.toApiData(),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log("Added", name: "Add Admin User");
      setState(() {});

      await _showSuccessDialog(successText);
    } catch (err) {
      developer.log(err.toString(), name: "Add Admin User");

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await _showFailedDialog(failedText, err);
    }
  }

  void _editAdminUser(VserveEditAdminUserData editedUserData) async {
    _showLoadingDialog();

    final successText =
        AppLocalizations.of(context)!.adminAccountsEditUserSuccessfulTitle;
    final failedText =
        AppLocalizations.of(context)!.adminAccountsEditUserFailedTitle;

    try {
      await ApiService.dio.post(
        "${ApiService.baseUrlPath}/adminuser/edit",
        data: editedUserData.toApiData(withId: true),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log("Edited", name: "Edit Admin User");
      setState(() {});

      await _showSuccessDialog(successText);
    } catch (err) {
      developer.log(err.toString(), name: "Edit Admin User");

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await _showFailedDialog(failedText, err);
    }
  }

  void _deleteAdminUser(VserveUserData userData) async {
    _showLoadingDialog();

    final successText =
        AppLocalizations.of(context)!.siteEditDeleteSiteSuccessfulTitle;
    final failedText =
        AppLocalizations.of(context)!.siteEditDeleteSiteFailedTitle;

    try {
      await ApiService.dio.post(
        "${ApiService.baseUrlPath}/adminuser/delete",
        data: {
          "id": userData.id,
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log("Deleted", name: "Delete Admin User");
      setState(() {});

      await _showSuccessDialog(successText);
    } catch (err) {
      developer.log(err.toString(), name: "Delete Admin User");

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
                _loadAdminsData();
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

class _AdminUserFormDialog extends StatefulWidget {
  const _AdminUserFormDialog({
    this.originalData,
    this.onEditAdminUser,
  });

  final VserveUserData? originalData;
  final Function(VserveEditAdminUserData)? onEditAdminUser;

  @override
  State<_AdminUserFormDialog> createState() => _AdminUserFormDialogState();
}

class _AdminUserFormDialogState extends State<_AdminUserFormDialog> {
  final VserveEditAdminUserData _editedAdminUserData =
      VserveEditAdminUserData(VserveUserData());
  final PasswordGenerator _passwordGenerator = PasswordGenerator(
    length: 12,
    hasCapitalLetters: true,
    hasNumbers: true,
    hasSmallLetters: true,
    hasSymbols: true,
  );

  final TextEditingController _acutalNameTextFieldCtrl =
      TextEditingController();
  final TextEditingController _usernameTextFieldCtrl = TextEditingController();
  final TextEditingController _passwordTextFieldCtrl = TextEditingController();
  final TextEditingController _confirmPasswordTextFieldCtrl =
      TextEditingController();
  final TextEditingController _noteTextFieldCtrl = TextEditingController();

  bool _hidePassword = true;
  bool _fullScreen = false;

  @override
  void initState() {
    super.initState();

    if (widget.originalData != null) {
      _editedAdminUserData.editedData = widget.originalData!.clone();
    } else {
      _editedAdminUserData.editedData.role = "admin";
      _editedAdminUserData.needEditPassword = true;
    }

    _acutalNameTextFieldCtrl.text = _editedAdminUserData.editedData.actualName;
    _usernameTextFieldCtrl.text = _editedAdminUserData.editedData.username;
    _passwordTextFieldCtrl.text = _editedAdminUserData.newPassword;
    _confirmPasswordTextFieldCtrl.text =
        _editedAdminUserData.newPasswordConfirm;
    _noteTextFieldCtrl.text = _editedAdminUserData.editedData.note;
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
                      ? AppLocalizations.of(context)!.adminAccountsEditUserTitle
                      : AppLocalizations.of(context)!.adminAccountsNewUserTitle,
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
                      value: _editedAdminUserData.editedData.active,
                      onChanged: (state) {
                        _editedAdminUserData.editedData.active = state;
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
                          child: Text(AppLocalizations.of(context)!
                              .adminAccountEditRoleTitle),
                        ),
                        Padding(
                          padding: tablePadding,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            value: _editedAdminUserData.editedData.role,
                            onChanged: (value) {
                              if (value != null) {
                                _editedAdminUserData.editedData.role = value;
                                setState(() => {});
                              }
                            },
                            items: [
                              "admin",
                              "superadmin",
                              if (_editedAdminUserData.editedData.role ==
                                  "developer")
                                "developer"
                            ].map((v) {
                              return DropdownMenuItem<String>(
                                value: v,
                                child: Text(
                                  _translatedRole(context, v),
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                              .adminAccountEditActualNameTitle),
                        ),
                        Padding(
                          padding: tablePadding,
                          child: TextField(
                            controller: _acutalNameTextFieldCtrl,
                            decoration: const InputDecoration(
                              isDense: true,
                              prefixIcon: Icon(FontAwesomeIcons.suitcase),
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              _editedAdminUserData.editedData.actualName =
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
                              .adminAccountEditUsernameTitle),
                        ),
                        Padding(
                          padding: tablePadding,
                          child: TextField(
                            controller: _usernameTextFieldCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              isDense: true,
                              prefixIcon: const Icon(FontAwesomeIcons.user),
                              border: const OutlineInputBorder(),
                              errorText: _editedAdminUserData.isUsernameValid
                                  ? null
                                  : AppLocalizations.of(context)!
                                      .adminAccountEditUsernameInvalidText,
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: widget.originalData != null
                                ? null
                                : (value) {
                                    _editedAdminUserData.editedData.username =
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
                          child: Wrap(
                            spacing: 7,
                            runSpacing: 3.5,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(AppLocalizations.of(context)!
                                  .adminAccountEditPasswordTitle),
                              _PasswordEyeComponent(
                                hideState: _hidePassword,
                                onTap: () {
                                  _hidePassword = !_hidePassword;
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: tablePadding,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.originalData != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        _editedAdminUserData.needEditPassword =
                                            true;
                                        setState(() {});
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const FaIcon(FontAwesomeIcons.key,
                                              size: 14),
                                          const SizedBox(width: 7),
                                          Text(AppLocalizations.of(context)!
                                              .profileEditChangePasswordButton),
                                        ],
                                      ),
                                    ),
                                    if (_editedAdminUserData
                                        .needEditPassword) ...[
                                      const SizedBox(width: 14),
                                      OutlinedButton(
                                        onPressed: () {
                                          _editedAdminUserData
                                              .needEditPassword = false;
                                          setState(() {});
                                        },
                                        child: Text(AppLocalizations.of(
                                                context)!
                                            .profileEditChangePasswordRevertButton),
                                      ),
                                    ],
                                  ],
                                ),
                              if (_editedAdminUserData.needEditPassword) ...[
                                if (widget.originalData != null)
                                  const SizedBox(height: 7),
                                TextField(
                                  controller: _passwordTextFieldCtrl,
                                  obscureText: _hidePassword,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    prefixIcon:
                                        const Icon(FontAwesomeIcons.key),
                                    border: const OutlineInputBorder(),
                                    labelText: AppLocalizations.of(context)!
                                        .adminAccountEditPasswordHintText,
                                  ),
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) {
                                    _editedAdminUserData.newPassword = value;
                                    setState(() {});
                                  },
                                ),
                                const SizedBox(height: 7),
                                OutlinedButton(
                                    onPressed: () {
                                      final pw =
                                          _passwordGenerator.generatePassword();
                                      _editedAdminUserData.newPassword = pw;
                                      _editedAdminUserData.newPasswordConfirm =
                                          pw;
                                      _passwordTextFieldCtrl.text = pw;
                                      _confirmPasswordTextFieldCtrl.text = pw;
                                      _hidePassword = false;
                                      setState(() {});
                                    },
                                    child: Text(AppLocalizations.of(context)!
                                        .adminAccountEditGeneratePasswordText)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: tablePadding,
                          child: Wrap(
                            spacing: 7,
                            runSpacing: 3.5,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(AppLocalizations.of(context)!
                                  .adminAccountEditPasswordConfirmTitle),
                              if (_editedAdminUserData.needEditPassword)
                                _PasswordEyeComponent(
                                  hideState: _hidePassword,
                                  onTap: () {
                                    _hidePassword = !_hidePassword;
                                    setState(() {});
                                  },
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: tablePadding,
                          child: TextField(
                            controller: _confirmPasswordTextFieldCtrl,
                            obscureText: _hidePassword,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              isDense: true,
                              prefixIcon: const Icon(FontAwesomeIcons.key),
                              border: const OutlineInputBorder(),
                              labelText: AppLocalizations.of(context)!
                                  .adminAccountEditPasswordConfirmHintText,
                              errorText: _editedAdminUserData
                                      .isNewPasswordConfirmValid
                                  ? null
                                  : AppLocalizations.of(context)!
                                      .adminAccountEditPasswordConfirmInvalidText,
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              _editedAdminUserData.newPasswordConfirm = value;
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
                              .adminAccountEditNoteTitle),
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
                              _editedAdminUserData.editedData.note = value;
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
                    onPressed: _editedAdminUserData.isFormValid
                        ? () {
                            widget.onEditAdminUser?.call(_editedAdminUserData);
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

  String _translatedRole(BuildContext context, String actualRole) {
    switch (actualRole) {
      case "admin":
        return AppLocalizations.of(context)!.roleAdmin;
      case "superadmin":
        return AppLocalizations.of(context)!.roleSuperadmin;
      case "developer":
        return AppLocalizations.of(context)!.roleDeveloper;
      default:
        return actualRole;
    }
  }
}

class _PasswordEyeComponent extends StatelessWidget {
  const _PasswordEyeComponent({required this.hideState, this.onTap});

  final bool hideState;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onTap?.call();
        },
        child: Icon(
          hideState ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
          size: 14,
        ),
      ),
    );
  }
}