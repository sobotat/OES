import 'package:download/download.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/restApi/api/http/HttpRequest.dart';
import 'package:oes/src/restApi/api/http/HttpRequestOptions.dart';
import 'package:oes/src/restApi/api/http/RequestResult.dart';
import 'package:oes/src/services/DeviceInfo.dart';
import 'package:oes/src/services/NewTabOpener.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/Gradient.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/RefreshWidget.dart';
import 'package:oes/ui/assets/templates/SizedContainer.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class WebHomeScreen extends StatefulWidget {
  const WebHomeScreen({super.key});

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  GlobalKey<RefreshWidgetState> refreshKey = GlobalKey<RefreshWidgetState>();

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
      body: RefreshWidget(
        key: refreshKey,
        onRefreshed: () {
          setState(() {});
          refreshKey.currentState?.refresh();
        },
        child: SizedContainer(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: GradientContainer(
              borderRadius: BorderRadius.circular(10),
              colors: [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).extension<AppCustomColors>()!.accent,
              ],
              child: ListView(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Title(width: width, overflow: overflow),
                      const _WhyToUse(),
                      const _Download(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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
    return const SizedContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text("Learn with fun and ease"),
          // Text("Create your own quiz as student"),
          // Text("Use it on all Platforms"),
          _ImageBanner(
            text: "Modern and Simple UI\nWith Animations",
            file: 'assets/images/main.png',
            alignment: _Align.right,
          ),
          _ImageBanner(
            text: "Supported Tests, Homeworks, Online Quizzes and many more",
            file: 'assets/images/course.png',
            alignment: _Align.left,
          ),
        ],
      ),
    );
  }
}

enum _Align{
  left,
  right
}

class _ImageBanner extends StatelessWidget {
  const _ImageBanner({
    required this.text,
    required this.file,
    this.alignment = _Align.right,
    super.key
  });

  final String text;
  final _Align alignment;
  final String file;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return SizedContainer(
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: width > overflow ? 50 : 15,
            vertical: 20
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Builder(
          builder: (context) {
            if (alignment == _Align.left) {
              List<Widget> widgets = [
                _BannerImage(
                  file: file,
                ),
                _BannerText(
                  text: text,
                  align: TextAlign.left,
                )
              ];
      
              if (width < overflow) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widgets,
                );
              }
              return Row(
                children: widgets,
              );
            }
            List<Widget> widgets = [
              _BannerText(
                text: text,
                align: TextAlign.left,
              ),
              _BannerImage(
                file: file,
              ),
            ];
            if (width < overflow) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: widgets,
              );
            }
            return Row(
              children: widgets,
            );
          }
        ),
      ),
    );
  }
}

class _BannerImage extends StatelessWidget {
  const _BannerImage({
    required this.file,
    super.key,
  });

  final String file;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(file),
          ),
        ),
      )
    );
  }
}

class _BannerText extends StatelessWidget {
  const _BannerText({
    super.key,
    required this.text,
    required this.align,
  });

  final String text;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(child: Text(text, textAlign: align, style: const TextStyle(fontSize: 40),)),
          ],
        ),
      )
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
        onMiddleClick: (context) {
          String path = context.namedLocation("main");
          NewTabOpener.open(path);
        },
      ),
    );
  }
}

class _Download extends StatelessWidget {
  const _Download({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return SizedContainer(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: width > overflow ? 50 : 15,
          vertical: 20
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10)
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Download", style: TextStyle(fontSize: 50),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: _DownloadButton(
                    fileName: "oes-windows.zip",
                    icon: AppIcons.icon_windows,
                  ),
                ),
                Flexible(
                  child: _DownloadButton(
                    fileName: "oes-android.apk",
                    icon: AppIcons.icon_android,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadButton extends StatefulWidget {
  const _DownloadButton({
    required this.fileName,
    required this.icon,
    super.key
  });

  final String fileName;
  final IconData icon;

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {

  int progress = -1;

  Future<void> downloadApp(String fileName) async {
    setState(() {
      progress = 0;
    });
    Device device = await DeviceInfo.getDevice();
    String? path;
    if (device.isWeb) {
      path = fileName;
    } else {
      path = await FilePicker.platform.getDirectoryPath(dialogTitle: "Download Location");
      if (path == null) {
        setState(() {
          progress = -1;
        });
        return;
      }
      path += "/$fileName";
    }
    debugPrint("Downloading File to $path");

    String baseUrl = "${Uri.base}app-download";
    if(baseUrl.contains("localhost")) {
      for(int p = 0; p <= 100; p++) {
        setState(() {
          progress = p;
        });
        await Future.delayed(const Duration(milliseconds: 20));
      }
      setState(() {
        progress = -1;
      });
      return;
    }

    RequestResult result = await HttpRequest.instance.get("$baseUrl/$fileName",
      options: HttpRequestOptions(
          responseType: HttpResponseType.bytes
      ),
      onReceiveProgress: (progress) {
        setState(() {
          this.progress = (progress * 100).round();
        });
      },
    );

    if (!result.checkOk()) {
      Toast.makeErrorToast(text: "File failed to Download", duration: ToastDuration.large);
      setState(() {
        progress = -1;
      });
      return;
    }

    await download(Stream.fromIterable(result.data as List<int>), path);
    Toast.makeSuccessToast(text: "File Downloaded", duration: ToastDuration.large);
    setState(() {
      progress = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Button(
        maxWidth: 150,
        maxHeight: 150,
        onClick: (context) async {
          downloadApp(widget.fileName);
        },
        child: Builder(
          builder: (context) {
            if (progress != -1) {
              return Column(
                children: [
                  const WidgetLoading(),
                  Text(" $progress%")
                ],
              );
            }
            return Icon(
              widget.icon,
              size: 50,
            );
          },
        ),
      ),
    );
  }
}
