
enum DevicePlatform {
  android, ios, windows, macos, other
}

class SignedDevice {

  SignedDevice({
    required this.name,
    required this.platform,
    required this.isWeb,
    required this.lastSignIn,
  });

  String name;
  DevicePlatform platform;
  bool isWeb;
  DateTime lastSignIn;
}