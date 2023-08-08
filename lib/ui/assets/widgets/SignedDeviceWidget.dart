import 'package:flutter/material.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/src/Objects/SignedDevice.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class SignedDeviceWidget extends StatelessWidget {

  const SignedDeviceWidget({
    required this.signedDevice,
    super.key
  });

  final SignedDevice signedDevice;

  IconData getIcon() {
    if(signedDevice.isWeb) {
      return AppIcons.icon_web;
    }

    switch (signedDevice.platform) {
      case DevicePlatform.android:
        return AppIcons.icon_android;
      case DevicePlatform.ios:
        return AppIcons.icon_ios;
      case DevicePlatform.windows:
        return AppIcons.icon_windows;
      case DevicePlatform.macos:
        return AppIcons.icon_apple;
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
                _Icon(icon: getIcon(),),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: _Info(signedDevice: signedDevice),
                ),
              ],
            ),
            _Actions()
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.signedDevice,
    super.key,
  });

  final SignedDevice signedDevice;

  String getPlatform() {
    String web = signedDevice.isWeb ? ' (Web)' : '';
    switch(signedDevice.platform) {
      case DevicePlatform.android:
        return 'Android$web';
      case DevicePlatform.ios:
        return 'iOS$web';
      case DevicePlatform.windows:
        return 'Windows$web';
      case DevicePlatform.macos:
        return 'MacOS$web';
      default:
        return 'Web';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(getPlatform(),
          style:Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold
          ),
        ),
        Text('Last Signed: \n${signedDevice.lastSignIn.toString()}',
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Button(
        backgroundColor: Colors.red,
        text: 'Sign-Out',
        maxWidth: 75,
        maxHeight: 50,
        onClick: (context) {
          debugPrint('You sign out of that device');
          //TODO: Implement sign out
        },
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon({
    required this.icon,
    super.key,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
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
