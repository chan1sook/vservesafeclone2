import 'dart:async';
import 'dart:math' as math;
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vservesafe/src/components/icon_button_component.dart';
import 'package:vservesafe/src/components/pagination_component.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/models/department_data.dart';
import 'package:vservesafe/src/models/shedein_form/shedein_form.dart';
import 'package:vservesafe/src/models/site_data.dart';
import 'package:vservesafe/src/services/api_service.dart';
import 'package:vservesafe/src/services/settings_service.dart';

class ShedeinFoodsafetyDashboardHistoryView extends StatefulWidget {
  const ShedeinFoodsafetyDashboardHistoryView({
    super.key,
    required this.settingsController,
    required this.userController,
    this.onBack,
    this.onSelectItem,
    this.formKey,
  });

  final SettingsController settingsController;
  final UserController userController;
  final Function()? onBack;
  final Function(String? id)? onSelectItem;
  final String? formKey;

  @override
  State<ShedeinFoodsafetyDashboardHistoryView> createState() =>
      _ShedeinFoodsafetyDashboardHistoryViewState();
}

class _ShedeinFoodsafetyDashboardHistoryViewState
    extends State<ShedeinFoodsafetyDashboardHistoryView> {
  late Timer _timer;
  bool _isLoadingSite = true;
  int _pageIndex = 1;
  int _pageSize = 10;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  VserveSiteData? _siteData;
  final List<VserveDepartmentData> _departments = [];
  final List<VserveShedeinResponseData> _formLists = [];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final site = widget.userController.selectedSite;

      if (_siteData?.id != site?.id) {
        _siteData = site;
        _isLoadingSite = true;
        _loadAllData();
        setState(() {});
      }
    });

    _siteData = widget.userController.selectedSite;
    _loadAllData();
  }

  @override
  void reassemble() {
    super.reassemble();

    _siteData = widget.userController.selectedSite;
    _isLoadingSite = true;
    _loadAllData();
    setState(() {});
  }

  void _loadAllData() async {
    await _loadDepartments();
    await _loadFormData();

    _isLoadingSite = false;
    setState(() {});
  }

  Future<void> _loadDepartments() async {
    if (_siteData == null) {
      return;
    }

    try {
      final response = await ApiService.dio.get(
        "${ApiService.baseUrlPath}/departments/site/${_siteData!.id}",
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
        setState(() {});
      }
    } catch (err) {
      developer.log(err.toString(), name: "Department Lists");
    }
  }

  Future<void> _loadFormData() async {
    try {
      final response = await ApiService.dio.get(
        "${ApiService.baseUrlPath}/shedein-res/history",
        queryParameters: {
          "form_id": widget.formKey,
          "site_id": _siteData?.id,
        },
      );

      List<VserveShedeinResponseData> newForm = [];
      final formData = response.data["shedeinResponses"] as List<dynamic>;
      for (final ele in formData) {
        if (ele is Map<String, dynamic>) {
          newForm.add(
              VserveShedeinResponseData.parseFromRawData(ele, _departments));
        }
      }

      if (mounted) {
        _formLists.clear();
        _formLists.addAll(newForm);
        _sortForms();
        setState(() {});
      }
    } catch (err) {
      developer.log(err.toString(), name: "User Lists");
    }
  }

  @override
  Widget build(BuildContext context) {
    double breakpoint = 1600;

    return _isLoadingSite
        ? Center(
            child: Text(
              AppLocalizations.of(context)!.loadingDialogText,
              style: const TextStyle(fontSize: 21),
            ),
          )
        : Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: ListView(
                primary: false,
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      IconButtonComponent(
                        icon: FontAwesomeIcons.arrowLeft,
                        onPressed: () {
                          widget.onBack?.call();
                        },
                        width: 40,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          translateFormKeyLong(context, widget.formKey ?? ""),
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      if (width < breakpoint) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: _shortListView,
                          ),
                        );
                      } else {
                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: breakpoint),
                            child: _wideTableView,
                          ),
                        );
                      }
                    },
                  ),
                  Center(
                    child: PaginationComponent(
                      currentPage: _pageIndex,
                      pageSize: _pageSize,
                      totalElements: _formLists.length,
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
          );
  }

  Widget get _shortListView {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
                AppLocalizations.of(context)!.shedeinFoodSafetyReportSortLabel),
            const SizedBox(width: 7),
            Expanded(child: _filterDropdown),
            if (_sortColumnIndex != null) ...[
              const SizedBox(width: 7),
              IconButtonComponent(
                width: 32,
                icon: _sortAscending
                    ? FontAwesomeIcons.arrowDown19
                    : FontAwesomeIcons.arrowUp91,
                onPressed: () {
                  _sortAscending = !_sortAscending;
                  _sortForms();
                  setState(() {});
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: 7),
        ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: _filterForms.length,
          itemBuilder: (context, index) {
            final item = _filterForms[index];
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade500, width: 0.5),
                ),
              ),
              child: ListTile(
                title: Text(item.answerBy),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      translateFormKeyShort(context, item.formKey),
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      "${AppLocalizations.of(context)!.shedeinFoodSafetyReportAnswerAtLabel}: ${_formatDate(item.answerDate)}",
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      "${AppLocalizations.of(context)!.createdTitle}: ${_formatDate(item.createdAt)}",
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                onTap: () {
                  widget.onSelectItem?.call(item.id);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget get _filterDropdown {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        fillColor: Colors.grey.shade300,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      ),
      value: _sortColumnIndex,
      onChanged: (value) {
        if (value != null) {
          _sortColumnIndex = value;
          _sortAscending = true;
          _sortForms();
          setState(() {});
        }
      },
      items: [
        if (SettingsService.showItemId)
          DropdownMenuItem<int>(
            value: _fieldHeaders.indexWhere((ele) => ele == "id"),
            child: Text(
              AppLocalizations.of(context)!.idTitle,
            ),
          ),
        DropdownMenuItem<int>(
          value: _fieldHeaders.indexWhere((ele) => ele == "answerBy"),
          child: Text(
            AppLocalizations.of(context)!.shedeinFoodSafetyReportAnswerByLabel,
          ),
        ),
        DropdownMenuItem<int>(
          value: _fieldHeaders.indexWhere((ele) => ele == "answerDate"),
          child: Text(
            AppLocalizations.of(context)!.shedeinFoodSafetyReportAnswerAtLabel,
          ),
        ),
        DropdownMenuItem<int>(
          value: _fieldHeaders.indexWhere((ele) => ele == "createdAt"),
          child: Text(
            AppLocalizations.of(context)!.createdTitle,
          ),
        ),
      ],
    );
  }

  Widget get _wideTableView {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.minWidth),
          child: DataTable(
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            columns: [
              DataColumn(
                label: Text(AppLocalizations.of(context)!.actionTitle),
                tooltip: AppLocalizations.of(context)!.actionTitle,
              ),
              if (SettingsService.showItemId)
                DataColumn(
                  label: Text(AppLocalizations.of(context)!.idTitle),
                  tooltip: AppLocalizations.of(context)!.idTitle,
                  onSort: _setSortColumn,
                ),
              DataColumn(
                label: Text(AppLocalizations.of(context)!
                    .shedeinFoodSafetyReportAnswerByLabel),
                tooltip: AppLocalizations.of(context)!
                    .shedeinFoodSafetyReportAnswerByLabel,
              ),
              DataColumn(
                label: Text(AppLocalizations.of(context)!
                    .shedeinFoodSafetyReportFormTypeLabel),
                tooltip: AppLocalizations.of(context)!
                    .shedeinFoodSafetyReportFormTypeLabel,
              ),
              DataColumn(
                label: Text(AppLocalizations.of(context)!
                    .shedeinFoodSafetyReportAnswerAtLabel),
                tooltip: AppLocalizations.of(context)!
                    .shedeinFoodSafetyReportAnswerAtLabel,
                onSort: _setSortColumn,
              ),
              DataColumn(
                label: Text(AppLocalizations.of(context)!.createdTitle),
                tooltip: AppLocalizations.of(context)!.createdTitle,
                onSort: _setSortColumn,
              ),
            ],
            rows: _filterForms
                .map((ele) => DataRow(cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButtonComponent(
                              icon: FontAwesomeIcons.magnifyingGlass,
                              color: Colors.blue,
                              onPressed: () {
                                widget.onSelectItem?.call(ele.id);
                              },
                              width: 32,
                            ),
                          ],
                        ),
                      ),
                      if (SettingsService.showItemId) DataCell(Text(ele.id)),
                      DataCell(Text(ele.answerBy)),
                      DataCell(
                          Text(translateFormKeyShort(context, ele.formKey))),
                      DataCell(
                        Text(
                          _formatDate(ele.answerDate),
                        ),
                      ),
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
    );
  }

  List<VserveShedeinResponseData> get _filterForms {
    if (_formLists.isEmpty) {
      return [];
    }

    int startIndex = _pageSize * (_pageIndex - 1);
    if (_formLists.length < startIndex) {
      return [];
    }

    int endIndex = math.min(_pageSize * _pageIndex, _formLists.length);
    return _formLists.sublist(startIndex, endIndex);
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

    _sortForms();
    setState(() {});
  }

  List<String> get _fieldHeaders => [
        "",
        if (SettingsService.showItemId) "id",
        "",
        "answerBy",
        "answerDate",
        "createdAt"
      ];

  String _sortIndexToField(int? index) {
    if (index != null && index >= 0 && index < _fieldHeaders.length) {
      return _fieldHeaders[index];
    }

    return "";
  }

  void _sortForms() {
    final column = _sortIndexToField(_sortColumnIndex);
    developer.log("$_sortColumnIndex => $column ($_sortAscending)",
        name: "Sort");

    switch (column) {
      case "id":
        _formLists.sort((a, b) =>
            _sortAscending ? a.id.compareTo(b.id) : b.id.compareTo(a.id));
        break;
      case "answerBy":
        _formLists.sort((a, b) => _sortAscending
            ? a.answerBy.compareTo(b.answerBy)
            : b.answerBy.compareTo(a.answerBy));
      case "answerDate":
        _formLists.sort((a, b) => _sortAscending
            ? a.answerDate.compareTo(b.answerDate)
            : b.answerDate.compareTo(a.answerDate));
      case "createdAt":
        _formLists.sort((a, b) => _sortAscending
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
