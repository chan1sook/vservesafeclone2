import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vservesafe/src/models/user_data.dart';
import 'package:vservesafe/src/services/api_service.dart';

class UserController with ChangeNotifier {
  UserController();

  VserveUserData? _userData;
  VserveUserData? get userData => _userData;

  final ApiService _apiService = ApiService();

  Future<void> updateUserData(VserveUserData? userData) async {
    _userData = userData;

    notifyListeners();
  }

  Future<VserveUserData?> getUserServer() => _apiService.getUserServer();
}
