import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppRouter.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/services/NetworkChecker.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({
    required this.path,
    super.key
  });

  final String path;

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {

  bool refreshing = false;

  Future<void> refresh(BuildContext context) async {
    setState(() {
      refreshing = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    bool haveInternet = await NetworkChecker.instance.checkConnection();

    if(context.mounted && (haveInternet || AppRouter.instance.disableNetworkCheck)){
      context.go(widget.path);
    }
    setState(() {
      refreshing = false;
    });
  }

  void disableNetworkCheck() {
    AppRouter.instance.disableNetworkCheck = true;
    debugPrint('Network check Disabled for this session');
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
        Stack(
          children: [
            Center(
              child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onDoubleTap: () => disableNetworkCheck(),
                        child: Text(
                          !AppRouter.instance.disableNetworkCheck ? 'No Internet' : 'Network Check Disabled',
                          style: TextStyle(
                            fontSize: 40,
                            color: !AppRouter.instance.disableNetworkCheck ? Theme.of(context).textTheme.bodyMedium!.color : Colors.red,
                          ),
                        ),
                      ),
                    ),
                    Button(
                      text: !AppRouter.instance.disableNetworkCheck ? 'Refresh' : 'Go Back',
                      maxWidth: 150,
                      onClick: (context) => refresh(context),
                      child: !refreshing ? null : SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Theme.of(context).extension<AppCustomColors>()!.accent,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            const Align(
              alignment: Alignment.topRight,
              child: ThemeModeButton(),
            )
          ],
        ),
      ),
    );
  }
}
