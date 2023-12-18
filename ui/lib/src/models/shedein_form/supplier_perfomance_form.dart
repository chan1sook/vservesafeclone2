import 'dart:math' as math;

const String supplierPerformanceFormKey =
    "foodsafety-supplier-performance-form";

class FoodsafetyPerfomanceFormItem {
  String supplier = "";
  String product = "";
  int qualityScore = 1;
  int deliveryScore = 1;
  int documentScore = 1;
  int responseScore = 1;
  DateTime reviewDate = DateTime.now();
  String reviewBy = "";
  String remark = "";

  FoodsafetyPerfomanceFormItem({
    String? supplier,
    String? product,
    int? qualityScore,
    int? deliveryScore,
    int? documentScore,
    int? responseScore,
    DateTime? reviewDate,
    String? reviewBy,
    String? remark,
  }) {
    if (supplier != null) {
      this.supplier = supplier;
    }
    if (product != null) {
      this.product = product;
    }
    if (qualityScore != null) {
      this.qualityScore = qualityScore;
    }
    if (deliveryScore != null) {
      this.deliveryScore = deliveryScore;
    }
    if (documentScore != null) {
      this.documentScore = documentScore;
    }
    if (responseScore != null) {
      this.responseScore = responseScore;
    }
    if (reviewDate != null) {
      this.reviewDate = reviewDate;
    }
    if (reviewBy != null) {
      this.reviewBy = reviewBy;
    }
    if (remark != null) {
      this.remark = remark;
    }
  }

  int get totalScore {
    int score = 0;
    score += math.min(math.max(qualityScore, 1), 5);
    score += math.min(math.max(deliveryScore, 1), 5);
    score += math.min(math.max(documentScore, 1), 5);
    score += math.min(math.max(responseScore, 1), 5);

    return score;
  }

  double get scorePercentage {
    return 5.0 * totalScore;
  }

  bool get isFormValid {
    return supplier.isNotEmpty && product.isNotEmpty;
  }

  Map<String, dynamic> toApiData() {
    return {
      "supplier": supplier,
      "product": product,
      "qualityScore": qualityScore,
      "deliveryScore": deliveryScore,
      "documentScore": documentScore,
      "responseScore": responseScore,
      "reviewDate": reviewDate.toIso8601String(),
      "reviewBy": reviewBy,
      "remark": remark,
    };
  }

  static FoodsafetyPerfomanceFormItem parseFromRawData(
      Map<String, dynamic> data) {
    final result = FoodsafetyPerfomanceFormItem();

    if (data["supplier"] is String) {
      result.supplier = data["supplier"];
    }
    if (data["product"] is String) {
      result.product = data["product"];
    }
    if (data["qualityScore"] is num) {
      result.qualityScore = int.tryParse("${data["qualityScore"]}") ?? 0;
    }
    if (data["deliveryScore"] is num) {
      result.deliveryScore = int.tryParse("${data["deliveryScore"]}") ?? 0;
    }
    if (data["documentScore"] is num) {
      result.documentScore = int.tryParse("${data["documentScore"]}") ?? 0;
    }
    if (data["responseScore"] is num) {
      result.responseScore = int.tryParse("${data["responseScore"]}") ?? 0;
    }
    if (data["reviewDate"] is String) {
      result.reviewDate = DateTime.parse(data["reviewDate"]);
    }
    if (data["reviewBy"] is String) {
      result.reviewBy = data["reviewBy"];
    }
    return result;
  }
}
