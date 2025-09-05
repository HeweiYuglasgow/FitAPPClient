import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// API响应基础模型
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final DateTime? timestamp;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  /// 成功响应
  factory ApiResponse.success({T? data, String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      timestamp: DateTime.now(),
    );
  }

  /// 错误响应
  factory ApiResponse.error({required String message, T? data}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      data: data,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, hasData: ${data != null})';
  }
}

/// 错误响应模型
@JsonSerializable()
class ErrorResponse {
  final bool success;
  final ErrorDetail error;
  final DateTime? timestamp;

  const ErrorResponse({
    required this.success,
    required this.error,
    this.timestamp,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}

/// 错误详情模型
@JsonSerializable()
class ErrorDetail {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const ErrorDetail({
    required this.code,
    required this.message,
    this.details,
  });

  factory ErrorDetail.fromJson(Map<String, dynamic> json) => _$ErrorDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorDetailToJson(this);
}

/// 分页响应模型
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> items;
  final Pagination pagination;

  const PaginatedResponse({
    required this.items,
    required this.pagination,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}

/// 分页信息模型
@JsonSerializable()
class Pagination {
  final int page;
  final int limit;
  final int total;
  final int pages;

  const Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);

  /// 是否有下一页
  bool get hasNext => page < pages;

  /// 是否有上一页
  bool get hasPrevious => page > 1;

  /// 下一页页码
  int? get nextPage => hasNext ? page + 1 : null;

  /// 上一页页码
  int? get previousPage => hasPrevious ? page - 1 : null;
}