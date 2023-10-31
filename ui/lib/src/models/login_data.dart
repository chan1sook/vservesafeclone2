class VserveLoginData {
  String username = "";
  String password = "";
  bool rememberLogin = false;

  VserveLoginData({String? username, String? password, bool? rememberLogin}) {
    if (username != null) {
      this.username = username;
    }
    if (password != null) {
      this.password = password;
    }
    if (rememberLogin != null) {
      this.rememberLogin = rememberLogin;
    }
  }

  VserveLoginData clone() {
    return VserveLoginData(
      username: username,
      password: password,
      rememberLogin: rememberLogin,
    );
  }

  bool get isFormValid => username.isNotEmpty && password.isNotEmpty;

  Map<String, dynamic> toApiData() {
    return {
      "username": username,
      "password": password,
    };
  }
}
