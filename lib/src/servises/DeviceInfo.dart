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
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo = await DeviceInfoPlugin().androidInfo;

        if (androidDeviceInfo.manufacturer.toLowerCase() == 'samsung') {
          name = '${androidDeviceInfo.manufacturer[0].toUpperCase()}${androidDeviceInfo.manufacturer.substring(1).toLowerCase()} ${androidDeviceInfo.model}';
        }else {
          name = androidDeviceInfo.model;
        }
      } else if (Platform.isIOS) {
        name = (await DeviceInfoPlugin().iosInfo).utsname.machine;
      } else if (Platform.isMacOS) {
        name = (await DeviceInfoPlugin().macOsInfo).model;
      } else if (Platform.isLinux) {
        name = (await DeviceInfoPlugin().linuxInfo).prettyName;
      } else {
        name = Platform.localHostname;
      }
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
        } else if (platform.contains('linux')) {
          return DevicePlatform.linux;
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
    } else if (Platform.isLinux) {
      return DevicePlatform.linux;
    }
    return DevicePlatform.other;
  }

}