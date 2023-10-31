import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:vservesafe/src/components/alert_component.dart';
import 'package:vservesafe/src/components/tabs_component.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/models/user_data.dart';
import 'package:vservesafe/src/models/user_edit_data.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/services/api_service.dart';

class ProfileDashboardView extends StatefulWidget {
  const ProfileDashboardView({
    super.key,
    required this.settingsController,
    required this.userController,
    this.startPageIndex,
  });

  final SettingsController settingsController;
  final UserController userController;
  final int? startPageIndex;

  static const routeName = '/profile';

  static const infomationPageIndex = 0;
  static const editProfilePageIndex = 1;

  @override
  State<ProfileDashboardView> createState() => _ProfileDashboardViewState();
}

class _ProfileDashboardViewState extends State<ProfileDashboardView> {
  int _tabIndex = 0;
  bool _isLoadingOpened = false;
  String? _progressText;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      ApiService.dio.interceptors.add(CookieManager(ApiService.cookieJar));
    }

    developer.log("${widget.startPageIndex}", name: "Route Args");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DefaultTabController(
                length: 2,
                initialIndex: widget.startPageIndex ?? 0,
                child: VserveTabBarComponent(
                  onTap: (index) {
                    _tabIndex = index;
                    setState(() {});
                  },
                  tabs: [
                    VserveHorizontalTabComponent(
                      icon: const Icon(Icons.info_outline),
                      label: Text(
                          AppLocalizations.of(context)!.profileTabInfomation),
                    ),
                    VserveHorizontalTabComponent(
                      icon: const FaIcon(FontAwesomeIcons.user),
                      label: Text(AppLocalizations.of(context)!.profileTabEdit),
                    ),
                  ],
                ),
              ),
              if (_tabIndex == 0)
                _ProfileInfoTabView(userController: widget.userController),
              if (_tabIndex == 1)
                _ProfileEditTabView(
                  userController: widget.userController,
                  onSubmitForm: _onSubmitForm,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmitForm(VserveEditProfileData editedUserData) async {
    _showLoadingDialog();

    final uploadAvatarProgressText =
        AppLocalizations.of(context)!.profileEditProgressUpdateAvatar;
    final editProfileProgressText =
        AppLocalizations.of(context)!.profileEditProgressUpdateProfile;

    try {
      if (editedUserData.newAvatarImage != null) {
        _progressText = uploadAvatarProgressText;
        setState(() {});
        final imagePath = await _uploadImage(editedUserData.newAvatarImage!);
        editedUserData.editedData.avatarUrl = imagePath;
      }

      _progressText = editProfileProgressText;
      setState(() {});

      await ApiService.dio.post(
        "${ApiService.baseUrlPath}/user/update",
        data: editedUserData.toApiData(),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await widget.userController.updateUserData(editedUserData.editedData);

      developer.log("Updated", name: "Update Profile");
      setState(() {});

      await _showUpdateProfileSuccessDialog();
    } catch (err) {
      developer.log(err.toString(), name: "Update Profile");

      if (_isLoadingOpened && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await _showUpdateProfileFailedDialog(err);
    }
  }

  Future<String> _uploadImage(XFile imageFile) async {
    late FormData formData;
    if (kIsWeb) {
      formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(await imageFile.readAsBytes(),
            filename: imageFile.path,
            contentType: imageFile.mimeType != null
                ? MediaType.parse(imageFile.mimeType!)
                : null),
      });
    } else {
      formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(imageFile.path),
      });
    }

    await widget.userController.getUserServer();

    final result = await ApiService.dio.post(
      "${ApiService.baseUrlPath}/avatar/update",
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
      ),
    );

    developer.log(result.data["path"], name: "Avatar Path");

    return result.data["path"];
  }

  Future<void> _showLoadingDialog() async {
    if (_isLoadingOpened) {
      return;
    }

    _isLoadingOpened = true;

    return showDialog<void>(
      context: context,
      barrierDismissible: SettingsController.isDebugMode,
      builder: (BuildContext context) {
        return LoadingAlertDialog(text: _progressText);
      },
    ).then((value) {
      _isLoadingOpened = false;
    });
  }

  Future<void> _showUpdateProfileFailedDialog(Object err) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.profileEditFailedTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    AppLocalizations.of(context)!.errorMessage(err.toString())),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUpdateProfileSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.profileEditSuccessfulTitle),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _ProfileEditTabView extends StatefulWidget {
  const _ProfileEditTabView({
    required this.userController,
    this.onSubmitForm,
  });

  final UserController userController;
  final Function(VserveEditProfileData)? onSubmitForm;

  @override
  State<_ProfileEditTabView> createState() => _ProfileEditTabViewState();
}

