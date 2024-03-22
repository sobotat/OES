import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

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
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();

    bool haveInternet = false;
    for (ConnectivityResult result in results) {
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

      if (haveInternet) break;
    }

    this.haveInternet = haveInternet;
    notifyListeners();

    return haveInternet;
  }
}