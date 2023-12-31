import 'package:vservesafe/src/services/api_service.dart';

class VserveDepartmentData {
  String id = "";
  bool active = false;
  String name = "";
  String logoUrl = "";
  String contractEmail = "";
  String phoneNumber = "";
  String note = "";
  List<String> locations = [];
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  VserveDepartmentData({
    String? id,
    bool? active,
    String? name,
    String? logoUrl,
    String? contractEmail,
    String? phoneNumber,
    String? note,
    List<String>? locations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    if (id != null) {
      this.id = id;
    }
    if (active != null) {
      this.active = active;
    }
    if (name != null) {
      this.name = name;
    }
    if (logoUrl != null) {
      this.logoUrl = logoUrl;
    }
    if (contractEmail != null) {
      this.contractEmail = contractEmail;
    }
    if (phoneNumber != null) {
      this.phoneNumber = phoneNumber;
    }
    if (locations != null) {
      this.locations = List.from(locations);
    }
    if (note != null) {
      this.note = note;
    }
    if (createdAt != null) {
      this.createdAt = createdAt;
    }
    if (updatedAt != null) {
      this.updatedAt = updatedAt;
    }
  }

  bool get hasLogoImage => logoUrl.isNotEmpty;

  String get serverLogoUrl {
    if (!hasLogoImage) {
      return "https://fakeimg.pl/256x256?text=LOGO";
    }

    final url = Uri.tryParse(logoUrl);
    if (url != null && !url.isAbsolute) {
      // is relative
      return "${ApiService.baseUrlPath}/$logoUrl";
    }

    return logoUrl;
  }

  VserveDepartmentData clone() {
    return VserveDepartmentData(
      id: id,
      active: active,
      name: name,
      logoUrl: logoUrl,
      contractEmail: contractEmail,
      phoneNumber: phoneNumber,
      note: note,
      locations: List.from(locations),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static VserveDepartmentData parseFromRawData(Map<String, dynamic> data) {
    final result = VserveDepartmentData();
    if (data["_id"] is String) {
      result.id = data["_id"];
    }
    if (data["active"] is bool) {
      result.active = data["active"];
    }
    if (data["name"] is String) {
      result.name = data["name"];
    }
    if (data["logoUrl"] is String) {
      result.logoUrl = data["logoUrl"];
    }
    if (data["contractEmail"] is String) {
      result.contractEmail = data["contractEmail"];
    }
    if (data["phoneNumber"] is String) {
      result.phoneNumber = data["phoneNumber"];
    }
    if (data["note"] is String) {
      result.note = data["note"];
    }
    if (data["locations"] is List) {
      List<String> locations = [];
      for (final ele in data["locations"]) {
        if (ele is String) {
          locations.add(ele);
        }
      }
      result.locations = locations;
    }
    if (data["createdAt"] is String) {
      result.createdAt = DateTime.parse(data["createdAt"]);
    }
    if (data["updatedAt"] is String) {
      result.updatedAt = DateTime.parse(data["updatedAt"]);
    }
    return result;
  }
}
