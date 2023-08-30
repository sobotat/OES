import 'package:flutter/material.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';

class TestApi {

  static Future<List<String>> users() async {

    RequestResult result = await HttpRequest.instance.get("http://oes-api.sobotovi.net:8001/api/test/get");

    if (result.statusCode != 200) {
      debugPrint('Error Code ${result.statusCode}');
      return [];
    }

    if (result.data is! List<dynamic>) {
      debugPrint('Is not List of Users');
      return [];
    }

    List<String> out = [];
    for (Map user in result.data ?? []) {
      out.add(user['name']);
    }

    return out;
  }
}