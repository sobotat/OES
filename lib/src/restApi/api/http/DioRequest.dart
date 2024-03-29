
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oes/config/AppRouter.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:dio/dio.dart';

class DioRequest extends HttpRequest {

  Dio? _dio;
  Timer? _timer;

  Dio _getDio() {
    if (_dio == null) {
      _dio = Dio();
      debugPrint('✅ Client Connection opened');
    }

    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    _timer = Timer(const Duration(seconds: 10), () {
      close();
      _timer = null;
      debugPrint('⛔ Client Connection closed');
    });
    return _dio!;
  }

  RequestResult _getResultFromResponse(Response response) {
    return RequestResult(
      headers: response.headers.map,
      statusCode: response.statusCode,
      message: response.statusMessage,
      data: response.data,
      isRedirect: response.isRedirect
    );
  }

  Options? _getOptionsFromHttpRequestOptions(HttpRequestOptions? options) {
    return options == null ? Options(
      receiveDataWhenStatusError: true,
      validateStatus: (status) => true,
    ) : Options(
      contentType: options.contentType,
      responseType: options.responseType != null ? ResponseType.values[options.responseType!.index] : null,
      extra: options.extra,
      followRedirects: options.followRedirects,
      headers: options.headers,
      maxRedirects: options.maxRedirects,
      method: options.method,
      persistentConnection: options.persistentConnection,
      sendTimeout: options.sendTimeout,
      receiveTimeout: options.receiveTimeout,
      receiveDataWhenStatusError: true,
      validateStatus: (status) => true,
    );
  }

  Future<Response<dynamic>> _onError(error, stackTrace) {
    if(error is DioException) {
      if (error.response != null) {
        RequestResult result = _getResultFromResponse(error.response!);
        debugPrint("⭕ API Request Failed: ${result.statusCode} - ${result.message}");
        return Future(() => error.response!,);
      } else {
        debugPrint("⭕ Failed to get RequestResult from API");
        // AppRouter.instance.router.goNamed('no-api');
        //throw error;
        return Future(() => Response(requestOptions: RequestOptions(), statusCode: 500, statusMessage: error.message));
      }
    }
    AppRouter.instance.router.goNamed('no-api');
    throw error!;
  }

  @override
  Future<RequestResult> get(String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    HttpRequestOptions? options,
    Function(double progress)? onReceiveProgress,
  }) async {
    Response response = await _getDio().get(url,
      data: data,
      queryParameters: queryParameters,
      options: _getOptionsFromHttpRequestOptions(options),
      onReceiveProgress: onReceiveProgress != null ? (count, total) {
        onReceiveProgress(count / total);
      } : null,
    ).onError(_onError);

    return _getResultFromResponse(response);
  }

  @override
  Future<RequestResult> post(String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    HttpRequestOptions? options,
    Function(double progress)? onReceiveProgress,
    Function(double progress)? onSendProgress,
  }) async {

    Response response = await _getDio().post(url,
      data: data,
      queryParameters: queryParameters,
      options: _getOptionsFromHttpRequestOptions(options),
      onReceiveProgress: onReceiveProgress != null ? (count, total) {
        onReceiveProgress(count / total);
      } : null,
      onSendProgress: onSendProgress != null ? (count, total) {
        onSendProgress(count / total);
      } : null,
    ).onError(_onError);

    return _getResultFromResponse(response);
  }

  @override
  Future<RequestResult> put(String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    HttpRequestOptions? options
  }) async {

    Response response = await _getDio().put(url,
        data: data,
        queryParameters: queryParameters,
        options: _getOptionsFromHttpRequestOptions(options)
    ).onError(_onError);

    return _getResultFromResponse(response);
  }

  @override
  Future<RequestResult> patch(String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    HttpRequestOptions? options,
  }) async {

    Response response = await _getDio().patch(url,
        data: data,
        queryParameters: queryParameters,
        options: _getOptionsFromHttpRequestOptions(options)
    ).onError(_onError);

    return _getResultFromResponse(response);
  }

  @override
  Future<RequestResult> delete(String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    HttpRequestOptions? options
  }) async {

    Response response = await _getDio().delete(url,
        data: data,
        queryParameters: queryParameters,
        options: _getOptionsFromHttpRequestOptions(options)
    ).onError(_onError);

    return _getResultFromResponse(response);
  }

  @override
  void close() {
    if (_dio != null) {
      _dio!.close();
      _dio = null;
    }
  }
}