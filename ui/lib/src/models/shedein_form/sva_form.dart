import 'package:file_picker/file_picker.dart';
import 'package:vservesafe/src/services/api_service.dart';

enum FoodsafetySvaRiskLevel { C, M, MI }

enum FoodsafetySvaComplicantLevel { complicant, nonComplicant }

const String svaFormKey = "foodsafety-sva-form";

class FoodSafetySvaItem {
  String key;
  String? thText;
  String? enText;
  FoodsafetySvaRiskLevel risklevel;
  FoodsafetySvaComplicantLevel? complicantLevel;
  int deductionScore = 0;
  String evidence = "";
  String filePath = "";
  PlatformFile? fileEvidence;

  FoodSafetySvaItem({
    this.key = "",
    this.thText,
    this.enText,
    this.risklevel = FoodsafetySvaRiskLevel.C,
  });

  int get baseScore {
    switch (risklevel) {
      case FoodsafetySvaRiskLevel.C:
        return 5;
      case FoodsafetySvaRiskLevel.M:
        return 3;
      case FoodsafetySvaRiskLevel.MI:
        return 1;
    }
  }

  String getTranslatedText(String tag) {
    if (tag.startsWith("en")) {
      return enText ?? key;
    }
    if (tag.startsWith("th")) {
      return thText ?? key;
    }
    return key;
  }

  bool get isFormValid {
    switch (complicantLevel) {
      case FoodsafetySvaComplicantLevel.complicant:
        return true;
      case FoodsafetySvaComplicantLevel.nonComplicant:
        return evidence.isNotEmpty;
      case null:
      default:
        return false;
    }
  }

  bool get isNonComplicant {
    return complicantLevel == FoodsafetySvaComplicantLevel.nonComplicant;
  }

  String get serverFileUrl {
    if (filePath.isEmpty) {
      return "";
    }

    final url = Uri.tryParse(filePath);
    if (url != null && !url.isAbsolute) {
      // is relative
      return "${ApiService.baseUrlPath}/$filePath";
    }

    return filePath;
  }

  Map<String, dynamic> toApiData() {
    return {
      "questionId": key,
      "baseScore": baseScore,
      "complicant": complicantLevel == FoodsafetySvaComplicantLevel.complicant,
      "deduction": deductionScore,
      "evidence": evidence,
      "filePath": filePath,
    };
  }

  void applyAnswerFromRawData(Map<String, dynamic> answer) {
    complicantLevel = answer["complicant"] == true
        ? FoodsafetySvaComplicantLevel.complicant
        : FoodsafetySvaComplicantLevel.nonComplicant;
    deductionScore = answer["deduction"];
    evidence = answer["evidence"];
    filePath = answer["filePath"];
  }
}

class FoodSafetySvaItemGroup {
  String key;
  String? thText;
  String? enText;
  List<FoodSafetySvaItem> items = [];

  FoodSafetySvaItemGroup({
    this.key = "",
    this.thText,
    this.enText,
    List<FoodSafetySvaItem>? items,
  }) {
    if (items != null) {
      this.items = items;
    }
  }

  int get totalBaseScore {
    int score = 0;
    for (final item in items) {
      score += item.baseScore;
    }
    return score;
  }

  int get totalDeductionScore {
    int score = 0;
    for (final item in items) {
      score += item.deductionScore;
    }
    return score;
  }

  bool get isFormValid {
    for (final item in items) {
      if (!item.isFormValid) {
        return false;
      }
    }
    return true;
  }

  String getTranslatedText(String tag) {
    if (tag.startsWith("en")) {
      return enText ?? key;
    }
    if (tag.startsWith("th")) {
      return thText ?? key;
    }
    return key;
  }

  List<Map<String, dynamic>> toApiListData() {
    List<Map<String, dynamic>> result = [];
    for (final item in items) {
      result.add(item.toApiData());
    }
    return result;
  }
}

