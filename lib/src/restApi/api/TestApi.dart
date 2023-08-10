import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class TestApi {

  static Future<List<String>> users() async {
    Client client = Client();
    Response response;
    try {
      response = await client.get(Uri.parse('http://oes-api.sobotovi.net:8001/api/Test'));
    }
    finally {
      client.close();
    }

    if (response.statusCode != 200) return [];

    List<String> out = [];

    var decodedResponse = jsonDecode(response.body.toString()) as List;

    for (Map user in decodedResponse) {
      out.add(user['name']);
    }

    return out;
  }

  static Future<int?> number(int num) async {

    Client client = Client();
    Response response;
    try {
      response = await client.get(Uri.parse('http://oes-api.sobotovi.net:8001/WeatherForecast/thing2/$num'));
    }
    finally {
      client.close();
    }

    if (response.statusCode != 200) return null;
    return int.parse(response.body.toString());
  }

}