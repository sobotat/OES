
import 'package:oes/src/restApi/api/http/DioRequest.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'HttpRequestOptions.dart';

abstract class HttpRequest {

  static HttpRequest instance = DioRequest();

  Future<RequestResult> get(String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    HttpRequestOptions? options,
  });

  Future<RequestResult> post(String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    HttpRequestOptions? options,
    Function(double progress)? onReceiveProgress,
    Function(double progress)? onSendProgress,
  });

  Future<RequestResult> put(String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    HttpRequestOptions? options
  });

  Future<RequestResult> patch(String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    HttpRequestOptions? options
  });

  Future<RequestResult> delete(String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    HttpRequestOptions? options
  });

  void close();
}