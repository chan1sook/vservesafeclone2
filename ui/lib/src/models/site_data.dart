import 'package:vservesafe/src/services/api_service.dart';

class VserveSiteData {
  String id = "";
  bool active = false;
  String name = "";
  String logoUrl = "";
  String contractEmail = "";
  String phoneNumber = "";
  String welcomeScreenEn = "";
  String welcomeScreenTh = "";
  String note = "";
  List<String> admins = [];
  List<String> managers = [];
  List<String> users = [];
  int managerUserCap = 10;
  int userUserCap = 100;
  bool isAdmin = false;
  bool isManager = false;
  bool isUser = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  VserveSiteData({
    String? id,
    bool? active,
    String? name,
    String? logoUrl,
    String? contractEmail,
    String? phoneNumber,
    List<String>? admins,
    List<String>? managers,
    List<String>? users,
    String? welcomeScreenEn,
    String? welcomeScreenTh,
    String? note,
    int? managerUserCap,
    int? userUserCap,
    bool? isAdmin,
    bool? isManager,
    bool? isUser,
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
    if (admins != null) {
      this.admins = List.from(admins);
    }
    if (managers != null) {
      this.managers = List.from(managers);
    }
    if (users != null) {
      this.users = List.from(users);
    }
    if (welcomeScreenEn != null) {
      this.welcomeScreenEn = welcomeScreenEn;
    }
    if (welcomeScreenTh != null) {
      this.welcomeScreenTh = welcomeScreenTh;
    }
    if (note != null) {
      this.note = note;
    }
    if (managerUserCap != null) {
      this.managerUserCap = managerUserCap;
    }
    if (userUserCap != null) {
      this.userUserCap = userUserCap;
    }
    if (isAdmin != null) {
      this.isAdmin = isAdmin;
    }
    if (isManager != null) {
      this.isManager = isManager;
    }
    if (isUser != null) {
      this.isUser = isUser;
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
      // return "${ApiService.baseUrlPath}/avatar/placeholder/256?u=$username";
      return "https://fakeimg.pl/256x256?text=LOGO";
    }

    final url = Uri.tryParse(logoUrl);
    if (url != null && !url.isAbsolute) {
      // is relative
      return "${ApiService.baseUrlPath}/$logoUrl";
    }

    return logoUrl;
  }

  VserveSiteData clone() {
    return VserveSiteData(
      id: id,
      active: active,
      name: name,
      logoUrl: logoUrl,
      contractEmail: contractEmail,
      phoneNumber: phoneNumber,
      welcomeScreenEn: welcomeScreenEn,
      welcomeScreenTh: welcomeScreenTh,
      note: note,
      admins: List.from(admins),
      managers: List.from(managers),
      users: List.from(users),
      managerUserCap: managerUserCap,
      userUserCap: userUserCap,
      isAdmin: isAdmin,
      isManager: isManager,
      isUser: isUser,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static VserveSiteData parseFromRawData(Map<String, dynamic> data) {
    final result = VserveSiteData();
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
    if (data["welcomeScreenEn"] is String) {
      result.welcomeScreenEn = data["welcomeScreenEn"];
    }
    if (data["welcomeScreenTh"] is String) {
      result.welcomeScreenTh = data["welcomeScreenTh"];
    }
    if (data["note"] is String) {
      result.note = data["note"];
    }
    if (data["admins"] is List) {
      List<String> admins = [];
      for (final ele in data["admins"]) {
        if (ele is String) {
          admins.add(ele);
        }
      }
      result.admins = admins;
    }
    if (data["managers"] is List) {
      List<String> managers = [];
      for (final ele in data["managers"]) {
        if (ele is String) {
          managers.add(ele);
        }
      }
      result.managers = managers;
    }
    if (data["users"] is List) {
      List<String> users = [];
      for (final ele in data["users"]) {
        if (ele is String) {
          users.add(ele);
        }
      }
      result.users = users;
    }
    if (data["managerUserCap"] is num) {
      result.managerUserCap = int.tryParse("${data["managerUserCap"]}") ?? 10;
    }
    if (data["userUserCap"] is num) {
      result.userUserCap = int.tryParse("${data["userUserCap"]}") ?? 100;
    }
    if (data["isAdmin"] is bool) {
      result.isAdmin = data["isAdmin"];
    }
    if (data["isManager"] is bool) {
      result.isManager = data["isManager"];
    }
    if (data["isUser"] is bool) {
      result.isUser = data["isUser"];
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
