import 'package:download/download.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/services/DeviceInfo.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/Gradient.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class WebHomeScreen extends StatefulWidget {
  const WebHomeScreen({super.key});

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Scaffold(
      appBar: AppAppBar(
        actions: [
          width > overflow ? const _GoToMain(maxWidth: 150,) : const _GoToMain(),
        ],
      ),
      body: ListView(
        children: [
          _Title(width: width, overflow: overflow),
          const _WhyToUse(),
          const _Download(),
        ],
      ),
    );
  }
}

class _WhyToUse extends StatelessWidget {
  const _WhyToUse({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Learn with fun and ease"),
        Text("Create your own quiz as student"),
        Text("Use it on all Platforms"),
        _ImageBanner(text: "aaaaaaaaaaaaaaa")
      ],
    );
  }
}

class _ImageBanner extends StatelessWidget {
  const _ImageBanner({
    required this.text,
    super.key
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Center(
            child: Text(text, textAlign: TextAlign.right,),
          )
        ),
        Flexible(
          child: Image.network(
            "https://media.istockphoto.com/id/952696392/vector/television-test-card.jpg?s=612x612&w=0&k=20&c=HLKN1cPrugPVtcPI6RK60CVb2wKq39ERVa9LgfLW38s=",
            height: 400,
            width: 400,
          )
        ),
      ],
    );
  }
}


class _Title extends StatelessWidget {
  const _Title({
    super.key,
    required this.width,
    required this.overflow,
  });

  final double width;
  final int overflow;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: GradientContainer(
        borderRadius: BorderRadius.zero,
        colors: [
          Theme.of(context).colorScheme.secondary,
          Theme.of(context).extension<AppCustomColors>()!.accent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 700,
              child: Center(
                child: Text(width > overflow ? 'Online E-Learning System' : 'Online\nE-Learning\nSystem',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontSize: width > overflow ? 50 : 35,
                    letterSpacing: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getActiveTheme().calculateTextColor(Theme.of(context).colorScheme.secondary, context)
                  ),
                  textAlign: TextAlign.center
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoToMain extends StatelessWidget {
  const _GoToMain({
    this.maxWidth = double.infinity,
  });

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      child: Button(
        text: 'Enter',
        backgroundColor: Theme.of(context).colorScheme.primary,
        minWidth: 100,
        maxWidth: maxWidth,
        onClick: (context) {
          context.goNamed('main');
        },
      ),
    );
  }
}

class _Download extends StatelessWidget {
  const _Download({super.key});

  Future<void> downloadApp(String fileName) async {
    Device device = await DeviceInfo.getDevice();
    String? path;
    if (device.isWeb) {
      path = fileName;
    } else {
      path = await FilePicker.platform.getDirectoryPath(dialogTitle: "Download Location");
      if (path == null) {
        return;
      }
      path += "/$fileName";
    }
    debugPrint("Downloading File to $path");

    String baseUrl = "${Uri.base}app-download";
    RequestResult result = await HttpRequest.instance.get("$baseUrl/$fileName",
      options: HttpRequestOptions(
          responseType: HttpResponseType.bytes
      ),
    );

    if (!result.checkOk()) {
      Toast.makeErrorToast(text: "File failed to Download", duration: ToastDuration.large);
      return;
    }

    await download(Stream.fromIterable(result.data as List<int>), path);
    Toast.makeSuccessToast(text: "File Downloaded", duration: ToastDuration.large);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(50),
      alignment: Alignment.center,
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Download", style: TextStyle(fontSize: 50),),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Button(
                  icon: AppIcons.icon_windows,
                  iconSize: 50,
                  maxWidth: 150,
                  maxHeight: 150,
                  onClick: (context) async {
                    downloadApp("oes-windows.msix");
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Button(
                  icon: AppIcons.icon_android,
                  iconSize: 50,
                  maxWidth: 150,
                  maxHeight: 150,
                  onClick: (context) {
                    downloadApp("oes-android.apk");
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
