import 'dart:developer' as developer;

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:vservesafe/src/models/user_data.dart';

class ApiService {
  static const String baseUrlPath =
      kDebugMode ? "http://localhost:3061" : "http://34.143.230.243/api";
  static const String socketIoPath =
      kDebugMode ? "http://localhost:3061" : "http://34.143.230.243/api";
  static final cookieJar = kIsWeb ? CookieJar() : PersistCookieJar();
  static final dio = Dio(BaseOptions(
    extra: {
      "withCredentials": true,
    },
  ));

  ApiService() {
    if (!kIsWeb) {
      dio.interceptors.add(CookieManager(cookieJar));
    }
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
}
