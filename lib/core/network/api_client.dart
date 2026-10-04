import 'package:dio/dio.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;
  String? authToken;
  final String baseUrl = "http://localhost:8000/api/v1";

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
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
