import 'package:image_picker/image_picker.dart';
import 'package:vservesafe/src/models/site_data.dart';

class VserveEditSiteData {
  late VserveSiteData editedData;
  XFile? newLogoImage;

  VserveEditSiteData(VserveSiteData original) {
    editedData = original.clone();
  }

  bool get isNameValid => editedData.name.isNotEmpty;
  bool get isFormValid => isNameValid;

  Map<String, dynamic> toApiData({bool? withId = false}) {
    return {
      if (withId == true) "id": editedData.id,
      "active": editedData.active,
      "name": editedData.name,
      "logoUrl": editedData.logoUrl,
      "contractEmail": editedData.contractEmail,
      "phoneNumber": editedData.phoneNumber,
      // "admins": editedData.admins,
      "note": editedData.note,
    };
  }
}
