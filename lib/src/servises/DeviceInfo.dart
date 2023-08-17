import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:oes/src/objects/DevicePlatform.dart';
import 'dart:io' show Platform;

class DeviceInfo {

  DeviceInfo({
    required this.name,
    required this.platform,
    required this.isWeb,
  });

  String name;
  DevicePlatform platform;
  bool isWeb;

  @override
  String toString() {
    return 'DeviceInfo{name: $name, platform: $platform, isWeb: $isWeb}';
  }

  static Future<DeviceInfo> getInfo() async {
    return DeviceInfo(
      name:  await _getName(),
      platform: await _getPlatform(),
      isWeb: kIsWeb,
    );
  }

  static Future<String> _getName() async {
    String name = 'Device';
    try{
      name = Platform.localHostname;
    } on UnsupportedError {
      if (kIsWeb) {
        name = (await DeviceInfoPlugin().webBrowserInfo).browserName.name;
        name = '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
      }else {
        throw UnsupportedError('Hostname is not supported on device');
      }
    }
    return name;
  }

  static Future<DevicePlatform> _getPlatform() async {
    if (kIsWeb) {
      var data = await DeviceInfoPlugin().webBrowserInfo;

      if (data.platform != null) {
        String platform = data.platform!.toLowerCase();
        if (platform.contains('android')){
          return DevicePlatform.android;
        } else if (platform.contains('iphone') || platform.contains('ipad')) {
          return DevicePlatform.ios;
        } else if (platform.contains('win')) {
          return DevicePlatform.windows;
        } else if (platform.contains('mac')) {
          return DevicePlatform.macos;
        }
      }
      return DevicePlatform.other;
    }

    if (Platform.isAndroid) {
      return DevicePlatform.android;
    } else if (Platform.isIOS) {
      return DevicePlatform.ios;
    } else if (Platform.isWindows) {
      return DevicePlatform.windows;
    } else if (Platform.isMacOS) {
      return DevicePlatform.macos;
    }
    return DevicePlatform.other;
  }

}