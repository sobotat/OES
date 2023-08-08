import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NetworkChecker extends ChangeNotifier {

  static final NetworkChecker instance = NetworkChecker();
  final Connectivity _connectivity = Connectivity();
  bool haveInternet = false;
  bool isInit = false;

  void init(){
    _connectivity.onConnectivityChanged.listen((event) {
      checkConnection();
    });
    isInit = true;
  }

  Future<bool> checkConnection() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();

    debugPrint('Network [$result]');
    switch (result) {
      case ConnectivityResult.mobile:
        haveInternet = true;
      case ConnectivityResult.wifi:
        haveInternet = true;
      case ConnectivityResult.ethernet:
        haveInternet = true;
      default:
        haveInternet = false;
    }

    notifyListeners();
    return haveInternet;
  }
}