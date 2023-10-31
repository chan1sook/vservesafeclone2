import 'package:image_picker/image_picker.dart';
import 'package:vservesafe/src/models/user_data.dart';

class VserveEditProfileData {
  late VserveUserData editedData;
  XFile? newAvatarImage;
  bool needEditPassword = false;
  String oldPassword = "";
  String newPassword = "";
  String newPasswordConfirm = "";

  VserveEditProfileData(VserveUserData original) {
    editedData = original.clone();
  }

  bool get isNewPasswordValid => newPassword.length >= 6;
  bool get isNewPasswordConfirmValid => newPassword == newPasswordConfirm;

  bool get isFormValid {
    final changePwValid = needEditPassword
        ? (oldPassword.isNotEmpty &&
            isNewPasswordValid &&
            isNewPasswordConfirmValid)
        : true;
    return changePwValid;
  }

  Map<String, dynamic> toApiData() {
    return {
      "avatarUrl": editedData.avatarUrl,
      "actualName": editedData.actualName,
      "contractEmail": editedData.contractEmail,
      "phoneNumber": editedData.phoneNumber,
      "position": editedData.position,
      "address": editedData.address,
      "note": editedData.note,
      "needEditPassword": needEditPassword,
      if (needEditPassword) ...{
        "oldPassword": oldPassword,
        "newPassword": newPassword,
        "newPasswordConfirm": newPasswordConfirm,
      }
    };
  }
}
