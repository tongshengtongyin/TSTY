// 封装dio
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:tsty_app/constants/index.dart';

class DioUtils {
  final Dio _dio = Dio();

  DioUtils() {
    _dio.options
      ..baseUrl = GlobalConstants.apiBaseUrl
      ..connectTimeout = GlobalConstants.timeoutDuration
      ..receiveTimeout = GlobalConstants.timeoutDuration;

    // 添加日志拦截器
    _addLogsInterceptor();

    // 添加通用拦截器
    _addInterceptors();
  }

  void _addLogsInterceptor() {
    // 仅在DEBUG模式添加接口日志拦截器，RELEASE模式移除
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true, // 打印请求头
          requestBody: true, // 打印请求参数
          responseBody: true, // 打印响应数据
          responseHeader: false, // 不打印响应头
          error: true, // 打印错误信息
          compact: false, // 格式化打印（非紧凑模式）
          maxWidth: 120, // 每行最大长度
        ),
      );
    }
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 在请求发送之前做一些处理
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 在响应到达之前做一些处理
          return handler.next(response);
        },
        onError: (error, handler) {
          // 在发生错误时做一些处理
          return handler.next(error);
        },
      ),
    );
  }

  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    return _handleRequest(
      await _dio.get(
        url,
        queryParameters: params,
        options: headers == null ? null : Options(headers: headers),
      ),
    );
  }

  Future<dynamic> post(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    return _handleRequest(
      await _dio.post(
        url,
        data: data,
        options: headers == null ? null : Options(headers: headers),
      ),
    );
  }

  Future<dynamic> _handleRequest(Response<dynamic> task) async {
    try {
      final result = task;
      final data = result.data;

      if (data is Map) {
        if (data.containsKey('code')) {
          final code = data['code'];
          final ok = code == GlobalConstants.successState ||
              code?.toString() == GlobalConstants.successState.toString();
          if (ok) {
            return data['data'];
          }
          throw Exception(data['message']?.toString() ?? '数据处理出错！');
        }
        return data;
      }

      return data;
    } catch (e) {
      throw Exception(e);
    }
  }
}

// 创建单例对象
final DioUtils dioUtils = DioUtils();
