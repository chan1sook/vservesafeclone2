import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vservesafe/src/components/grid_form_item_component.dart';
import 'package:vservesafe/src/components/tabs_component.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/models/shedein_form/supplier_perfomance_form.dart';
import 'package:vservesafe/src/models/shedein_form/sva_form.dart';
import 'package:vservesafe/src/models/shedein_form/shedein_form.dart';
import 'package:vservesafe/src/pages/dashboard/shedein_foodsafety/shedein_foodsafety_history_view.dart';
import 'package:vservesafe/src/pages/dashboard/shedein_foodsafety/shedein_foodsafety_supplier_perfomance_form_view.dart';
import 'package:vservesafe/src/pages/dashboard/shedein_foodsafety/shedein_foodsafety_sva_form_view.dart';

class ShedeinFoodsafetyDashboardView extends StatefulWidget {
  const ShedeinFoodsafetyDashboardView({
    super.key,
    required this.settingsController,
    required this.userController,
  });

  final SettingsController settingsController;
  final UserController userController;
  static const routeName = '/shedein-foodsafety';

  @override
  State<ShedeinFoodsafetyDashboardView> createState() =>
      _ShedeinFoodsafetyDashboardViewState();
}

class _ShedeinFoodsafetyDashboardViewState
    extends State<ShedeinFoodsafetyDashboardView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  String? _selectedFormKey;
  String? _selectedFormKeyReport;
  bool _showResponseList = false;
  String? _selectedFormId;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      shrinkWrap: true,
      children: [
        VserveTabBarComponent(
          tabs: [
            VserveHorizontalTabComponent(
              icon: const FaIcon(FontAwesomeIcons.pencil),
              label:
                  Text(AppLocalizations.of(context)!.shedeinFoodSafetyFormTab),
            ),
            VserveHorizontalTabComponent(
              icon: const FaIcon(FontAwesomeIcons.book),
              label: Text(
                  AppLocalizations.of(context)!.shedeinFoodSafetyReportTab),
            ),
          ],
          controller: _tabController,
          onTap: (index) {
            _tabController.index = index;
            setState(() {});
          },
        ),
        const SizedBox(height: 7),
        if (_tabController.index == 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: _selectedFormKey != null
                ? _getFormById(_selectedFormKey)
                : _FoodSafetySelectView(
                    onSelectItem: (formKey) {
                      _selectedFormKey = formKey;
                      setState(() {});
                    },
                  ),
          ),
        if (_tabController.index == 1) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: _selectedFormId != null
                ? _getReportFormById(_selectedFormKeyReport)
                : _showResponseList
                    ? ShedeinFoodsafetyDashboardHistoryView(
                        userController: widget.userController,
                        settingsController: widget.settingsController,
                        formKey: _selectedFormKeyReport,
                        onBack: () {
                          _showResponseList = false;
                          setState(() {});
                        },
                        onSelectItem: (id) {
                          _selectedFormId = id;
                          setState(() {});
                        },
                      )
                    : _FoodSafetySelectView(
                        onSelectItem: (formKey) {
                          _selectedFormKeyReport = formKey;
                          _showResponseList = true;
                          setState(() {});
                        },
                      ),
          ),
        ],
      ],
    );
  }

  Widget _getFormById(String? formKey) {
    switch (formKey) {
      case svaFormKey:
        return FoodSafetySvaFormView(
          userController: widget.userController,
          settingsController: widget.settingsController,
          onBack: () {
            _selectedFormKey = null;
            setState(() {});
          },
          afterSentForm: () {
            _selectedFormKey = null;
            setState(() {});
          },
        );
      case supplierPerformanceFormKey:
        return FoodSafetyPerformanceFormView(
          userController: widget.userController,
          settingsController: widget.settingsController,
          onBack: () {
            _selectedFormKey = null;
            setState(() {});
          },
          afterSentForm: () {
            _selectedFormKey = null;
            setState(() {});
          },
        );
      default:
        return Container();
    }
  }

  Widget _getReportFormById(String? formKey) {
    switch (formKey) {
      case svaFormKey:
        return FoodSafetySvaFormView(
          userController: widget.userController,
          settingsController: widget.settingsController,
          formId: _selectedFormId,
          onBack: () {
            _selectedFormId = null;
            setState(() {});
          },
        );
      case supplierPerformanceFormKey:
        return FoodSafetyPerformanceFormView(
          userController: widget.userController,
          settingsController: widget.settingsController,
          formId: _selectedFormId,
          onBack: () {
            _selectedFormId = null;
            setState(() {});
          },
        );
      default:
        return Container();
    }
  }
}

class _FoodSafetySelectView extends StatefulWidget {
  const _FoodSafetySelectView({
    this.onSelectItem,
  });

  final Function(String formKey)? onSelectItem;
  @override
  State<_FoodSafetySelectView> createState() => _FoodSafetySelectViewState();
}

class _FoodSafetySelectViewState extends State<_FoodSafetySelectView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.dashboardMenuShedeinFoodSafety,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth - 28;
                final colCount = math.max((width / 350).round(), 1).toInt();

                return GridView.builder(
                  itemCount: foodsafetyFormOrder.length,
                  shrinkWrap: true,
                  primary: false,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: colCount,
                    mainAxisExtent: 75,
                  ),
                  itemBuilder: (context, index) {
                    return GridFormItemComponent(
                      leadColor: Colors.amber,
                      text: translateFormKeyLong(
                          context, foodsafetyFormOrder[index]),
                      onSelectItem: () {
                        widget.onSelectItem?.call(foodsafetyFormOrder[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
