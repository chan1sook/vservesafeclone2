class VserveIoTDeviceData {
  String id = "";
  bool active = false;
  String name = "";
  String macAddress = "";
  String type = "";
  String note = "";
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  VserveIoTDeviceData({
    String? id,
    bool? active,
    String? name,
    String? macAddress,
    String? type,
    String? note,
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
    if (macAddress != null) {
      this.macAddress = macAddress;
    }
    if (type != null) {
      this.type = type;
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

  VserveIoTDeviceData clone() {
    return VserveIoTDeviceData(
      id: id,
      active: active,
      name: name,
      macAddress: macAddress,
      type: type,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static VserveIoTDeviceData parseFromRawData(Map<String, dynamic> data) {
    final result = VserveIoTDeviceData();

    if (data["_id"] is String) {
      result.id = data["_id"];
    }
    if (data["active"] is bool) {
      result.active = data["active"];
    }
    if (data["name"] is String) {
      result.name = data["name"];
    }
    if (data["macAddress"] is String) {
      result.macAddress = data["macAddress"];
    }
    if (data["type"] is String) {
      result.type = data["type"];
    }
    if (data["note"] is String) {
      result.note = data["note"];
    }
    if (data["createdAt"] is String) {
      result.createdAt = DateTime.parse(data["createdAt"]);
    }
    if (data["updatedAt"] is String) {
      result.updatedAt = DateTime.parse(data["updatedAt"]);
    }
    return result;
  }

  static String normalizeMacAddress(String macAddress) {
    return macAddress.toUpperCase().replaceAll(":", "");
  }

  static List<String> defaultTypes = ["General", "Refrigerator"];
}
