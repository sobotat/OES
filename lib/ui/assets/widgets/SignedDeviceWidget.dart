import 'package:flutter/material.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/DevicePlatform.dart';
import 'package:oes/src/objects/SignedDevice.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class SignedDeviceWidget extends StatelessWidget {

  const SignedDeviceWidget({
    required this.device,
    super.key
  });

  final SignedDevice device;

  bool isCurrent() {
    return device.deviceToken == AppSecurity.instance.user!.token;
  }

  IconData getIcon() {
    if(device.isWeb) {
      return AppIcons.icon_web;
    }

    switch (device.platform) {
      case DevicePlatform.android:
        return AppIcons.icon_android;
      case DevicePlatform.ios:
        return AppIcons.icon_ios;
      case DevicePlatform.windows:
        return AppIcons.icon_windows;
      case DevicePlatform.macos:
        return AppIcons.icon_apple;
      case DevicePlatform.linux:
        return AppIcons.icon_linux;
      default:
        return AppIcons.icon_web;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.background
        ),
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                _Icon(
                  icon: getIcon(),
                  isCurrent: isCurrent(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: _Info(signedDevice: device),
                ),
              ],
            ),
            _Actions(
              device: device,
            )
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.signedDevice,
  });

  final SignedDevice signedDevice;

  String getName() {
    String platform = '${signedDevice.platform.name[0].toUpperCase()}${signedDevice.platform.name.substring(1).toLowerCase()}';
    String web = signedDevice.isWeb ? ' ($platform)' : '';
    return '${signedDevice.name}$web';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getName(),
          style:Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold
          ),
        ),
        Text('Last Signed: \n${signedDevice.lastSignIn.toLocal().toString()}',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w300,
          ),
        )
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.device,
  });

  final SignedDevice device;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Button(
        backgroundColor: Colors.red,
        text: 'Sign-Out',
        maxWidth: 75,
        maxHeight: 50,
        onClick: (context) async {
          await AppSecurity.instance.logoutFromDevice(device.deviceToken);
          if (context.mounted) {
            Toast.makeToast(
                text: 'You have been signed out of device',
                duration: ToastDuration.large,
                icon: Icons.add_moderator
            );
          }
        },
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon({
    required this.icon,
    required this.isCurrent,
  });

  final IconData icon;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            border: isCurrent ? Border.all(
                color: Colors.greenAccent.shade400,
                width: 2) : null,
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.primary
          ),
          alignment: Alignment.center,
          width: 50,
          height: 50,
          child: Icon(
            icon,
            size: 35,
          ),
        ),
      ),
    );
  }
}