List<FoodSafetySvaItemGroup> generateSvaformItemGroups() {
  return [
    FoodSafetySvaItemGroup(
      key: "supplierApproval",
      enText: "Supplier Approval",
      thText: "การประเมินผู้ขาย",
      items: [
        FoodSafetySvaItem(
          key: "supplierApprovalDocumented",
          enText:
              "Delivery temperatures and corrective actions are documented/maintained at the facility",
          thText:
              "อุณหภูมิในการขนส่งและการแก้ไขต่างๆ มีการเก็บรักษา/มีเอกสารอยู่ที่พื้นที่การปฏิบัติงาน",
          risklevel: FoodsafetySvaRiskLevel.C,
        ),
        FoodSafetySvaItem(
          key: "supplierApprovalAudit",
          enText: "Supplier Audit / Evaluation process are established",
          thText: "ขั้นตอนในการตรวจสอบ/ประเมินผู้ขาย",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "receivingFood",
      enText: "Receiving of Food",
      thText: "การรับอาหาร",
      items: [
        FoodSafetySvaItem(
          key: "receivingFoodTempAvailable",
          enText: "Temperature logs are available, record has done correctly.",
          thText: "มีบันทึกอุณหภูมิและบันทึกได้อย่างถูกต้อง",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "receivingFoodProper",
          enText: "Food received at proper temperatures, proper packaging.",
          thText:
              "มีการรับอาหารที่อุณภูมิที่เหมาะสม และบรรจุภัณ์ของอาหารมีสภาพที่เหมาะสม",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "receivingFoodCleanliness",
          enText: "Area / Equipment cleanliness",
          thText: "พื้นที่/อุปกรณ์มีความสะอาด",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "receivingFoodGoodCondition",
          enText: "Area / Equipment condition",
          thText: "พื้นที่/อุปกรณ์อยู่ในสภาพที่ดี",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "receivingFoodKnowledge",
          enText: "Supervisor/ Staff Knowledge",
          thText: "หัวหน้างาน/พนักงานมีความรู้ความเข้าใจ",
          risklevel: FoodsafetySvaRiskLevel.C,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "foodStorage",
      enText: "Food Storage",
      thText: "การจัดเก็บอาหาร",
      items: [
        FoodSafetySvaItem(
          key: "foodStorageFifo",
          enText:
              "Were all foods in date and satisfactory FIFO /FEFO stock rotation system being used?",
          thText: "การจัดเก็บอาหารตาม FIFO/FEFO และมีระบบการหมุนเวียนสต๊อค",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "foodStorageCover",
          enText: "Are all foods covered?",
          thText: "อาหารทั้งหมดมีการปิดคลุมหรือไม่?",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "foodStorageDate",
          enText: "Are all foods dated?",
          thText: "อาหารมีการระบุ/ติดฉลาก?",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "foodStorageCooling",
          enText: "Are all cool units operating at the correct temperature?",
          thText: "ตู้เย็นมีอุณหภูมิที่เหมาะสม/ถูกต้อง",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "foodStorageExpired",
          enText: "Is there any expired food?",
          thText: "ไม่มีอาหารที่หมดอายุ",
          risklevel: FoodsafetySvaRiskLevel.C,
        ),
        FoodSafetySvaItem(
          key: "foodStorageContainers",
          enText: "Are food storage containers in good condition?",
          thText: "จัดเก็บอาหารในภาชนะที่มีสภาพที่เหมาะสม",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "personalHygiene",
      enText: "Personal Hygiene and Habits",
      thText: "สุขลักษณะส่วนบุคคลและพฤติกรรม",
      items: [
        FoodSafetySvaItem(
          key: "personalHygieneHealth",
          enText: "Food handlers in the hotel are in good health",
          thText: "พนักงานที่ต้องสัมผัสอาหารมีสุขภาพที่ดี",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "personalHygieneHat",
          enText: "Proper hair restraints worn in food service area",
          thText: "มีหมวกสำหรับคลุมผมไว้ในพื้นที่ที่ให้บริการด้านอาหาร",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "personalHygieneNoDrug",
          enText:
              "In food service area is free from gum, smoking, drinking or tobacco",
          thText:
              "พื้นที่ให้บริการอาหารต้องไม่พบการเคี่ยวหมากฝรั่ง, การสูบบุหรี่, การกิน ดื่ม หรือพบบุหรี่ในพื้นที่",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "personalHygieneHandWashing",
          enText: "Proper Hand washing procedures",
          thText: "มีขั้นตอนการล้างมือที่ถูกต้อง",
          risklevel: FoodsafetySvaRiskLevel.C,
        ),
        FoodSafetySvaItem(
          key: "personalHygieneHandSinks",
          enText: "Hand washing sinks are accessible and useable",
          thText: "มีอ่างล้างมือและพร้อมใช้งาน",
          risklevel: FoodsafetySvaRiskLevel.C,
        ),
        FoodSafetySvaItem(
          key: "personalHygieneGloves",
          enText:
              "When gloves are required, food handlers avoid touching ready-to-eat foods with bare hands",
          thText:
              "มีการสวมใส่ถุงมือ และผู้สัมผัสอาการต้องไม่สัมผัสอาหารที่พร้อมทานด้วยมือเปล่า",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "usingThermometer",
      enText: "Using and Calibration of Probe Thermometer",
      thText: " การใช้งานและสอบเทียบเทอร์โมมิเตอร์",
      items: [
        FoodSafetySvaItem(
          key: "usingThermometerCalibrated",
          enText:
              "Accurate and calibrated thermometer available, enough for staff.",
          thText:
              "เทอร์โมมิเตอร์มีความแม่นยำและถูกสอบเทียบมีพร้อมใช้งาน และเพียงพอ",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "usingThermometerMaintained",
          enText:
              "Accurate and calibrated thermometer does not maintained in good condition.",
          thText:
              "เทอร์โมมิเตอร์ต้องมีความเที่ยงตรงและถูกสอบเทียบต้องจัดเก็บในสภาพที่เหมาะสม",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "dishwasher",
      enText: "Dishwasher and Glass washer Machine",
      thText: "เครื่องล้างแก้วล้างจาน",
      items: [
        FoodSafetySvaItem(
          key: "dishwasherTemp",
          enText:
              "Temp of final rinse for dishwashing machine is 82°C to 90°C (or ≥ 71°C at dishware surfaces)",
          thText:
              "อุณหภูมิของน้ำสุดท้ายของเครื่องล้างจานคือ 80 - 92 องศาเซลเซียส (หรือ มากกว่าเท่ากับ 71 องศาเซลเซียส ของพื้นผิวของอุปกรณ์ที่ถูกล้าง)",
          risklevel: FoodsafetySvaRiskLevel.C,
        ),
        FoodSafetySvaItem(
          key: "dishwasherMachine",
          enText:
              "Dishwasher / Glass washer Machine maintain in good condition.",
          thText: "เครื่องล้างแก้ว ล้างจานต้องอยู่ในสภาพที่ดี",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "labeling",
      enText: "Labeling of Food",
      thText: "การชี้บ่ง/ติดฉลากอาหาร",
      items: [
        FoodSafetySvaItem(
          key: "labelingCovered",
          enText: "All items must be covered and labeled with date",
          thText: "อาหารต้องมีการปิดคลุมและมีป้ายชี้บ่ง",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "labelingNoDefect",
          enText: "No out of date / expired / defect items stored",
          thText: "ต้องไม่พบอาหารที่หมดอายุในพื้นที่จัดเก็บ",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "labelingFifo",
          enText:
              "FIFO/FEFO being practiced in Chillers / Freezers / Stores / Display",
          thText:
              "ต้องมีการปฏิบัติตาม FIFO/FEFO สำหรับการจัดเก็บในตู้แช่เย็น, ตู้แช่แข็ง, สโตร์ และไลน์อาหาร",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "labelingChillTemp",
          enText:
              "Chiller Storage: Chiller temperature  ≤ 5°C(or not above ccp 8°C )*",
          thText:
              "การจัดเก็บแบบแช่เย็น อุรหภูมิต้องน้อยกว่า 5 องศาเซลเซียส (หรือต้องไม่เกินจุด CCP 8 องศาเซลเซียส)",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "labelingFreezeTemp",
          enText: "Freezer Storage: Freezer temperature ≤ -18°C (air temp)",
          thText:
              "การจัดเก็บแบบแช่แข็ง อุณหภูมิแช่แข็งต้อง น้อยกว่า -18 องศาเซลเซียส",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "labelingSpace",
          enText:
              "Chiller / Freezer / Dry store storage of food follows minimum space requirement as defined in policy.",
          thText:
              "ตู้แช่เย็น/ตู้แช่แข็ง/ห้องเก็บของแห้ง ต้องจัดเก็บตามโดยมีขนาดพื้นที่ว่างในการจัดเก็บตามนโยบายที่กำหนด",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "labelingContamination",
          enText: "Well maintained and no cross contamination risk",
          thText: "มีการบำรุงรักษาที่ดีต้องไม่เกิดการปนเปื้อนข้าม",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "labelingForm",
          enText:
              "Refrigerator & Freezer Temperature Form completes & sign off",
          thText: "แบบฟอร์มตู้แช่เย็นและตู้แช่แข็งมีการบันทึกและตรวจสอบ",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "thawing",
      enText: "Thawing of Foods",
      thText: "การทำละลายอาหาร",
      items: [
        FoodSafetySvaItem(
          key: "thawingChoice",
          enText:
              "Using correctly thawing methods (Running water, Chiller, Microwave or cooking)",
          thText:
              "ใช้วิธีในการทำละลายที่ถูกต้อง (น้ไหลผ่าน,ตู้แช่เย็น,ไมโครเวฟ หรือปรุงสุก)",
          risklevel: FoodsafetySvaRiskLevel.C,
        ),
        FoodSafetySvaItem(
          key: "thawingContamination",
          enText:
              "Well maintained and no cross contamination risk in the thawing process",
          thText:
              "ต้องมีการบำรุงรักษาที่ดี และไม่มีเกิดการปนเปื้อนข้ามระหว่างการทำละลาย",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "cooking",
      enText: "Cooking, Cooling of Hot Food and Reheating of Food",
      thText: "การปรุงสุก, การทำเย็น สำหรับอาหารร้อนและอาหารที่อุ่นร้อนซ้ำ",
      items: [
        FoodSafetySvaItem(
          key: "cookingTemp",
          enText:
              "Minimum Internal Cooking temperature for different food items follow as per policy.",
          thText:
              "อุณหภูมิต่ำสุดในการปรุงสุกของอาหารตัลประเภทแตกต่างกัน ต้องมีการดำเนินการตามนโยบายที่กำหนด",
          risklevel: FoodsafetySvaRiskLevel.C,
        ),
        FoodSafetySvaItem(
          key: "cookingContamination",
          enText: "No cross-contamination risk (food-food, food-others)",
          thText: "ต้องไม่เกิดการปนเปื้อนข้าม (อาหาร-อาหาร, อาหาร-สิ่งอื่นๆ)",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "cookingForm",
          enText:
              "Cooking, Cooling of Hot Food and Re-heating Temperature Form completes and sign off",
          thText:
              "มีการบันทึกอุรหภูมิในการปรุงสุก, การทำเย็นของอาหารร้อนและอาหารที่อุ่นร้อนซ้ำ",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "cookingClean",
          enText: "Holding equipment clean & well maintained",
          thText: "อุปกรณ์ต้องสะอาดและมีการบำรุงรักษาที่ดี",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "cookingChillMaintain",
          enText: "Cold Food temperature is ≤ 5°C during display",
          thText: "อุณหภูมิสำหรับอาหารเย็นควบคุมไว้ไม่เกิน 5 องศาเซลเซียส",
          risklevel: FoodsafetySvaRiskLevel.C,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "preparedFood",
      enText: "Hot Foods, Cold Foods and Food Preparation at Room Temperature",
      thText:
          "อาหารปรุงแบบร้อน, อาหารปรุงแบบเย็น และอาหารที่เตรียมในอุณหภูมิห้อง",
      items: [
        FoodSafetySvaItem(
          key: "preparedFoodServeTime",
          enText:
              "Plating (a la carte), Display (buffet / banquet), Transfer and Cold cut items are displayed less than 4 hours",
          thText:
              "อาหารจานด่วน, อาหารแบบบุฟเฟ่ต์,จัดเลี้ยง, การขนส่งและอาหารกลุ่มเนื้อตัดเย็น ต้องเสิร์ฟไม่เกิน 4 ชม.",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "preparedFoodMilkServeTime",
          enText: "Milk is placed at room temperature not exceed than 2 hrs.",
          thText: "นมต้องวางไว้ที่อุณหภูมิห้องไม่เกิน 2 ชม.",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "contamination",
      enText: "Prevention of Cross Contamination during Preparation of Foods",
      thText: "การป้องกันการปนเปื้อนข้ามระหว่างการจัดเตรียมอาหาร",
      items: [
        FoodSafetySvaItem(
          key: "contaminationPrepare",
          enText: "No cross-contamination risk (food-food, food-others)",
          thText: "ต้องไม่เกิดการปนเปื้อนข้าม (อาหาร-อาหาร, อาหาร-สิ่งอื่นๆ)",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "garbage",
      enText: "Storage and Removal of Garbage",
      thText: "การจัดเก็บและการขนย้ายขยะ",
      items: [
        FoodSafetySvaItem(
          key: "garbageContamination",
          enText: "No cross-contamination risk (food-food, food-others)",
          thText: "ต้องไม่เกิดการปนเปื้อนข้าม (อาหาร-อาหาร, อาหาร-สิ่งอื่นๆ)",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "garbageBins",
          enText: "Garbage Bins in kitchen covered and well maintained",
          thText: "ถังขยะในครัวต้องมีฝาปิดและมีการดูแลรักษาอย่างดี",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "chemical",
      enText: "Chemical Control",
      thText: "การควบคุมสารเคมี",
      items: [
        FoodSafetySvaItem(
          key: "chemicalStorage",
          enText: "Designated storage area available and properly labeled",
          thText: "สารเคมีจัดเก็บในพื้นที่ที่กำหนดและมีป้ายชี้บ่ง",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "chemicalApproved",
          enText: "Approved chemical used",
          thText: "ใช้สารเคมีที่ได้รับการอนุมัติแล้วเท่านั้น",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "chemicalMsds",
          enText: "MSDS available",
          thText: "มีเอกสาร MSDS",
          risklevel: FoodsafetySvaRiskLevel.C,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "sanitizingVegetables",
      enText: "Washing and Sanitizing of Fruits and Vegetables",
      thText: "การล้างทำความสะอาดผักและผลไม้",
      items: [
        FoodSafetySvaItem(
          key: "sanitizingVegetablesChanging",
          enText: "Daily changing of sanitizer solution",
          thText: "มีการเปลี่ยนน้ำยาฆ่าเชื้อประจำวัน",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "allergen",
      enText: "Allergen Control",
      thText: "การควบคุมสารก่อภูมิแพ้",
      items: [
        FoodSafetySvaItem(
          key: "allergenLabeling",
          enText:
              "The product has identified allergen contain in storage area.",
          thText:
              "สินค้าต้องมีป้ายชี้บ่งเรื่องสารก่อภูมิแพ้ และจัดเก็บในพื้นที่ที่กำหนด",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "visitorControl",
      enText: "Visitor Control",
      thText: "การควบคุมผู้เยี่ยมชม",
      items: [
        FoodSafetySvaItem(
          key: "visitorControlHygiene",
          enText: "Visitor adhere to proper personal hygiene and habit",
          thText: "ผู้เยี่ยมชมต้องมีสุขลักษณะส่วนบุคคลและพฤติกรรมที่เหมาะสม",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "sanitizing",
      enText: "Cleaning and Sanitizing",
      thText: "การทำความสะอาดและการฆ่าเชื้อ",
      items: [
        FoodSafetySvaItem(
          key: "sanitizingStation",
          enText: "Clean & in good working condition",
          thText: "พื้นที่ในการทำงานอยู่ใสภาพที่ดีและสะอาด",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "sanitizingProcedures",
          enText:
              "Pot washing done as per procedures of wash, rinse and sanitize",
          thText:
              "การทำความสะอาดตามขั้นตอนการทำความสะอาด การล้างและการฆ่าเชื้อ",
          risklevel: FoodsafetySvaRiskLevel.C,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "iceMachine",
      enText: "Ice Machine",
      thText: " เครื่องทำน้ำแข็ง",
      items: [
        FoodSafetySvaItem(
          key: "iceMachineSanitizer",
          enText: "Daily changing of sanitizer solution",
          thText: "มีการเปลี่ยนน้ำยาฆ่าเชื้อประจำวัน",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "iceMachineReport",
          enText: "Cleaning record available",
          thText: "มีรายงานการทำความสะอาด",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "training",
      enText: "Food Safety Training",
      thText: "การฝึกอบรม",
      items: [
        FoodSafetySvaItem(
          key: "trainingReport",
          enText: "Training records available",
          thText: "มีรายงานการฝึกอบรม",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "trainingRefresh",
          enText: "Refresher training Available",
          thText: "มีการฝึกอบรมทบทวน",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "handlersHealth",
      enText: "Health of Food Handlers",
      thText: "สุขภาพของผู้สัมผัสอาหาร",
      items: [
        FoodSafetySvaItem(
          key: "handlersHealthReport",
          enText:
              "Pre-employment, Medical check up, staff illness report policy are implemented.",
          thText:
              "มีรายงานผลการตรวจสุขภาพก่อนเริ่มงาน, ตรวจสุขภาพประจำปี และนโยบายในการรายงานกรณีพนักงานมีการบาดเจ็บ เจ็บป่วย",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "handlersHealthFirstAidKits",
          enText: "First aid kit is available & well stocked",
          thText: "มีชุดปฐมพยาบาลและมีการหมุนเวียนสต๊อค",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "handlersHealthPlaster",
          enText: "Blue water proof plaster available",
          thText: "มีพลาสเตอร์สีน้ำเงินกันน้ำ",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "preventiveMaintenance",
      enText: "Preventive Maintenance",
      thText: "การซ่อมบำรุงรักษา",
      items: [
        FoodSafetySvaItem(
          key: "preventiveMaintenancePlan",
          enText: "Preventive Maintenance Plan/Schedule is available",
          thText: "มีแผน/ตารางการซ่อมบำรุง",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "preventiveMaintenanceUtensils",
          enText:
              "Food equipment and utensils used are clean and well maintained",
          thText:
              "เครื่องมือและอุปกรณ์ใช้สำหรับอาหารสะอาดและมีการบำรุงรักษาที่ดี",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "preventiveMaintenanceWaters",
          enText: "Water & ice control. Laboratory analysis available.",
          thText: "มีผลการตรวจน้ำและนำแข็ง",
          risklevel: FoodsafetySvaRiskLevel.C,
        ),
      ],
    ),
    FoodSafetySvaItemGroup(
      key: "pestControl",
      enText: "Pest Control",
      thText: "การควบคุมสัตว์พาหะ",
      items: [
        FoodSafetySvaItem(
          key: "pestControlsShedule",
          enText: "Pest Control schedule & bait station layout is available",
          thText:
              "ตารางการควบคุมสัตว์พาหะและแผนผังการวางเหยื่อมีพร้อมให้ตรวจสอบ",
          risklevel: FoodsafetySvaRiskLevel.MI,
        ),
        FoodSafetySvaItem(
          key: "pestControlsEffective",
          enText: "Effective in eradication / control",
          thText: "ประสิทธิภาพในการกำจัดและควบคุม",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
        FoodSafetySvaItem(
          key: "pestControlsReports",
          enText: "Service reports and records are available",
          thText: "รายงานการให้บริการและบันทึกต่างๆ มีพร้อมให้ตรวจสอบ",
          risklevel: FoodsafetySvaRiskLevel.M,
        ),
      ],
    )
  ];
}
