import 'package:vservesafe/src/services/api_service.dart';

class VserveUserData {
  String id = "";
  bool active = false;
  String username = "";
  String role = "user";
  String avatarUrl = "";
  String actualName = "";
  String contractEmail = "";
  String phoneNumber = "";
  String position = "";
  String address = "";
  String note = "";
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  VserveUserData({
    String? id,
    bool? active,
    String? username,
    String? role,
    String? avatarUrl,
    String? actualName,
    String? contractEmail,
    String? phoneNumber,
    String? position,
    String? address,
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
    if (username != null) {
      this.username = username;
    }
    if (role != null) {
      this.role = role;
    }
    if (avatarUrl != null) {
      this.avatarUrl = avatarUrl;
    }
    if (actualName != null) {
      this.actualName = actualName;
    }
    if (contractEmail != null) {
      this.contractEmail = contractEmail;
    }
    if (phoneNumber != null) {
      this.phoneNumber = phoneNumber;
    }
    if (position != null) {
      this.position = position;
    }
    if (address != null) {
      this.address = address;
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

  String get serverAvatarUrl {
    if (!hasAvatarImage) {
      return "${ApiService.baseUrlPath}/avatar/placeholder/256?u=$username";
    }

    final url = Uri.tryParse(avatarUrl);
    if (url != null && !url.isAbsolute) {
      // is relative
      return "${ApiService.baseUrlPath}/$avatarUrl";
    }

    return avatarUrl;
  }

  bool get hasAvatarImage => avatarUrl.isNotEmpty;

  static VserveUserData parseFromRawData(Map<String, dynamic> data) {
    final result = VserveUserData();
    if (data["_id"] is String) {
      result.id = data["_id"];
    }
    if (data["active"] is bool) {
      result.active = data["active"];
    }
    if (data["username"] is String) {
      result.username = data["username"];
    }
    if (data["role"] is String) {
      result.role = data["role"];
    }
    if (data["avatarUrl"] is String) {
      result.avatarUrl = data["avatarUrl"];
    }
    if (data["actualName"] is String) {
      result.actualName = data["actualName"];
    }
    if (data["contractEmail"] is String) {
      result.contractEmail = data["contractEmail"];
    }
    if (data["phoneNumber"] is String) {
      result.phoneNumber = data["phoneNumber"];
    }
    if (data["position"] is String) {
      result.position = data["position"];
    }
    if (data["address"] is String) {
      result.address = data["address"];
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

  VserveUserData clone() {
    return VserveUserData(
      id: id,
      active: active,
      username: username,
      role: role,
      avatarUrl: avatarUrl,
      actualName: actualName,
      contractEmail: contractEmail,
      phoneNumber: phoneNumber,
      position: position,
      address: address,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
