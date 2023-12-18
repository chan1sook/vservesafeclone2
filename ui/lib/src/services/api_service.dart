import 'dart:developer' as developer;
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:vservesafe/src/models/site_data.dart';
import 'package:vservesafe/src/models/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

// const _mobileLocalUrlPath = "http://192.168.1.8:3061";
const _mobileLocalUrlPath = "http://vservesafe.sensesiot.net/api";

class ApiService {
  static const String baseUrlPath = kDebugMode
      ? (kIsWeb ? "http://localhost:3061" : _mobileLocalUrlPath)
      : "http://vservesafe.sensesiot.net/api";
  static const String socketIoPath = kDebugMode
      ? (kIsWeb ? "http://localhost:3061" : _mobileLocalUrlPath)
      : "http://vservesafe.sensesiot.net/api";

  static final dio = Dio(BaseOptions(
    extra: {
      "withCredentials": true,
    },
  ));

  static const String _selectedSite = "selected_site";

  ApiService() {
    if (!kIsWeb) {
      _registerCookieJar();
    }
  }

  Future<void> _registerCookieJar() async {
    Directory tempDir = await getTemporaryDirectory();

    final cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage(tempDir.path),
    );

    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<VserveUserData?> getUserServer() async {
    try {
      final result = await dio.get("${ApiService.baseUrlPath}/user");
      developer.log(result.toString(), name: "API Get User");

      if (result.data is Map<String, dynamic>) {
        final userData = (result.data as Map<String, dynamic>)["userData"];

        if (userData is Map<String, dynamic>) {
          if (userData["role"] != "guest") {
            developer.log(result.toString(), name: "API Get User");
            return VserveUserData.parseFromRawData(userData);
          }
        }
      }
    } catch (err) {
      developer.log(err.toString(), name: "API Get User");
    }

    return null;
  }

  Future<String?> selectedSiteId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("$_selectedSite.$userId");
  }

  Future<void> updateSelectedSiteId(
      String? userId, String? selectedSiteId) async {
    if (selectedSiteId == null || userId == null) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("$_selectedSite.$userId", selectedSiteId);
  }

  Future<List<VserveSiteData>> getAvaliableSitesServer() async {
    try {
      final result = await dio.get("${ApiService.baseUrlPath}/sites/available");
      developer.log(result.toString(), name: "API Get Avaliable Sites");

      List<VserveSiteData> newSites = [];

      if (result.data is Map<String, dynamic>) {
        final sitesData = result.data["sites"] as List<dynamic>;

        for (final ele in sitesData) {
          if (ele is Map<String, dynamic>) {
            newSites.add(VserveSiteData.parseFromRawData(ele));
          }
        }
      }
      return newSites;
    } catch (err) {
      developer.log(err.toString(), name: "API Get Avaliable Sites");
    }

    return [];
  }
}
