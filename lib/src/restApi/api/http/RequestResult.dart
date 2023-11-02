

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

  bool checkUnauthorized() {
    return statusCode == 401;
  }

  bool checkOk() {
    if (statusCode == null) return false;
    return statusCode! >= 200 && statusCode! < 300;
  }
}