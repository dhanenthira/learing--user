import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;
  String? authToken;
  
  static String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:8000/api/v1";
    }
    return "http://192.168.1.108:8000/api/v1";
  }

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: getBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (authToken != null && authToken!.isNotEmpty) {
          options.headers["Authorization"] = "Bearer $authToken";
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Log network errors
        return handler.next(e);
      },
    ));
  }

  void setToken(String? token) {
    authToken = token;
  }
}
