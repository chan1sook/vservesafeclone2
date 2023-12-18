import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vservesafe/src/models/department_data.dart';
import 'package:vservesafe/src/models/shedein_form/supplier_perfomance_form.dart';
import 'package:vservesafe/src/models/shedein_form/sva_form.dart';

class VserveShedeinDepartmentData {
  VserveDepartmentData department;
  String? location;

  VserveShedeinDepartmentData({
    required this.department,
    this.location,
  });

  @override
  int get hashCode => Object.hash(department, location);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is VserveShedeinDepartmentData &&
        other.department == department &&
        other.location == location;
  }
}

class VserveShedeinResponseData {
  String id = "";
  String formKey = "";
  String answerBy = "";
  VserveShedeinDepartmentData? pair;
  DateTime answerDate = DateTime.now();
  DateTime createdAt = DateTime.now();

  bool get isValid {
    return pair != null;
  }

  VserveShedeinResponseData({
    String? id,
    String? formKey,
    String? answerBy,
    VserveShedeinDepartmentData? pair,
    DateTime? answerDate,
    DateTime? createdAt,
  }) {
    if (id != null) {
      this.id = id;
    }
    if (formKey != null) {
      this.formKey = formKey;
    }
    if (answerBy != null) {
      this.answerBy = answerBy;
    }
    if (pair != null) {
      this.pair = pair;
    }
    if (answerDate != null) {
      this.answerDate = answerDate;
    }
    if (createdAt != null) {
      this.createdAt = createdAt;
    }
  }

  static VserveShedeinResponseData parseFromRawData(
      Map<String, dynamic> data, List<VserveDepartmentData> departments) {
    final result = VserveShedeinResponseData();

    if (data["_id"] is String) {
      result.id = data["_id"];
    }
    if (data["formId"] is String) {
      result.formKey = data["formId"];
    }
    if (data["answerBy"] is String) {
      result.answerBy = data["answerBy"];
    }
    if (data["departmentId"] is String) {
      final target =
          departments.firstWhereOrNull((ele) => ele.id == data["departmentId"]);
      if (target != null) {
        final location = data["location"];
        result.pair = VserveShedeinDepartmentData(
            department: target, location: location is String ? location : null);
      }
    }
    if (data["answerDate"] is String) {
      result.answerDate = DateTime.parse(data["answerDate"]);
    }
    if (data["createdAt"] is String) {
      result.createdAt = DateTime.parse(data["createdAt"]);
    }
    return result;
  }

  Map<String, dynamic> toApiSvaData(List<FoodSafetySvaItemGroup> group,
      {String? siteId}) {
    List<Map<String, dynamic>> answers = [];
    for (final item in group) {
      answers.addAll(item.toApiListData());
    }

    return {
      "formId": formKey,
      if (siteId != null) "siteId": siteId,
      "departmentId": pair?.department.id,
      "location": pair?.location,
      "answerDate": answerDate.millisecondsSinceEpoch,
      "answers": answers,
    };
  }

  Map<String, dynamic> toApiPerfomanceSuplierData(
      List<FoodsafetyPerfomanceFormItem> items,
      {String? siteId}) {
    List<Map<String, dynamic>> answers = [];
    for (final item in items) {
      answers.add(item.toApiData());
    }

    return {
      "formId": formKey,
      if (siteId != null) "siteId": siteId,
      "departmentId": pair?.department.id,
      "location": pair?.location,
      "answerDate": answerDate.millisecondsSinceEpoch,
      "answers": answers,
    };
  }
}

const List<String> foodsafetyFormOrder = [
  svaFormKey,
  supplierPerformanceFormKey
];

String translateFormKeyLong(BuildContext context, String formKey) {
  switch (formKey) {
    case svaFormKey:
      return AppLocalizations.of(context)!.shedeinFoodSafetySvaTitle;
    case supplierPerformanceFormKey:
      return AppLocalizations.of(context)!
          .shedeinFoodSafetySupplierPerformanceReviewTitle;
    default:
      return formKey;
  }
}

String translateFormKeyShort(BuildContext context, String formKey) {
  switch (formKey) {
    case svaFormKey:
      return AppLocalizations.of(context)!.shedeinFoodSafetySvaShort;
    case supplierPerformanceFormKey:
      return AppLocalizations.of(context)!
          .shedeinFoodSafetySupplierPerformanceReviewShort;
    default:
      return formKey;
  }
}
