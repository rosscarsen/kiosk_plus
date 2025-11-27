import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get/get.dart' hide Response, MultipartFile, FormData;
import 'package:hive_ce/hive.dart';

import '../config.dart';
import '../model/login/login_data_model.dart';
import '../routes/app_pages.dart';
import '../translations/locale_keys.dart';
import '../utils/aes_gcm_crypto.dart';
import '../utils/logger.dart';
import 'dio_api_result.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  late final Dio _dio;
  // 错误代码常量
  static const int _loginInvalidCode = 10001;
  // 错误消息
  static String get _serviceError => LocaleKeys.serviceError.tr;
  static String get _dataException => LocaleKeys.dataException.tr;
  static String get _unknownError => LocaleKeys.unknownError.tr;
  static String get _connectionTimeout => LocaleKeys.connectionTimeout.tr;
  static String get _receiveTimeout => LocaleKeys.receiveTimeout.tr;
  static String get _loginInvalid => LocaleKeys.loginInvalid.tr;

  ApiClient._internal() {
    final baseOptions = BaseOptions(
      baseUrl: Config.baseurl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.plain,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 60),
      validateStatus: (status) => status != null,
    );

    _dio = Dio(baseOptions);
    // ⚠️ 忽略 HTTPS 证书验证（仅在 Release 模式启用）
    if (const bool.fromEnvironment('dart.vm.product')) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          return true;
        };
        return client;
      };
    }
    // 添加日志拦截器
    /*  _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    ); */
    // 添加认证拦截器
    _dio.interceptors.add(AuthInterceptor());

    // 添加日志拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (const bool.fromEnvironment("dart.vm.product")) {
            return handler.next(options);
          }
          logger.d(
            '原始请求信息: ${["method:${options.method}", "uri:${options.uri}", "queryParameters:${options.queryParameters}", "data:${options.data}", "headers:${options.headers}", "contentType:${options.contentType}", "responseType:${options.responseType}"]}',
          );
          return handler.next(options);
        },
      ),
    );
  }

  // POST请求
  Future<DioApiResult> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        onSendProgress: onSendProgress,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // GET请求
  Future<DioApiResult> get(String path, {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      final finalQuery = {...?queryParameters};
      if (data is Map<String, dynamic>) {
        finalQuery.addAll(data);
      }
      final response = await _dio.get(path, queryParameters: finalQuery);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // 处理响应
  DioApiResult _handleResponse(Response response) {
    final statusCode = response.statusCode;
    if (statusCode != 200) {
      return DioApiResult(success: false, error: 'HTTP $statusCode ${response.statusMessage}');
    }

    final responseData = response.data;

    final String dataJson = responseData?.toString() ?? '';

    if (dataJson.isEmpty || dataJson == 'null' || dataJson == '[]') {
      return DioApiResult(success: false, error: _dataException);
    }

    try {
      final decoded = jsonDecode(dataJson);
      if (decoded is Map<String, dynamic>) {
        final Map<String, dynamic> dataMap = Map.from(decoded);

        if (dataMap.containsKey('apiResult') &&
            dataMap['apiResult'] is List &&
            (dataMap['apiResult'] as List).isEmpty) {
          dataMap['apiResult'] = null;
        }
        return DioApiResult(success: true, data: jsonEncode(dataMap));
      }
      return DioApiResult(success: true, data: dataJson);
    } catch (err) {
      return DioApiResult(success: false, error: _dataException);
    }
  }

  // 处理错误
  DioApiResult _handleError(Object e) {
    if (e is DioException) {
      if (e.response?.statusCode == _loginInvalidCode) {
        Get.offAllNamed(Routes.LOGIN);
        return DioApiResult(success: false, error: _loginInvalid);
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        return DioApiResult(success: false, error: _connectionTimeout);
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        return DioApiResult(success: false, error: _receiveTimeout);
      }
      return DioApiResult(success: false, error: e.error?.toString() ?? _unknownError);
    } else {
      return DioApiResult(
        success: false,
        error: e is DioException ? e.error?.toString() ?? _unknownError : _serviceError,
      );
    }
  }
}

// 认证拦截器
class AuthInterceptor extends Interceptor {
  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (Get.currentRoute == Routes.LOGIN) {
      return handler.next(options);
    }
    final box = IsolatedHive.box(Config.kioskHiveBox);
    final loginInfo = await box.get(Config.loginData) as LoginDataModel?;
    if (loginInfo == null && loginInfo?.company == null && loginInfo?.dsn == null) {
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: ApiClient._loginInvalidCode),
          message: LocaleKeys.loginInvalid.tr,
          type: DioExceptionType.badResponse,
        ),
      );
    }
    final String plaintext = jsonEncode(loginInfo?.toJson());
    final encryptedData = await AesGcmCrypto.encrypt(plaintext);
    final String encryptedString = base64Encode(utf8.encode(jsonEncode(encryptedData)));

    options.headers.addAll({"Authorization": "Bearer $encryptedString"});
    return handler.next(options);
  }
}
