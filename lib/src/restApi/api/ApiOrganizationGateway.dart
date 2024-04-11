
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/objects/Organization.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/restApi/interface/OrganizationGateway.dart';

class ApiOrganizationGateway implements OrganizationGateway {

  String basePath = '${AppApi.instance.mainServerUrl}/api/Organizations';

  @override
  Future<Organization?> get(String name) async {
    RequestResult result = await HttpRequest.instance.get('$basePath/$name');

    if (!result.checkOk() || result.data is! Map<String ,dynamic>) {
      debugPrint('Api Error: [Organization-get] ${result.statusCode} -> ${result.message}');
      return null;
    }

    return Organization.fromJson(result.data);
  }

  @override
  Future<List<Organization>> getAll(String filter) async {
    if (filter.isEmpty) return [];

    RequestResult result = await HttpRequest.instance.get(basePath,
      queryParameters: {
        "keyword": filter
      }
    );

    if (!result.checkOk() || result.data is! List<dynamic>) {
      debugPrint('Api Error: [Organization-getAll] ${result.statusCode} -> ${result.message}');
      return [];
    }

    List<Organization> out = [];
    for (Map<String, dynamic> json in result.data) {
      out.add(Organization.fromJson(json));
    }
    return out;
  }

}