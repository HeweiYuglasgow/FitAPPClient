import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/api_response.dart';

/// HTTP Service
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  late final Dio _dio;
  String? _authToken;

  /// Initialize HTTP service
  Future<void> init() async {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: AppConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(_RequestInterceptor());
    _dio.interceptors.add(_ResponseInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
    
    // Load stored token
    await _loadAuthToken();
  }

  /// Load auth token
  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(AppConstants.tokenKey);
    if (_authToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_authToken';
    }
  }

  /// Set auth token
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
    
    // Store locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  /// Clear auth token
  Future<void> clearAuthToken() async {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
    
    // Delete from local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Auth-specific POST request that can get complete response data
  Future<Map<String, dynamic>?> postForAuth(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(path, queryParameters: queryParameters);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Handle response
  ApiResponse<T> _handleResponse<T>(Response response, T Function(dynamic)? fromJson) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        T? parsedData;
        if (fromJson != null && data['data'] != null) {
          parsedData = fromJson(data['data']);
        }
        
        return ApiResponse<T>.success(
          data: parsedData,
          message: data['message'] as String?,
        );
      } else {
        return ApiResponse<T>.success(data: fromJson != null ? fromJson(data) : null);
      }
    } else {
      return ApiResponse<T>.error(message: 'Request failed');
    }
  }

  /// Handle error
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiResponse<T>.error(message: 'Network timeout, please retry');
        case DioExceptionType.connectionError:
          return ApiResponse<T>.error(message: AppConstants.networkErrorMessage);
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          
          if (statusCode == 401) {
            // Clear invalid token
            clearAuthToken();
            
            // Check if there is specific error information
            String message = AppConstants.authErrorMessage;
            if (data is Map<String, dynamic>) {
              // Prioritize checking detail field (FastAPI default format)
              if (data['detail'] != null) {
                message = data['detail'] as String;
              } else if (data['message'] != null) {
                message = data['message'] as String;
              }
            }
            return ApiResponse<T>.error(message: message);
          } else if (statusCode != null && statusCode >= 400 && statusCode < 500) {
            String message = AppConstants.validationErrorMessage;
            if (data is Map<String, dynamic>) {
              // Prioritize checking detail field (FastAPI default format)
              if (data['detail'] != null) {
                message = data['detail'] as String;
              } else if (data['message'] != null) {
                message = data['message'] as String;
              } else if (data['error'] is Map<String, dynamic> &&
                         data['error']['message'] != null) {
                message = data['error']['message'] as String;
              }
            }
            return ApiResponse<T>.error(message: message);
          } else if (statusCode != null && statusCode >= 500) {
            return ApiResponse<T>.error(message: AppConstants.serverErrorMessage);
          } else {
            return ApiResponse<T>.error(message: AppConstants.unknownErrorMessage);
          }
        case DioExceptionType.cancel:
          return ApiResponse<T>.error(message: 'Request cancelled');
        default:
          return ApiResponse<T>.error(message: AppConstants.unknownErrorMessage);
      }
    } else {
      return ApiResponse<T>.error(message: AppConstants.unknownErrorMessage);
    }
  }

  /// Check network connection
  Future<bool> checkNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}

/// Request Interceptor
class _RequestInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Can add common parameters, print request logs, etc.
    print('Request: ${options.method} ${options.uri}');
    if (options.data != null) {
      print('Request data: ${options.data}');
    }
    handler.next(options);
  }
}

/// Response Interceptor
class _ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Can handle response data, print response logs, etc.
    print('Response: ${response.statusCode} ${response.requestOptions.uri}');
    print('Response Body: ${response.data}');
    handler.next(response);
  }
}

/// Error Interceptor
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Can handle errors uniformly, print error logs, etc.
    print('Error: ${err.message}');
    if (err.response != null) {
      print('Error response: ${err.response?.statusCode} ${err.response?.data}');
    }
    handler.next(err);
  }
}