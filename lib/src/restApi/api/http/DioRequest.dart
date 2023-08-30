
import 'dart:async';
import 'package:flutter/material.dart';
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
    return options == null ? null : Options(
      contentType: options.contentType,
      extra: options.extra,
      followRedirects: options.followRedirects,
      headers: options.headers,
      maxRedirects: options.maxRedirects,
      method: options.method,
      persistentConnection: options.persistentConnection,
      sendTimeout: options.sendTimeout,
      receiveTimeout: options.receiveTimeout,
      receiveDataWhenStatusError: true,
      validateStatus: options.validateStatus,
    );
  }

  @override
  Future<RequestResult> get(String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    HttpRequestOptions? options
  }) async {

    Response response = await _getDio().get(url,
      data: data,
      queryParameters: queryParameters,
      options: _getOptionsFromHttpRequestOptions(options),
    );

    return _getResultFromResponse(response);
  }

  @override
  Future<RequestResult> post(String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    HttpRequestOptions? options
  }) async {

    Response response = await _getDio().post(url,
      data: data,
      queryParameters: queryParameters,
      options: _getOptionsFromHttpRequestOptions(options)
    );

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
    );

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
    );

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
    );

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