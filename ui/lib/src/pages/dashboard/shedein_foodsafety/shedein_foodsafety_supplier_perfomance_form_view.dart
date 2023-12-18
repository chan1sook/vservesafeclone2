import 'dart:async';
import 'dart:developer' as developer;

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:vservesafe/src/components/icon_button_component.dart';
import 'package:vservesafe/src/components/scrollable_container.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/models/department_data.dart';
import 'package:vservesafe/src/models/shedein_form/supplier_perfomance_form.dart';
import 'package:vservesafe/src/models/site_data.dart';
import 'package:vservesafe/src/models/shedein_form/shedein_form.dart';
import 'package:vservesafe/src/services/api_service.dart';
import 'package:vservesafe/src/utils/alert_dialog.dart';

class FoodSafetyPerformanceFormView extends StatefulWidget {
  const FoodSafetyPerformanceFormView({
    super.key,
    required this.userController,
    required this.settingsController,
    this.onBack,
    this.afterSentForm,
    this.formId,
  });

  final UserController userController;
  final SettingsController settingsController;
  final Function()? onBack;
  final Function()? afterSentForm;
  final String? formId;
  @override
  State<FoodSafetyPerformanceFormView> createState() =>
      _FoodSafetyPerformanceFormViewState();
}

class _FoodSafetyPerformanceFormViewState
    extends State<FoodSafetyPerformanceFormView> {
  late Timer _timer;
  final List<FoodsafetyPerfomanceFormItem> _formItems = [];
  final List<TextEditingController> _supplierTextFieldCtrl = [];
  final List<TextEditingController> _productTextFieldCtrl = [];
  final List<TextEditingController> _reviewByTextFieldCtrl = [];
  final List<TextEditingController> _remarkByTextFieldCtrl = [];
  bool _isLoadingSite = true;
  bool _isLoadingOpened = false;
  String? _progressText;

  VserveSiteData? _siteData;
  final List<VserveDepartmentData> _departments = [];
  VserveShedeinResponseData _formData =
      VserveShedeinResponseData(formKey: supplierPerformanceFormKey);

  int _currentItemSeq = 0;

  @override
  void initState() {
    super.initState();
    _addFormItem();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final site = widget.userController.selectedSite;

      if (_siteData != site) {
        if (_readonly) {
          widget.onBack?.call();
        } else {
          _siteData = site;
          _loadAllData();
          _isLoadingSite = true;
          setState(() {});
        }
      }
    });

    _siteData = widget.userController.selectedSite;
    _isLoadingSite = true;
    _loadAllData();
  }

  @override
  void reassemble() {
    super.reassemble();

    _siteData = widget.userController.selectedSite;
    _loadAllData();
    _isLoadingSite = true;
    setState(() {});
  }

  void _loadAllData() async {
    await _loadDepartments();

    if (_readonly) {
      await _loadFormData();
    }

    _isLoadingSite = false;
    setState(() {});
  }

  Future<void> _loadFormData() async {
    if (_siteData == null) {
      return;
    }

    try {
      final response = await ApiService.dio.get(
        "${ApiService.baseUrlPath}/shedein-res/get/${widget.formId}",
      );

      final formData = response.data["shedeinResponse"] as Map<String, dynamic>;
      _formData =
          VserveShedeinResponseData.parseFromRawData(formData, _departments);

      _formItems.clear();

      // Next parse data
      final answers = formData["answers"];
      if (answers is List<dynamic>) {
        for (final answer in answers) {
          if (answer is Map<String, dynamic>) {
            _formItems
                .add(FoodsafetyPerfomanceFormItem.parseFromRawData(answer));
          }
        }
      }

      setState(() {});
    } catch (err) {
      developer.log(err.toString(), name: "Supplier Performance Form Data");
    }
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
        if (_departments.isNotEmpty) {
          final department = _departments.first;
          _formData.pair = VserveShedeinDepartmentData(
              department: department,
              location: department.locations.firstOrNull);
        } else {
          _formData.pair = null;
        }
        setState(() {});
      }
    } catch (err) {
      developer.log(err.toString(), name: "Department Lists");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoadingSite
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      AppLocalizations.of(context)!
                          .shedeinFoodSafetySupplierPerformanceReviewTitle,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 14),
              Text(
                AppLocalizations.of(context)!
                    .shedeinFoodSafetySupplierPerformanceAnnuallyWarningText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: _formWidget,
                ),
              ),
              const SizedBox(height: 14),
              _assignmentCriteriaWidget,
              if (!_readonly) ...[
                const SizedBox(height: 14),
                Center(
                  child: ElevatedButton(
                    onPressed: _isFormValid
                        ? () {
                            _submitPerfomanceForm(_formItems);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      backgroundColor: const Color(0xff975aff),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 21, vertical: 7),
                    ),
                    child: Text(AppLocalizations.of(context)!
                        .shedeinFoodSafetySupplierPerformanceSubmitButton),
                  ),
                ),
              ]
            ],
          );
  }

  Widget get _formWidget {
    double breakpoint = 1600;
    final header = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context)!
                .shedeinFoodSafetySupplierPerformanceAreaLabel),
            const SizedBox(width: 7),
            Expanded(
              child: _readonly
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      color: Colors.grey.shade300,
                      child: Text(_formData.pair != null
                          ? _prettyDepartmentPair(_formData.pair!)
                          : "??"),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child:
                          DropdownButtonFormField<VserveShedeinDepartmentData>(
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade300,
                          isDense: true,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3.5),
                          errorText: _formData.isValid ? null : "Required",
                        ),
                        value: _formData.pair,
                        onChanged: (value) {
                          _formData.pair = value;
                          setState(() {});
                        },
                        items: _getDepartmentsDropdownOption.map((pair) {
                          return DropdownMenuItem<VserveShedeinDepartmentData>(
                            value: pair,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _prettyDepartmentPair(pair),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          AppLocalizations.of(context)!
              .shedeinFoodSafetySupplierPerformanceRatingText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final boxConstraints =
              BoxConstraints(maxWidth: width < breakpoint ? 800 : 1200);
          return Center(
            child: ConstrainedBox(
              constraints: boxConstraints,
              child: header,
            ),
          );
        }),
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
      ],
    );
  }

  Widget get _assignmentCriteriaWidget {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!
              .shedeinFoodSafetySupplierPerformanceAssessmentCriteriaLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3.5),
        Text(
          AppLocalizations.of(context)!
              .shedeinFoodSafetySupplierPerformanceCriteriaQualityText,
        ),
        Text(
          AppLocalizations.of(context)!
              .shedeinFoodSafetySupplierPerformanceCriteriaDocumentText,
        ),
        Text(
          AppLocalizations.of(context)!
              .shedeinFoodSafetySupplierPerformanceCriteriaDeliveryText,
        ),
        Text(
          AppLocalizations.of(context)!
              .shedeinFoodSafetySupplierPerformanceCriteriaResponseText,
        ),
      ],
    );
  }

  Widget get _shortListView {
    final item = _formItems[_currentItemSeq];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _pageIndicator,
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!
                  .shedeinFoodSafetySupplierPerformanceSupplierTitle,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _supplierFormInput(_currentItemSeq),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!
                  .shedeinFoodSafetySupplierPerformanceProductTitle,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _productFormInput(_currentItemSeq),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!
                  .shedeinFoodSafetySupplierPerformanceTotalScoreTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 7),
            Text(
              "${item.scorePercentage}",
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!
                  .shedeinFoodSafetySupplierPerformanceQualityScoreTitle,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _qualityScoreFormInput(_currentItemSeq),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!
                  .shedeinFoodSafetySupplierPerformanceDeliveryScoreTitle,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _deliveryScoreFormInput(_currentItemSeq),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!
                  .shedeinFoodSafetySupplierPerformanceDocumentScoreTitle,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _documentScoreFormInput(_currentItemSeq),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!
                  .shedeinFoodSafetySupplierPerformanceResponseScoreTitle,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _responseScoreFormInput(_currentItemSeq),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!
                  .shedeinFoodSafetySupplierPerformanceReviewDateTitle,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _reviewDateFormInput(_currentItemSeq),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!
                  .shedeinFoodSafetySupplierPerformanceReviewByTitle,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _reviewByFormInput(_currentItemSeq),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!
                  .shedeinFoodSafetySupplierPerformanceRemarkTitle,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _remarkFormInput(_currentItemSeq),
            ),
          ],
        ),
      ],
    );
  }

  Widget get _pageIndicator {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!_readonly)
          IconButtonComponent(
            icon: FontAwesomeIcons.trash,
            onPressed: _currentItemSeq > 0
                ? () {
                    _removeFormItem(_currentItemSeq);
                    if (_currentItemSeq >= _formItems.length) {
                      _currentItemSeq = _formItems.length - 1;
                    }
                    setState(() {});
                  }
                : null,
            width: 36,
          ),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerRight,
            child: IconButtonComponent(
              icon: FontAwesomeIcons.chevronLeft,
              onPressed: _currentItemSeq > 0
                  ? () {
                      _currentItemSeq -= 1;
                      setState(() {});
                    }
                  : null,
              width: 36,
            ),
          ),
        ),
        SizedBox(
          width: 75,
          child: Text(
            "${_currentItemSeq + 1}",
            style: const TextStyle(fontSize: 21),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _readonly
                ? IconButtonComponent(
                    icon: FontAwesomeIcons.chevronRight,
                    onPressed: _currentItemSeq < _formItems.length - 1
                        ? () {
                            _currentItemSeq += 1;
                            setState(() {});
                          }
                        : null,
                    width: 36,
                  )
                : IconButtonComponent(
                    icon: (_currentItemSeq == _formItems.length - 1)
                        ? FontAwesomeIcons.plus
                        : FontAwesomeIcons.chevronRight,
                    onPressed: _currentItemSeq < _formItems.length
                        ? () {
                            if (_currentItemSeq == _formItems.length - 1) {
                              _addFormItem();
                            }
                            _currentItemSeq += 1;
                            setState(() {});
                          }
                        : null,
                    width: 36,
                  ),
          ),
        ),
      ],
    );
  }

  Widget get _wideTableView {
    const tablePadding = EdgeInsets.symmetric(horizontal: 7, vertical: 7);

    return ScrollableContainerComponent(
      child: Table(
        columnWidths: _columnWidths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: const TableBorder(
          top: BorderSide(color: Colors.black12),
          bottom: BorderSide(color: Colors.black12),
          left: BorderSide(color: Colors.black12),
          right: BorderSide(color: Colors.black12),
          horizontalInside: BorderSide(color: Colors.black12),
          verticalInside: BorderSide(color: Colors.black12),
        ),
        children: [
          TableRow(
            children: [
              if (!_readonly)
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(),
                ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  padding: tablePadding,
                  child: Text(
                    AppLocalizations.of(context)!
                        .shedeinFoodSafetySupplierPerformanceSupplierTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  padding: tablePadding,
                  child: Text(
                    AppLocalizations.of(context)!
                        .shedeinFoodSafetySupplierPerformanceProductTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  padding: tablePadding,
                  child: Text(
                    AppLocalizations.of(context)!
                        .shedeinFoodSafetySupplierPerformanceQualityScoreTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  padding: tablePadding,
                  child: Text(
                    AppLocalizations.of(context)!
                        .shedeinFoodSafetySupplierPerformanceDeliveryScoreTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  padding: tablePadding,
                  child: Text(
                    AppLocalizations.of(context)!
                        .shedeinFoodSafetySupplierPerformanceDocumentScoreTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  padding: tablePadding,
                  child: Text(
                    AppLocalizations.of(context)!
                        .shedeinFoodSafetySupplierPerformanceResponseScoreTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  padding: tablePadding,
                  child: Text(
                    AppLocalizations.of(context)!
                        .shedeinFoodSafetySupplierPerformanceTotalScoreTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  padding: tablePadding,
                  child: Text(
                    AppLocalizations.of(context)!
                        .shedeinFoodSafetySupplierPerformanceReviewDateTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  padding: tablePadding,
                  child: Text(
                    AppLocalizations.of(context)!
                        .shedeinFoodSafetySupplierPerformanceReviewByTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  padding: tablePadding,
                  child: Text(
                    AppLocalizations.of(context)!
                        .shedeinFoodSafetySupplierPerformanceRemarkTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          ..._formItems.mapIndexed((i, ele) {
            return _generateFromItem(ele, i);
          }),
          if (!_readonly)
            TableRow(
              children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    padding: tablePadding,
                    alignment: Alignment.center,
                    child: IconButtonComponent(
                      icon: FontAwesomeIcons.plus,
                      color: Colors.black,
                      onPressed: () {
                        _addFormItem();
                        setState(() {});
                      },
                      width: 32,
                    ),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Container(
                    padding: tablePadding,
                    child: Container(),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Container(
                    padding: tablePadding,
                    child: Container(),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Container(
                    padding: tablePadding,
                    child: Container(),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Container(
                    padding: tablePadding,
                    child: Container(),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Container(
                    padding: tablePadding,
                    child: Container(),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Container(
                    padding: tablePadding,
                    child: Container(),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Container(
                    padding: tablePadding,
                    child: Container(),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Container(
                    padding: tablePadding,
                    child: Container(),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Container(
                    padding: tablePadding,
                    child: Container(),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Container(
                    padding: tablePadding,
                    child: Container(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _addFormItem() {
    _formItems.add(FoodsafetyPerfomanceFormItem());
    _supplierTextFieldCtrl.add(TextEditingController());
    _productTextFieldCtrl.add(TextEditingController());
    _reviewByTextFieldCtrl.add(TextEditingController());
    _remarkByTextFieldCtrl.add(TextEditingController());
  }

  void _removeFormItem(int index) {
    _formItems.removeAt(index);
    _supplierTextFieldCtrl.removeAt(index);
    _productTextFieldCtrl.removeAt(index);
    _reviewByTextFieldCtrl.removeAt(index);
    _remarkByTextFieldCtrl.removeAt(index);
  }

  Map<int, TableColumnWidth> get _columnWidths {
    var inputWidth =
        _readonly ? const FixedColumnWidth(80) : const FixedColumnWidth(150);
    var baseColumnWidths = [
      const FixedColumnWidth(150),
      const FixedColumnWidth(150),
      inputWidth,
      inputWidth,
      inputWidth,
      inputWidth,
      const FixedColumnWidth(80),
      const FixedColumnWidth(150),
      const FixedColumnWidth(150),
      const MaxColumnWidth(
        FlexColumnWidth(),
        FixedColumnWidth(150),
      ),
    ];

    if (!_readonly) {
      baseColumnWidths.insert(0, const FixedColumnWidth(70));
    }

    Map<int, TableColumnWidth> result = {};
    for (var i = 0; i < baseColumnWidths.length; i += 1) {
      result[i] = baseColumnWidths[i];
    }

    return result;
  }

  Widget _supplierFormInput(int index) {
    final item = _formItems[index];
    return _readonly
        ? Text(item.supplier)
        : TextField(
            controller: _supplierTextFieldCtrl[index],
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            ),
            onChanged: (value) {
              item.supplier = value;
              setState(() {});
            },
          );
  }

  Widget _productFormInput(int index) {
    final item = _formItems[index];
    return _readonly
        ? Text(item.product)
        : TextField(
            controller: _productTextFieldCtrl[index],
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            ),
            onChanged: (value) {
              item.product = value;
              setState(() {});
            },
          );
  }

  Widget _qualityScoreFormInput(int index) {
    final item = _formItems[index];
    return _readonly
        ? Text("${item.qualityScore}", textAlign: TextAlign.center)
        : SpinBox(
            value: item.qualityScore.toDouble(),
            decimals: 0,
            min: 1,
            max: 5,
            iconSize: 14,
            decoration: const InputDecoration(
              isDense: true,
              isCollapsed: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            ),
            onSubmitted: (value) {
              item.qualityScore = value.toInt();
              setState(() {});
            },
          );
  }

  Widget _deliveryScoreFormInput(int index) {
    final item = _formItems[index];
    return _readonly
        ? Text("${item.deliveryScore}", textAlign: TextAlign.center)
        : SpinBox(
            value: item.deliveryScore.toDouble(),
            decimals: 0,
            min: 1,
            max: 5,
            iconSize: 14,
            decoration: const InputDecoration(
              isDense: true,
              isCollapsed: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            ),
            onSubmitted: (value) {
              item.deliveryScore = value.toInt();
              setState(() {});
            },
          );
  }

  Widget _documentScoreFormInput(int index) {
    final item = _formItems[index];
    return _readonly
        ? Text("${item.documentScore}", textAlign: TextAlign.center)
        : SpinBox(
            value: item.documentScore.toDouble(),
            decimals: 0,
            min: 1,
            max: 5,
            iconSize: 14,
            decoration: const InputDecoration(
              isDense: true,
              isCollapsed: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            ),
            onSubmitted: (value) {
              item.documentScore = value.toInt();
              setState(() {});
            },
          );
  }

  Widget _responseScoreFormInput(int index) {
    final item = _formItems[index];
    return _readonly
        ? Text("${item.responseScore}", textAlign: TextAlign.center)
        : SpinBox(
            value: item.responseScore.toDouble(),
            decimals: 0,
            min: 1,
            max: 5,
            iconSize: 14,
            decoration: const InputDecoration(
              isDense: true,
              isCollapsed: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            ),
            onSubmitted: (value) {
              item.responseScore = value.toInt();
              setState(() {});
            },
          );
  }

  Widget _reviewDateFormInput(int index) {
    final item = _formItems[index];
    return _readonly
        ? Text(
            _formatDate(item.reviewDate),
            textAlign: TextAlign.center,
          )
        : MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () async {
                final value = await showCalendarDatePicker2Dialog(
                  context: context,
                  config: CalendarDatePicker2WithActionButtonsConfig(
                    calendarType: CalendarDatePicker2Type.single,
                    currentDate: item.reviewDate,
                  ),
                  dialogSize: const Size(325, 400),
                  value: [item.reviewDate],
                  borderRadius: BorderRadius.circular(15),
                );
                if (value != null && value.isNotEmpty) {
                  item.reviewDate = value[0]!;
                  setState(() {});
                }
              },
              child: Text(
                _formatDate(item.reviewDate),
                textAlign: TextAlign.center,
              ),
            ),
          );
  }

  Widget _reviewByFormInput(int index) {
    final item = _formItems[index];
    return _readonly
        ? Text(item.reviewBy)
        : TextField(
            controller: _reviewByTextFieldCtrl[index],
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            ),
            onChanged: (value) {
              item.reviewBy = value;
              setState(() {});
            },
          );
  }

  Widget _remarkFormInput(int index) {
    final item = _formItems[index];
    return _readonly
        ? Text(item.remark)
        : TextField(
            controller: _remarkByTextFieldCtrl[index],
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            ),
            onChanged: (value) {
              item.remark = value;
              setState(() {});
            },
          );
  }

  TableRow _generateFromItem(FoodsafetyPerfomanceFormItem item, int index) {
    const tablePadding = EdgeInsets.symmetric(horizontal: 7, vertical: 7);

    return TableRow(
      children: [
        if (!_readonly)
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.top,
            child: Container(
              padding: tablePadding,
              alignment: Alignment.center,
              child: index > 0
                  ? IconButtonComponent(
                      icon: FontAwesomeIcons.minus,
                      color: Colors.black,
                      onPressed: () {
                        _removeFormItem(index);
                        setState(() {});
                      },
                      width: 32,
                    )
                  : null,
            ),
          ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Container(
            padding: tablePadding,
            child: _supplierFormInput(index),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Container(
            padding: tablePadding,
            child: _productFormInput(index),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            padding: tablePadding,
            child: Center(
              child: _qualityScoreFormInput(index),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            padding: tablePadding,
            child: Center(
              child: _deliveryScoreFormInput(index),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            padding: tablePadding,
            child: Center(
              child: _documentScoreFormInput(index),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            padding: tablePadding,
            child: Center(
              child: _responseScoreFormInput(index),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            padding: tablePadding,
            child: Center(
              child: Text(
                "${item.scorePercentage}",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            padding: tablePadding,
            child: Center(
              child: _reviewDateFormInput(index),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Container(
            padding: tablePadding,
            child: _reviewByFormInput(index),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Container(
            padding: tablePadding,
            child: _remarkFormInput(index),
          ),
        ),
      ],
    );
  }

  bool get _readonly {
    return widget.formId != null;
  }

  String _formatDate(DateTime datetime) {
    String head =
        DateFormat.yMd(widget.settingsController.locale.toLanguageTag())
            .format(datetime.toLocal());

    return head;
  }

  bool get _isFormValid {
    if (_formItems.isEmpty) {
      return false;
    }

    for (final itemGroup in _formItems) {
      if (!itemGroup.isFormValid) {
        return false;
      }
    }
    return true;
  }

  List<VserveShedeinDepartmentData> get _getDepartmentsDropdownOption {
    List<VserveShedeinDepartmentData> result = [];
    for (final department in _departments) {
      if (department.locations.isNotEmpty) {
        for (final location in department.locations) {
          result.add(VserveShedeinDepartmentData(
              department: department, location: location));
        }
      } else {
        result.add(VserveShedeinDepartmentData(department: department));
      }
    }
    return result;
  }

  String _prettyDepartmentPair(VserveShedeinDepartmentData pair) {
    String text = pair.department.name;
    if (pair.location != null) {
      text += " - ${pair.location}";
    }
    return text;
  }

  void _submitPerfomanceForm(List<FoodsafetyPerfomanceFormItem> items) async {
    _showLoadingDialog();

    final successText = AppLocalizations.of(context)!
        .shedeinFoodSafetySupplierPerformanceSubmitDataSuccessfulTitle;
    final failedText = AppLocalizations.of(context)!
        .shedeinFoodSafetySupplierPerformanceSubmitDataFailedTitle;

    try {
      setState(() {});

      await ApiService.dio.post(
        "${ApiService.baseUrlPath}/shedein-res/add",
        data:
            _formData.toApiPerfomanceSuplierData(items, siteId: _siteData?.id),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log("Added", name: "Add Shedein Foodsafety Supplier Form");
      setState(() {});

      await _showSuccessDialog(successText);
    } catch (err) {
      developer.log(err.toString(),
          name: "Add Shedein Foodsafety Supplier Form");

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
                widget.afterSentForm?.call();
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
