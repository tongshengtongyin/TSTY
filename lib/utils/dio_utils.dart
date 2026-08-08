// 封装dio
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:tsty_app/api/auth.dart';
import 'package:tsty_app/constants/index.dart';
import 'package:tsty_app/routes/app_navigator.dart';
import 'package:tsty_app/utils/user_prefs.dart';

class DioUtils {
  final Dio _dio = Dio();

  Future<void>? _refreshFuture;

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
          requestHeader: true,
          // 打印请求头
          requestBody: true,
          // 打印请求参数
          responseBody: true,
          // 打印响应数据
          responseHeader: false,
          // 不打印响应头
          error: true,
          // 打印错误信息
          compact: false,
          // 格式化打印（非紧凑模式）
          maxWidth: 120, // 每行最大长度
        ),
      );
    }
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final path = options.path;
            final skipAuth =
                options.extra['skipAuth'] == true ||
                path.contains(HttpConstants.authRefresh) ||
                path.contains(HttpConstants.childLoginPassword);

            if (!skipAuth) {
              final headers = options.headers;
              final hasAuth =
                  headers['Authorization']?.toString().trim().isNotEmpty ==
                  true;

              if (!hasAuth) {
                final token = await UserPrefs.getAccessToken();
                final t = token?.trim() ?? '';
                if (t.isNotEmpty) {
                  headers['Authorization'] = 'Bearer $t';
                }
              }

              final shouldRefresh = await UserPrefs.isAccessTokenExpiringSoon();
              if (shouldRefresh) {
                await _refreshAccessTokenLocked();
                final newToken = await UserPrefs.getAccessToken();
                final t = newToken?.trim() ?? '';
                if (t.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $t';
                }
              }
            }
          } catch (_) {
            // ignore request-side refresh errors; response-side will handle auth codes
          }
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          final path = response.requestOptions.path;
          final skipAuth =
              response.requestOptions.extra['skipAuth'] == true ||
              path.contains(HttpConstants.authRefresh) ||
              path.contains(HttpConstants.childLoginPassword);

          final data = response.data;
          if (data is Map && data.containsKey('code')) {
            final code = data['code'];
            final intCode = (code is int)
                ? code
                : int.tryParse(code?.toString() ?? '');

            if (intCode != null && intCode != GlobalConstants.successState) {
              final message = data['message']?.toString() ?? '请求失败';

              if (!skipAuth &&
                  (intCode == 1002 || intCode == 1003) &&
                  response.requestOptions.extra['retried'] != true) {
                try {
                  await _refreshAccessTokenLocked();
                  final newToken = await UserPrefs.getAccessToken();
                  final t = newToken?.trim() ?? '';
                  if (t.isEmpty) throw Exception('未登录');

                  final opts = response.requestOptions;
                  opts.extra['retried'] = true;
                  opts.headers['Authorization'] = 'Bearer $t';

                  final retryResponse = await _dio.fetch(opts);
                  return handler.resolve(retryResponse);
                } catch (_) {
                  await _clearLoginAndRedirect();
                  return handler.reject(
                    DioException(
                      requestOptions: response.requestOptions,
                      error: message,
                      type: DioExceptionType.unknown,
                    ),
                  );
                }
              }

              if (intCode == 1001 || intCode == 1004 || intCode == 1005) {
                await _clearLoginAndRedirect();
              }

              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  error: message,
                  type: DioExceptionType.badResponse,
                ),
              );
            }
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          final opts = error.requestOptions;
          final path = opts.path;
          final skipAuth =
              opts.extra['skipAuth'] == true ||
              path.contains(HttpConstants.authRefresh) ||
              path.contains(HttpConstants.childLoginPassword);

          final status = error.response?.statusCode;
          if (!skipAuth && status == 401 && opts.extra['retried'] != true) {
            try {
              await _refreshAccessTokenLocked();
              final newToken = await UserPrefs.getAccessToken();
              final t = newToken?.trim() ?? '';
              if (t.isEmpty) throw Exception('未登录');

              opts.extra['retried'] = true;
              opts.headers['Authorization'] = 'Bearer $t';
              final retryResponse = await _dio.fetch(opts);
              return handler.resolve(retryResponse);
            } catch (_) {
              await _clearLoginAndRedirect();
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _refreshAccessTokenLocked() async {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    final fut = () async {
      try {
        final refreshToken = await UserPrefs.getRefreshToken();
        final rt = refreshToken?.trim() ?? '';
        if (rt.isEmpty) {
          throw Exception('refreshToken为空');
        }

        final deviceId = await UserPrefs.getOrCreateDeviceId();
        final resp = await refreshTokenAPI(
          refreshToken: rt,
          deviceId: deviceId,
        );

        final accessToken = resp['accessToken']?.toString() ?? '';
        final newRefreshToken = resp['refreshToken']?.toString() ?? '';
        final tokenExpiresIn = resp['tokenExpiresIn'];
        final expiresInSeconds = (tokenExpiresIn is int)
            ? tokenExpiresIn
            : int.tryParse(tokenExpiresIn?.toString() ?? '') ?? 0;
        if (accessToken.trim().isEmpty ||
            newRefreshToken.trim().isEmpty ||
            expiresInSeconds <= 0) {
          throw Exception('刷新Token失败：返回数据不完整');
        }

        await UserPrefs.setTokenBundle(
          accessToken: accessToken,
          refreshToken: newRefreshToken,
          tokenExpiresInSeconds: expiresInSeconds,
        );
        await UserPrefs.setLoggedIn(true);
      } catch (e) {
        await _clearLoginAndRedirect();
        rethrow;
      }
    }();

    _refreshFuture = fut;
    try {
      await fut;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<void> _clearLoginAndRedirect() async {
    await UserPrefs.setLoggedIn(false);
    await UserPrefs.clearAccessToken();
    await UserPrefs.clearRefreshToken();
    await UserPrefs.clearTokenMeta();
    await UserPrefs.clearChildProfile();

    final nav = appNavigatorKey.currentState;
    if (nav == null) return;
    nav.pushNamedAndRemoveUntil('/login', (route) => false);
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
    Options? options,
  }) async {
    return _handleRequest(
      await _dio.post(
        url,
        data: data,
        options:
            options ?? (headers == null ? null : Options(headers: headers)),
      ),
    );
  }

  Future<dynamic> put(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    return _handleRequest(
      await _dio.put(
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
          final ok =
              code == GlobalConstants.successState ||
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