class _ProfileEditTabViewState extends State<_ProfileEditTabView> {
  final ImagePicker _imagePicker = ImagePicker();
  late VserveEditProfileData _editedUserData;
  final TextEditingController _accountNameTextFieldCtrl =
      TextEditingController();
  final TextEditingController _actualNameTextFieldCtrl =
      TextEditingController();
  final TextEditingController _contractEmailTextFieldCtrl =
      TextEditingController();
  final TextEditingController _phoneNumberTextFieldCtrl =
      TextEditingController();
  final TextEditingController _positionTextFieldCtrl = TextEditingController();
  final TextEditingController _addressTextFieldCtrl = TextEditingController();
  final TextEditingController _noteTextFieldCtrl = TextEditingController();

  bool _showChangePassword = false;

  @override
  void initState() {
    super.initState();
    _editedUserData = VserveEditProfileData(
        widget.userController.userData ?? VserveUserData());
    _accountNameTextFieldCtrl.text = _editedUserData.editedData.username;
    _actualNameTextFieldCtrl.text = _editedUserData.editedData.actualName;
    _contractEmailTextFieldCtrl.text = _editedUserData.editedData.contractEmail;
    _phoneNumberTextFieldCtrl.text = _editedUserData.editedData.phoneNumber;
    _positionTextFieldCtrl.text = _editedUserData.editedData.phoneNumber;
    _addressTextFieldCtrl.text = _editedUserData.editedData.address;
    _noteTextFieldCtrl.text = _editedUserData.editedData.note;
  }

