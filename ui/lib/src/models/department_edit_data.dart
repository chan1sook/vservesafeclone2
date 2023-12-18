import 'package:image_picker/image_picker.dart';
import 'package:vservesafe/src/models/department_data.dart';

class VserveEditDepartmentData {
  late VserveDepartmentData editedData;
  XFile? newLogoImage;

  VserveEditDepartmentData(VserveDepartmentData original) {
    editedData = original.clone();
  }

  bool get isNameValid => editedData.name.isNotEmpty;
  bool get isLocationsValid =>
      editedData.locations.any((element) => element.isNotEmpty);
  bool get isFormValid => isNameValid;

  Map<String, dynamic> toApiData(String siteId, {bool? withId = false}) {
    return {
      if (withId == true) "id": editedData.id,
      "siteId": siteId,
      "active": editedData.active,
      "name": editedData.name,
      "logoUrl": editedData.logoUrl,
      "contractEmail": editedData.contractEmail,
      "phoneNumber": editedData.phoneNumber,
      "locations": editedData.locations,
      "note": editedData.note,
    };
  }
}
