import 'package:email_validator/email_validator.dart';
import 'package:vservesafe/src/models/user_data.dart';

class VserveEditAdminUserData {
  late VserveUserData editedData;
  bool needEditPassword = false;
  String newPassword = "";
  String newPasswordConfirm = "";

  VserveEditAdminUserData(VserveUserData original) {
    editedData = original.clone();
  }

  bool get isUsernameValid => EmailValidator.validate(editedData.username);
  bool get isNewPasswordValid => newPassword.length >= 6;
  bool get isNewPasswordConfirmValid => newPassword == newPasswordConfirm;

  bool get isFormValid {
    final changePwValid = needEditPassword
        ? (isNewPasswordValid && isNewPasswordConfirmValid)
        : true;

    return isUsernameValid && changePwValid;
  }

  Map<String, dynamic> toApiData({bool? withId = false}) {
    return {
      if (withId == true) "id": editedData.id,
      "active": editedData.active,
      "role": editedData.role,
      "actualName": editedData.actualName,
      "username": editedData.username,
      "contractEmail": editedData.contractEmail,
      "note": editedData.note,
      "needEditPassword": needEditPassword,
      if (needEditPassword) ...{
        "newPassword": newPassword,
        "newPasswordConfirm": newPasswordConfirm,
      },
    };
  }
}