  @override
  Widget build(BuildContext context) {
    const tablePadding = EdgeInsets.symmetric(horizontal: 14, vertical: 7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Table(
            columnWidths: const {0: IntrinsicColumnWidth()},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: const TableBorder(
              horizontalInside: BorderSide(color: Colors.black12),
              verticalInside: BorderSide(color: Colors.black12),
            ),
            children: [
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(
                        AppLocalizations.of(context)!.profileEditAvatarTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 7,
                      spacing: 7,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: _editedUserData.newAvatarImage != null
                              ? CircleAvatar(
                                  backgroundImage: XFileImage(
                                      _editedUserData.newAvatarImage!),
                                )
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(_editedUserData
                                      .editedData.serverAvatarUrl),
                                ),
                        ),
                        OutlinedButton(
                          onPressed: _pickImage,
                          child: Text(AppLocalizations.of(context)!
                              .profileEditChangeAvatarButton),
                        ),
                        if (_editedUserData.newAvatarImage != null)
                          OutlinedButton(
                            onPressed: _revertPickImage,
                            child: Text(AppLocalizations.of(context)!
                                .profileEditRevertAvatarButton),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(AppLocalizations.of(context)!
                        .profileEditChangePasswordTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              onPressed: _toggleResetPasswordPanel,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const FaIcon(FontAwesomeIcons.key, size: 14),
                                  const SizedBox(width: 7),
                                  Text(AppLocalizations.of(context)!
                                      .profileEditChangePasswordButton),
                                ],
                              ),
                            ),
                            if (_editedUserData.needEditPassword) ...[
                              const SizedBox(width: 14),
                              OutlinedButton(
                                onPressed: _clearChangePassword,
                                child: Text(AppLocalizations.of(context)!
                                    .profileEditChangePasswordRevertButton),
                              ),
                            ],
                          ],
                        ),
                        if (_showChangePassword) ...[
                          const SizedBox(height: 14),
                          TextField(
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: AppLocalizations.of(context)!
                                  .profileEditOldPasswordTextFieldLabel,
                              border: const OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              _editedUserData.oldPassword = value;
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: AppLocalizations.of(context)!
                                  .profileEditNewPasswordTextFieldLabel,
                              hintText: AppLocalizations.of(context)!
                                  .profileEditNewPasswordTextFieldHint,
                              border: const OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              _editedUserData.newPassword = value;
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: AppLocalizations.of(context)!
                                  .profileEditNewPasswordConfirmTextFieldLabel,
                              hintText: AppLocalizations.of(context)!
                                  .profileEditNewPasswordConfirmTextFieldHint,
                              border: const OutlineInputBorder(),
                              errorText: _editedUserData
                                      .isNewPasswordConfirmValid
                                  ? null
                                  : AppLocalizations.of(context)!
                                      .profileEditNewPasswordConfirmInvalidText,
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              _editedUserData.newPasswordConfirm = value;
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: OutlinedButton(
                              onPressed: _applyChangePassword,
                              child: Text(AppLocalizations.of(context)!
                                  .profileEditChangePasswordButton),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(
                        AppLocalizations.of(context)!.profileEditUsernameTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: TextField(
                      controller: _accountNameTextFieldCtrl,
                      readOnly: true,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        isDense: true,
                        prefixIcon: Icon(FontAwesomeIcons.userCheck),
                        filled: true,
                        fillColor: Color(0x18000000),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(AppLocalizations.of(context)!
                        .profileEditActualNameTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: TextField(
                      controller: _actualNameTextFieldCtrl,
                      decoration: const InputDecoration(
                        isDense: true,
                        prefixIcon: Icon(FontAwesomeIcons.user),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        _editedUserData.editedData.actualName = value;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(AppLocalizations.of(context)!
                        .profileEditContractEmailTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: TextField(
                      controller: _contractEmailTextFieldCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        isDense: true,
                        prefixIcon: Icon(FontAwesomeIcons.envelope),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        _editedUserData.editedData.contractEmail = value;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(
                        AppLocalizations.of(context)!.profileEditPhoneTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: TextField(
                      controller: _phoneNumberTextFieldCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        isDense: true,
                        prefixIcon: Icon(FontAwesomeIcons.phone),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        _editedUserData.editedData.phoneNumber = value;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(
                        AppLocalizations.of(context)!.profileEditPositionTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: TextField(
                      controller: _positionTextFieldCtrl,
                      decoration: const InputDecoration(
                        isDense: true,
                        prefixIcon: Icon(FontAwesomeIcons.suitcase),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        _editedUserData.editedData.position = value;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(
                        AppLocalizations.of(context)!.profileEditAddressTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: TextField(
                      controller: _addressTextFieldCtrl,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        isDense: true,
                        prefixIcon: Icon(FontAwesomeIcons.house),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _editedUserData.editedData.address = value;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(
                        AppLocalizations.of(context)!.profileEditNotesTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: TextField(
                      controller: _noteTextFieldCtrl,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        isDense: true,
                        prefixIcon: Icon(FontAwesomeIcons.noteSticky),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _editedUserData.editedData.note = value;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          Center(
            child: ElevatedButton(
              onPressed: _editedUserData.isFormValid
                  ? () {
                      widget.onSubmitForm?.call(_editedUserData);
                    }
                  : null,
              child: Text(AppLocalizations.of(context)!.profileEditSaveButton),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    _editedUserData.newAvatarImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  void _revertPickImage() {
    _editedUserData.newAvatarImage = null;
    setState(() {});
  }

  void _toggleResetPasswordPanel() {
    _showChangePassword = !_showChangePassword;
    setState(() {});
  }

  void _applyChangePassword() {
    _editedUserData.needEditPassword = true;
    _showChangePassword = false;
    setState(() {});
  }

  void _clearChangePassword() {
    _editedUserData.needEditPassword = false;
    _editedUserData.oldPassword = "";
    _editedUserData.newPassword = "";
    _editedUserData.newPasswordConfirm = "";
    setState(() {});
  }
}

class _ProfileInfoTabView extends StatelessWidget {
  const _ProfileInfoTabView({
    required this.userController,
  });

  final UserController userController;

  @override
  Widget build(BuildContext context) {
    const tablePadding = EdgeInsets.symmetric(horizontal: 14, vertical: 7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Table(
            columnWidths: const {0: IntrinsicColumnWidth()},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: const TableBorder(
              horizontalInside: BorderSide(color: Colors.black12),
              verticalInside: BorderSide(color: Colors.black12),
            ),
            children: [
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(
                        AppLocalizations.of(context)!.profileEditAvatarTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircleAvatar(
                            backgroundImage: userController.userData != null
                                ? NetworkImage(
                                    userController.userData!.serverAvatarUrl)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(
                        AppLocalizations.of(context)!.profileEditUsernameTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: Text(userController.userData?.username ?? ""),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(AppLocalizations.of(context)!
                        .profileEditActualNameTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: Text(userController.userData?.actualName ?? ""),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(AppLocalizations.of(context)!
                        .profileEditContractEmailTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: Text(userController.userData?.contractEmail ?? ""),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(
                        AppLocalizations.of(context)!.profileEditPhoneTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: Text(userController.userData?.phoneNumber ?? ""),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(
                        AppLocalizations.of(context)!.profileEditPositionTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: Text(userController.userData?.position ?? ""),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(
                        AppLocalizations.of(context)!.profileEditAddressTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: Text(userController.userData?.address ?? ""),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: tablePadding,
                    child: Text(
                        AppLocalizations.of(context)!.profileEditNotesTitle),
                  ),
                  Padding(
                    padding: tablePadding,
                    child: Text(userController.userData?.note ?? ""),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
