import 'dart:async';
import 'dart:developer' as developer;

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vservesafe/src/components/icon_button_component.dart';
import 'package:vservesafe/src/components/scrollable_container.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/models/department_data.dart';
import 'package:vservesafe/src/models/shedein_form/sva_form.dart';
import 'package:vservesafe/src/models/site_data.dart';
import 'package:vservesafe/src/models/shedein_form/shedein_form.dart';
import 'package:vservesafe/src/services/api_service.dart';
import 'package:vservesafe/src/utils/alert_dialog.dart';

class FoodSafetySvaFormView extends StatefulWidget {
  const FoodSafetySvaFormView({
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
  State<FoodSafetySvaFormView> createState() => _FoodSafetySvaFormViewState();
}

class _FoodSafetySvaFormViewState extends State<FoodSafetySvaFormView> {
  late Timer _timer;
  final List<FoodSafetySvaItemGroup> _formItems = generateSvaformItemGroups();
  bool _isLoadingSite = true;
  bool _isLoadingOpened = false;
  String? _progressText;

  VserveSiteData? _siteData;
  final List<VserveDepartmentData> _departments = [];
  VserveShedeinResponseData _formData =
      VserveShedeinResponseData(formKey: svaFormKey);

  int _currentItemSeq = 0;

  @override
  void initState() {
    super.initState();
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

      // Next parse data
      final answers = formData["answers"];
      List<FoodSafetySvaItem> allItems = _flatAllItems;

      if (answers is List<dynamic>) {
        for (final answer in answers) {
          if (answer is Map<String, dynamic>) {
            final target = allItems
                .firstWhereOrNull((ele) => ele.key == answer["questionId"]);
            if (target != null) {
              target.applyAnswerFromRawData(answer);
            }
          }
        }
      }

      setState(() {});
    } catch (err) {
      developer.log(err.toString(), name: "SVA Form Data");
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
                      AppLocalizations.of(context)!.shedeinFoodSafetySvaTitle,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
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
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context)!
                        .shedeinFoodSafetySvaRemarkTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 7),
                  Text(AppLocalizations.of(context)!
                      .shedeinFoodSafetySvaRemarkCriticalRemarkText),
                  Text(AppLocalizations.of(context)!
                      .shedeinFoodSafetySvaRemarkMajorRemarkText),
                  Text(AppLocalizations.of(context)!
                      .shedeinFoodSafetySvaRemarkMinorRemarkText),
                ],
              ),
              if (!_readonly) ...[
                const SizedBox(height: 14),
                Center(
                  child: ElevatedButton(
                    onPressed: _isFormValid
                        ? () {
                            _submitSvaForm(_formItems);
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
                        .shedeinFoodSafetySvaSubmitButton),
                  ),
                ),
              ]
            ],
          );
  }

  bool get _readonly {
    return widget.formId != null;
  }

  List<FoodSafetySvaItem> get _flatAllItems {
    List<FoodSafetySvaItem> allItems = [];
    for (final items in _formItems) {
      allItems.addAll(items.items);
    }
    return allItems;
  }

  List<FoodSafetySvaItemGroup> get _flatAllGroup {
    List<FoodSafetySvaItemGroup> allItemsGroup = [];
    for (var i = 0; i < _formItems.length; i++) {
      final item = _formItems[i];
      for (var j = 0; j < item.items.length; j++) {
        allItemsGroup.add(item);
      }
    }
    return allItemsGroup;
  }

  Widget get _formWidget {
    double breakpoint = 1600;

    final header = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_readonly) ...[
          Row(
            children: [
              Text(AppLocalizations.of(context)!
                  .shedeinFoodSafetySvaTargetLabel),
              const SizedBox(width: 7),
              Expanded(
                child: Container(
                  color: Colors.grey.shade300,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(_formData.answerBy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        Row(
          children: [
            Text(AppLocalizations.of(context)!.shedeinFoodSafetySvaAreaLabel),
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
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 7),
                          border: const OutlineInputBorder(),
                          errorText: _formData.isValid ? null : "Required",
                        ),
                        value: _formData.pair,
                        onChanged: (value) {
                          _formData.pair = value;
                          setState(() {});
                        },
                        items: _departmentsDropdownOption.map((pair) {
                          return DropdownMenuItem<VserveShedeinDepartmentData>(
                            value: pair,
                            child: Text(
                              _prettyDepartmentPair(pair),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final colCount = width <= 600 ? 1 : 2;

            return GridView(
              shrinkWrap: true,
              primary: false,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: colCount,
                mainAxisExtent: 21,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              children: [
                Row(
                  children: [
                    Text(AppLocalizations.of(context)!
                        .shedeinFoodSafetySvaDateLabel),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Container(
                        color: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Text(_formatDate(_formData.answerDate)),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(AppLocalizations.of(context)!
                        .shedeinFoodSafetySvaPercentScoreLabel),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Container(
                        color: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Text(_percentScore.toStringAsFixed(2)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
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

  List<VserveShedeinDepartmentData> get _departmentsDropdownOption {
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

  Widget get _shortListView {
    String lang = widget.settingsController.locale.toLanguageTag();
    final colorHeader = Colors.grey.shade300;
    const padding = EdgeInsets.symmetric(horizontal: 14, vertical: 7);
    final currenFormGroup = _flatAllGroup[_currentItemSeq];
    final currenFormItem = _flatAllItems[_currentItemSeq];

    final seq = _formItems.indexWhere((element) => element == currenFormGroup);
    final subseq = currenFormGroup.items
        .indexWhere((element) => element == currenFormItem);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                "${seq + 1}.${subseq + 1}",
                style: const TextStyle(fontSize: 21),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButtonComponent(
                  icon: FontAwesomeIcons.chevronRight,
                  onPressed: _currentItemSeq < _flatAllGroup.length - 1
                      ? () {
                          _currentItemSeq += 1;
                          setState(() {});
                        }
                      : null,
                  width: 36,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Container(
          padding: padding,
          color: colorHeader,
          child: Text("${seq + 1}. ${currenFormGroup.getTranslatedText(lang)}"),
        ),
        const SizedBox(height: 7),
        Padding(
          padding: padding,
          child: Text(
              "${seq + 1}.${subseq + 1}. ${currenFormItem.getTranslatedText(lang)}"),
        ),
        const SizedBox(height: 7),
        Padding(
          padding: padding,
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                text: AppLocalizations.of(context)!
                    .shedeinFoodSafetySvaRiskLevelTitle,
              ),
              const TextSpan(text: ": "),
              TextSpan(
                text: _riskLevelPretty(currenFormItem.risklevel),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _riskLevelColor(currenFormItem.risklevel),
                ),
              ),
              TextSpan(
                text: " (${currenFormItem.baseScore})",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _riskLevelColor(currenFormItem.risklevel),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 7),
        Padding(
          padding: padding,
          child: _complianceInputForm(currenFormItem),
        ),
        if (currenFormItem.isNonComplicant) ...[
          const SizedBox(height: 7),
          Padding(
            padding: padding,
            child: Row(
              children: [
                Text(AppLocalizations.of(context)!
                    .shedeinFoodSafetySvaScoreDeductionTitle),
                const SizedBox(width: 7),
                Expanded(
                  child: _scoreDeductionInputForm(currenFormItem),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Padding(
            padding: padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!
                    .shedeinFoodSafetySvaFindingsTitle),
                const SizedBox(width: 14),
                Expanded(
                  child: _evidenceInputForm(currenFormItem),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget get _wideTableView {
    const tablePadding = EdgeInsets.symmetric(horizontal: 7, vertical: 7);

    return ScrollableContainerComponent(
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(75),
          1: MaxColumnWidth(
            FlexColumnWidth(),
            FixedColumnWidth(200),
          ),
          2: FixedColumnWidth(100),
          3: FixedColumnWidth(100),
          4: FixedColumnWidth(175),
          5: FixedColumnWidth(150),
          6: FixedColumnWidth(250),
        },
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
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  padding: tablePadding,
                  child: Text(
                    AppLocalizations.of(context)!.shedeinFoodSafetySvaSeqTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  padding: tablePadding,
                  child: Text(
                    AppLocalizations.of(context)!.shedeinFoodSafetySvaNameTitle,
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
                        .shedeinFoodSafetySvaRiskLevelTitle,
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
                        .shedeinFoodSafetySvaBaseScoreTitle,
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
                        .shedeinFoodSafetySvaComplianceStatusTitle,
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
                        .shedeinFoodSafetySvaScoreDeductionTitle,
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
                        .shedeinFoodSafetySvaFindingsTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          ..._generateTableRowListFromSvaItemGroup(context, _formItems),
          TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(),
              ),
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
                        .shedeinFoodSafetySvaTotalScoreLabel,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  padding: tablePadding,
                  child: Text(
                    _totalBaseScore.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                        .shedeinFoodSafetySvaTotalDeductionLabel,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  padding: tablePadding,
                  child: Text(
                    _totalDeductionScore.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _complianceInputForm(FoodSafetySvaItem item) {
    return _readonly
        ? Text(item.isNonComplicant
            ? AppLocalizations.of(context)!.shedeinFoodSafetySvaComplianceChoice
            : AppLocalizations.of(context)!
                .shedeinFoodSafetySvaNotComplianceChoice)
        : DropdownButtonFormField<FoodsafetySvaComplicantLevel?>(
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            ),
            value: item.complicantLevel,
            onChanged: (value) {
              item.complicantLevel = value;
              setState(() {});
            },
            items: [
              DropdownMenuItem<FoodsafetySvaComplicantLevel?>(
                value: FoodsafetySvaComplicantLevel.complicant,
                child: Text(
                  AppLocalizations.of(context)!
                      .shedeinFoodSafetySvaComplianceChoice,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              DropdownMenuItem<FoodsafetySvaComplicantLevel?>(
                value: FoodsafetySvaComplicantLevel.nonComplicant,
                child: Text(
                  AppLocalizations.of(context)!
                      .shedeinFoodSafetySvaNotComplianceChoice,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          );
  }

  Widget _scoreDeductionInputForm(FoodSafetySvaItem item) {
    return _readonly
        ? Text(item.deductionScore.toString())
        : SpinBox(
            value: item.deductionScore.toDouble(),
            decimals: 0,
            min: 0,
            max: item.baseScore.toDouble(),
            onSubmitted: (value) {
              item.deductionScore = value.toInt();
              setState(() {});
            },
            iconSize: 14,
            decoration: const InputDecoration(
              isDense: true,
              isCollapsed: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            ),
          );
  }

  Widget _evidenceInputForm(FoodSafetySvaItem item) {
    return _readonly
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(item.evidence),
              if (item.filePath.isNotEmpty) ...[
                const SizedBox(height: 7),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      if (!await launchUrl(Uri.parse(item.serverFileUrl))) {
                        throw Exception(
                            'Could not launch ${item.serverFileUrl}');
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!
                          .shedeinFoodSafetySvaFileLink,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ]
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                  errorText: item.evidence.isEmpty ? "Required" : null,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onChanged: (value) {
                  item.evidence = value;
                  setState(() {});
                },
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  IconButtonComponent(
                    icon: FontAwesomeIcons.file,
                    color: const Color(0xff975aff),
                    onPressed: () {
                      _pickFile(item);
                    },
                    width: 36,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    AppLocalizations.of(context)!
                        .shedeinFoodSafetySvaFileSelectedCountLabel(
                            item.fileEvidence != null ? 1 : 0),
                  ),
                  if (item.fileEvidence != null) ...[
                    const SizedBox(width: 14),
                    IconButtonComponent(
                      icon: FontAwesomeIcons.rotateLeft,
                      color: const Color(0xff975aff),
                      onPressed: () {
                        _revertPickFile(item);
                      },
                      width: 36,
                    ),
                  ]
                ],
              ),
            ],
          );
  }

  List<TableRow> _generateTableRowListFromSvaItemGroup(
      BuildContext context, List<FoodSafetySvaItemGroup> groups) {
    List<TableRow> result = [];
    String lang = widget.settingsController.locale.toLanguageTag();

    for (final itemGroupEntry in groups.asMap().entries) {
      final seq = itemGroupEntry.key + 1;
      final group = itemGroupEntry.value;
      final headerRow =
          _generateTableRowHeaderFromSvaItemGroup(group, lang: lang, seq: seq);
      result.add(headerRow);

      for (final itemEntry in group.items.asMap().entries) {
        final row = _generateTableRowFromSvaItem(
          itemEntry.value,
          lang: lang,
          seq: seq,
          subseq: itemEntry.key + 1,
        );
        result.add(row);
      }
    }

    return result;
  }

  TableRow _generateTableRowHeaderFromSvaItemGroup(
    FoodSafetySvaItemGroup group, {
    required String lang,
    required int seq,
  }) {
    const tablePadding = EdgeInsets.symmetric(horizontal: 7, vertical: 7);
    final colorHeader = Colors.grey.shade300;

    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            padding: tablePadding,
            color: colorHeader,
            child: Text("$seq", textAlign: TextAlign.center),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Container(
            padding: tablePadding,
            color: colorHeader,
            child: Text(group.getTranslatedText(lang)),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            color: colorHeader,
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            color: colorHeader,
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            color: colorHeader,
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            color: colorHeader,
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            color: colorHeader,
          ),
        ),
      ],
    );
  }

  TableRow _generateTableRowFromSvaItem(
    FoodSafetySvaItem item, {
    required String lang,
    required int seq,
    required int subseq,
  }) {
    const tablePadding = EdgeInsets.symmetric(horizontal: 7, vertical: 7);
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Container(
            padding: tablePadding,
            child: Text("$seq.$subseq", textAlign: TextAlign.center),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Container(
            padding: tablePadding,
            child: Text(item.getTranslatedText(lang)),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            padding: tablePadding,
            child: Text(
              _riskLevelPretty(item.risklevel),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _riskLevelColor(item.risklevel),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            padding: tablePadding,
            child: Text(
              "${item.baseScore}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _riskLevelColor(item.risklevel),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            padding: tablePadding,
            child: _complianceInputForm(item),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            padding: tablePadding,
            child: (item.isNonComplicant)
                ? _scoreDeductionInputForm(item)
                : Container(),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            padding: tablePadding,
            child:
                (item.isNonComplicant) ? _evidenceInputForm(item) : Container(),
          ),
        ),
      ],
    );
  }

  int get _totalBaseScore {
    int baseScore = 0;
    for (final itemGroup in _formItems) {
      baseScore += itemGroup.totalBaseScore;
    }
    return baseScore;
  }

  int get _totalDeductionScore {
    int deductionScore = 0;
    for (final itemGroup in _formItems) {
      deductionScore += itemGroup.totalDeductionScore;
    }
    return deductionScore;
  }

  double get _percentScore {
    if (_totalBaseScore == 0) {
      return 0;
    }

    return 100 * ((_totalBaseScore - _totalDeductionScore) / _totalBaseScore);
  }

  String _formatDate(DateTime datetime) {
    String head =
        DateFormat.yMd(widget.settingsController.locale.toLanguageTag())
            .format(datetime.toLocal());

    return head;
  }

  bool get _isFormValid {
    if (!_formData.isValid) {
      return false;
    }

    for (final itemGroup in _formItems) {
      if (!itemGroup.isFormValid) {
        return false;
      }
    }
    return true;
  }

  String _prettyDepartmentPair(VserveShedeinDepartmentData pair) {
    String text = pair.department.name;
    if (pair.location != null) {
      text += " - ${pair.location}";
    }
    return text;
  }

  String _riskLevelPretty(FoodsafetySvaRiskLevel risklevel) {
    switch (risklevel) {
      case FoodsafetySvaRiskLevel.C:
        return "C";
      case FoodsafetySvaRiskLevel.M:
        return "M";
      case FoodsafetySvaRiskLevel.MI:
        return "MI";
    }
  }

  Color _riskLevelColor(FoodsafetySvaRiskLevel risklevel) {
    switch (risklevel) {
      case FoodsafetySvaRiskLevel.C:
        return Colors.red;
      case FoodsafetySvaRiskLevel.M:
        return Colors.yellow.shade800;
      case FoodsafetySvaRiskLevel.MI:
        return Colors.black;
    }
  }

  Future<void> _pickFile(FoodSafetySvaItem item) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ["pdf"]);

    if (result != null) {
      PlatformFile file = result.files.first;
      item.fileEvidence = file;
      setState(() => {});
    }
  }

  void _revertPickFile(FoodSafetySvaItem item) {
    item.fileEvidence = null;
    setState(() => {});
  }

  void _submitSvaForm(List<FoodSafetySvaItemGroup> group) async {
    _showLoadingDialog();

    final uploadEvidenceProgressText =
        AppLocalizations.of(context)!.shedeinFoodSafetySvaProgressUploadFile;
    final submitDataProgressText =
        AppLocalizations.of(context)!.shedeinFoodSafetySvaProgressSubmitData;
    final successText = AppLocalizations.of(context)!
        .shedeinFoodSafetySvaSubmitDataSuccessfulTitle;
    final failedText =
        AppLocalizations.of(context)!.shedeinFoodSafetySvaSubmitDataFailedTitle;

    try {
      _progressText = uploadEvidenceProgressText;
      setState(() {});

      List<FoodSafetySvaItem> uploadedItems = [];

      // Scan item
      for (final groupItem in group) {
        for (final item in groupItem.items) {
          if (item.fileEvidence != null) {
            uploadedItems.add(item);
          }
        }
      }

      if (uploadedItems.isNotEmpty) {
        int success = 0;

        for (final item in uploadedItems) {
          success += 1;
          _progressText =
              "$uploadEvidenceProgressText\n$success/${uploadedItems.length}";
          setState(() {});

          item.filePath = await _uploadFile(item.fileEvidence!);
          developer.log("Uploaded", name: "Upload File");
        }
      }

      _progressText = submitDataProgressText;
      setState(() {});

      await ApiService.dio.post(
        "${ApiService.baseUrlPath}/shedein-res/add",
        data: _formData.toApiSvaData(group, siteId: _siteData?.id),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      developer.log("Added", name: "Add Shedein Foodsafety Sva Form");
      setState(() {});

      await _showSuccessDialog(successText);
    } catch (err) {
      developer.log(err.toString(), name: "Add Shedein Foodsafety Sva Form");

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

  Future<String> _uploadFile(PlatformFile file) async {
    late FormData formData;
    formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(file.bytes!.toList(),
          filename: "file.pdf",
          contentType: MediaType.parse("application/pdf")),
    });

    final result = await ApiService.dio.post(
      "${ApiService.baseUrlPath}/sva-evidence/upload",
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
      ),
    );

    developer.log(result.data["path"], name: "Evidence Path");

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
