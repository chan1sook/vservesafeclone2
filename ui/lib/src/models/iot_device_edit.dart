import 'package:vservesafe/src/models/iot_device.dart';

class VserveEditIoTDeviceData {
  late VserveIoTDeviceData editedData;

  VserveEditIoTDeviceData(VserveIoTDeviceData original) {
    editedData = original.clone();
  }

  bool get isNameValid => editedData.name.isNotEmpty;
  bool get isMacAddressValid => editedData.macAddress.isNotEmpty;
  bool get isTypeValid => editedData.type.isNotEmpty;

  bool get isFormValid => isNameValid && isMacAddressValid && isTypeValid;

  Map<String, dynamic> toApiData(String siteId, {bool? withId = false}) {
    return {
      if (withId == true) "id": editedData.id,
      "active": editedData.active,
      "name": editedData.name,
      "macAddress": editedData.macAddress,
      "siteId": siteId,
      "type": editedData.type,
    };
  }
}
