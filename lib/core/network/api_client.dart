import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({required String baseUrl, List<Interceptor>? interceptors}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
        headers: _buildHeaders(),
      ),
    );

    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  Map<String, String> _buildHeaders() {
    if (kIsWeb) {
      // On web, use application/x-www-form-urlencoded to avoid CORS preflight
      // The API.yaml confirms the register endpoint accepts this Content-Type
      return {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };
    }
    // On mobile/desktop, use application/json
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  /// The underlying [Dio] instance. Exposed so the [AuthInterceptor] can
  /// replay queued requests (with a fresh token) after a successful refresh.
  Dio get dio => _dio;

  /// Attaches the [AuthInterceptor] to Dio so it can retry the original
  /// request through the same interceptor chain after a token refresh.
  void attachInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    debugPrint('BASE URL : ${_dio.options.baseUrl}');
    debugPrint('FULL URL : ${_dio.options.baseUrl}$path');
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) async {
    debugPrint('BASE URL : ${_dio.options.baseUrl}');
    debugPrint('FULL URL : ${_dio.options.baseUrl}$path');
    return await _dio.post(
      path,
      data: data,
      options: Options(
        connectTimeout: connectTimeout ?? _dio.options.connectTimeout,
        receiveTimeout: receiveTimeout ?? _dio.options.receiveTimeout,
      ),
    );
  }

  /// Like [post] but always sends `application/json` regardless of the global
  /// web header override. Use this for endpoints that require JSON bodies even
  /// on Flutter Web (e.g. password/forgot, password/reset, password/verify-otp).
  Future<Response> postJson(
    String path, {
    required Map<String, dynamic> data,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) async {
    debugPrint('BASE URL : ${_dio.options.baseUrl}');
    debugPrint('FULL URL : ${_dio.options.baseUrl}$path');
    return await _dio.post(
      path,
      data: data,
      options: Options(
        contentType: 'application/json',
        connectTimeout: connectTimeout ?? _dio.options.connectTimeout,
        receiveTimeout: receiveTimeout ?? _dio.options.receiveTimeout,
      ),
    );
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
