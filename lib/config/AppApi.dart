import 'package:flutter/cupertino.dart';
import 'package:oes/src/objects/Organization.dart';
import 'package:oes/src/restApi/interface/OrganizationGateway.dart';
import 'package:oes/src/services/LocalStorage.dart';

class AppApi extends ChangeNotifier {

  static final AppApi instance = AppApi._();
  AppApi._();

  String mainServerUrl = 'http://oes-main.sobotovi.net:8002';
  String _apiServerUrl = '';
  Organization? organization;
  bool isInit = false;

  String get apiServerUrl => _apiServerUrl;
  set apiServerUrl(String value) {
    if(value[value.length - 1] == '/') {
      _apiServerUrl = value.substring(0, value.length - 1);
    } else {
      _apiServerUrl = value;
    }
  }

  Future<void> init() async {
    String? organizationName = await LocalStorage.instance.get("organization");
    if (organizationName == null) {
      isInit = true;
      notifyListeners();
      return;
    }

    Organization? organization = await OrganizationGateway.instance.get(organizationName);
    if (organization == null) {
      isInit = true;
      notifyListeners();
      return;
    }
    setOrganization(organization);
    isInit = true;
    notifyListeners();
  }

  Future<void> setOrganization(Organization organization) async {
    this.organization = organization;
    apiServerUrl = organization.url;
    await LocalStorage.instance.set("organization", organization.name);
  }

  bool haveApiUrl() {
    return apiServerUrl != '';
  }
}