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
    this.persistentConnection
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
}