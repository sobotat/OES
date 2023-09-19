import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';

class TestApi {

  static Future<List<String>> users(int page, int count) async {

    RequestResult result = await HttpRequest.instance.get("${AppApi.instance.apiServerUrl}/api/test/get",
      queryParameters: {
        'page': page,
        'pageSize': count
      });

    if (result.statusCode != 200) {
      debugPrint('Error Code ${result.statusCode}');
      return [];
    }

    if (result.data is! Map<String, dynamic>) {
      debugPrint('Didnt get Json Object');
      return [];
    }

    List<dynamic> items = result.data['items'] ?? [];
    List<String> out = [];
    for (Map user in items) {
      out.add('${user['name']}');
    }

    return out;
  }
}