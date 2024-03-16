
class HttpRequestOptions {

  HttpRequestOptions({
    this.method,
    this.sendTimeout,
    this.receiveTimeout,
    this.extra,
    this.headers,
    this.contentType,
    this.validateStatus,
    this.followRedirects,
    this.maxRedirects,
    this.persistentConnection,
    this.responseType
  });

  String? method;
  Duration? sendTimeout;
  Duration? receiveTimeout;
  Map<String, dynamic>? extra;
  Map<String, dynamic>? headers;
  String? contentType;
  bool Function(int?)? validateStatus;
  bool? followRedirects;
  int? maxRedirects;
  bool? persistentConnection;
  HttpResponseType? responseType;
}

class AuthHttpRequestOptions extends HttpRequestOptions {

  AuthHttpRequestOptions({
    required this.token,
    super.method,
    super.sendTimeout,
    super.receiveTimeout,
    super.extra,
    Map<String, dynamic>? headers,
    super.contentType,
    super.validateStatus,
    super.followRedirects,
    super.maxRedirects,
    super.persistentConnection,
    super.responseType
  }) {
    super.headers = {
      'Authorization': 'Bearer $token'
    };

    if (headers != null) {
      super.headers!.addAll(headers);
    }
  }

  String token;

}

enum HttpResponseType {
  json,
  stream,
  plain,
  bytes,
}