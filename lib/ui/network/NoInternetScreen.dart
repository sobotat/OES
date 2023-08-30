import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

    if(context.mounted && haveInternet){
      context.go(widget.path);
    }
    setState(() {
      refreshing = false;
    });
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
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'No Internet',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                    Button(
                      text: 'Refresh',
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
