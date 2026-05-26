import 'dart:async';
import 'package:dio/dio.dart';
import '../../config/ai_chat_config.dart';

enum DioHttpMethod {
  get("GET"),
  post("POST"),
  put("PUT"),
  delete("DELETE"),
  patch("PATCH");

  const DioHttpMethod(this.value);
  final String value;
}

class EndpointType {
  EndpointType({
    this.path,
    this.httpMethod,
    this.parameters,
    this.header = const {},
    this.parameterList,
    this.responseType,
  });

  final String? path;
  final DioHttpMethod? httpMethod;
  final Map<String, dynamic>? parameters;
  final List<Map<String, dynamic>>? parameterList;
  final Map<String, String> header;
  final ResponseType? responseType;
}

class DefaultHeader {
  DefaultHeader._();
  static final DefaultHeader instance = DefaultHeader._();

  Map<String, String> get defaultHeader {
    Map<String, String> header = <String, String>{};
    header["content-type"] = "application/json";
    return header;
  }

  Map<String, String> get emptyHeader {
    Map<String, String> header = <String, String>{};
    return header;
  }
}

class BaseResponse {
  final String? message;
  final dynamic data;
  final bool isSuccess;
  final int? status;
  final Headers? headers;

  const BaseResponse({
    this.message,
    this.data,
    this.isSuccess = false,
    this.status,
    this.headers,
  });

  factory BaseResponse.fromSuccessJson(
    dynamic json,
    int status,
    Headers header,
  ) {
    return BaseResponse(
      isSuccess: true,
      data: json,
      status: status,
      headers: header,
    );
  }

  factory BaseResponse.fromErrorJson(Map<dynamic, dynamic> json, int? status) {
    String message = "";
    if (json.containsKey("errors")) {
      final errors = json["errors"];
      if (errors is Map) {
        final base = errors['base'];
        if (base != null) {
          if (base is List) {
            message = '${base.first}';
          } else {
            message = '$base';
          }
        }
        final messageJson = errors['message'];
        if (messageJson != null) {
          if (messageJson is List) {
            message = '${messageJson.first}';
          } else {
            message = '$messageJson';
          }
        }
      } else if (errors is List) {
        message = '${errors.firstOrNull}';
      } else {
        message = '$errors';
      }
    }
    if (json.containsKey("error")) {
      message = json["error"];
    }
    if (message.isEmpty && json.containsKey("message")) {
      final messageJson = json["message"];
      if (messageJson is List) {
        message = '${messageJson.firstOrNull}';
      } else {
        message = '$messageJson';
      }
    }
    return BaseResponse(
      isSuccess: false,
      message: message,
      status: status,
    );
  }
}

class BaseModel<T> {
  final bool? isSuccess;
  final String? message;
  final T? data;
  final dynamic otherData;
  final int? pageCount;
  final int? status;
  final int? totalItem;

  bool get isAccessDenied {
    return status == 400000;
  }

  const BaseModel({
    this.isSuccess,
    this.message,
    this.data,
    this.otherData,
    this.pageCount,
    this.status,
    this.totalItem,
  });
}

abstract class RestfulRequest {
  Future<BaseResponse> requestData(
    EndpointType endpoint, {
    CancelToken? cancelToken,
  });

  Future<String?> get token;
  Future<bool> refreshToken();
}

class RestfulRequestImplement extends RestfulRequest {
  final String url;
  late Dio _dio;

  RestfulRequestImplement({
    required this.url,
  }) {
    _dio = Dio();
    _dio.options.baseUrl = url;
    _dio.options.receiveTimeout = const Duration(seconds: 25);
    _dio.options.connectTimeout = const Duration(seconds: 25);
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final headers = options.headers;
        if (AIChatConfig.getTokenCallback != null) {
          final tokenStr = await AIChatConfig.getTokenCallback!();
          if (tokenStr != null) {
            headers["Authorization"] = 'Bearer $tokenStr';
          }
        }
        if (!headers.containsKey("Accept")) {
          headers["Accept"] = "application/json, text/plain, */*";
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        if (response.statusCode == 401) {
          if (AIChatConfig.refreshTokenCallback != null) {
            final success = await AIChatConfig.refreshTokenCallback!();
            if (success) {
              final newRes = await _retry(response.requestOptions);
              return handler.resolve(newRes);
            }
          }
        }
        return handler.next(response);
      },
      onError: (err, handler) async {
        if (err.response?.statusCode == 401) {
          if (AIChatConfig.refreshTokenCallback != null) {
            final success = await AIChatConfig.refreshTokenCallback!();
            if (success) {
              try {
                final newRes = await _retry(err.requestOptions);
                return handler.resolve(newRes);
              } catch (e) {
                return handler.next(err);
              }
            }
          }
        }
        return handler.next(err);
      },
    ));
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    if (AIChatConfig.getTokenCallback != null) {
      final tokenStr = await AIChatConfig.getTokenCallback!();
      if (tokenStr != null) {
        options.headers?["Authorization"] = 'Bearer $tokenStr';
      }
    }
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  @override
  Future<BaseResponse> requestData(
    EndpointType endpoint, {
    CancelToken? cancelToken,
  }) async {
    try {
      final options = Options(
        headers: endpoint.header,
        method: endpoint.httpMethod!.value,
        responseType: endpoint.responseType,
        validateStatus: (status) {
          if (status == null) return false;
          return status <= 500;
        },
      );
      Response response;
      if (endpoint.httpMethod == DioHttpMethod.get) {
        response = await _dio.request(
          endpoint.path!,
          queryParameters: endpoint.parameters,
          cancelToken: cancelToken,
          options: options,
        );
      } else {
        response = await _dio.request(
          endpoint.path!,
          data: endpoint.parameterList ?? endpoint.parameters,
          options: options,
        );
      }
      final json = response.data;
      int statusCode = response.statusCode!;
      if (json == null || json == "") {
        return const BaseResponse();
      }
      if (statusCode >= 200 && statusCode < 300) {
        if (json is Map && json.containsKey('code')) {
          final code = json['code'];
          if (code == 40000000) {
            return BaseResponse.fromErrorJson(json, code);
          }
        }
        return BaseResponse.fromSuccessJson(
          json,
          200,
          response.headers,
        );
      }
      return BaseResponse.fromErrorJson(json, statusCode);
    } catch (ex) {
      if (ex is DioException) {
        if (ex.type == DioExceptionType.receiveTimeout ||
            ex.type == DioExceptionType.connectionTimeout) {
          return BaseResponse.fromErrorJson(
            {'error': 'Quá thời gian kết nối vui lòng thử lại!'},
            ex.response?.statusCode,
          );
        }
      }
      return BaseResponse.fromErrorJson(
        {'error': 'Hệ thống đang gặp vấn đề vui lòng thử lại!'},
        500,
      );
    }
  }

  @override
  Future<String?> get token async {
    if (AIChatConfig.getTokenCallback != null) {
      return await AIChatConfig.getTokenCallback!();
    }
    return null;
  }

  @override
  Future<bool> refreshToken() async {
    if (AIChatConfig.refreshTokenCallback != null) {
      return await AIChatConfig.refreshTokenCallback!();
    }
    return false;
  }
}
