

class RequestResult {

  RequestResult({
    this.headers,
    this.statusCode,
    this.message,
    this.data,
    this.isRedirect = false,
  });

  Map<String, List<String>>? headers;
  int? statusCode;
  String? message;
  dynamic data;
  bool isRedirect;

}