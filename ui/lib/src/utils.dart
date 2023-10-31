import 'package:dio/dio.dart';

InterceptorsWrapper getCookieInterceptor() {
  return InterceptorsWrapper(onRequest: (options, handler) async {
    options.extra["withCredentials"] = true;
    return handler.next(options);
  });
}
