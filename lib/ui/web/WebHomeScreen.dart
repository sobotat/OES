import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';

class WebHomeScreen extends StatefulWidget {
  const WebHomeScreen({super.key});

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

String getActiveThemeModeName() {
  return '${AppTheme.isDarkMode() ? 'Dark' : 'Light'}  ${ThemeMode.system == AppTheme.activeThemeMode.themeMode ? '(System)' : ''}';
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 0,
          ),
          child: Center(
            child: Row(
              children: [
                const NameBanner(),
                Expanded(
                  flex: width >= overflow ? 2 : 0,
                  child: width >= overflow ? _LargeMenu() : Container(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          width < overflow ? _SmallMenu(): Container(),
        ],
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          children: [
            Center(child: Text('This will be main web page', style: TextStyle(fontWeight: FontWeight.bold),))
          ],
        ),
      ),
    );
  }
}

class NameBanner extends StatelessWidget {
  const NameBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Text('OES - Online E-learning System', style: TextStyle(fontSize: 24),),
      )
    );
  }
}

class _UserWidget extends StatefulWidget {
  const _UserWidget({this.maxWidth=-1, this.maxHeight=-1, super.key});

  final double maxWidth;
  final double maxHeight;

  @override
  State<_UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<_UserWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (AppSecurity.instance.isLoggedIn()){
              context.goNamed('sign-out');
            }else {
              context.goNamed('sign-in', queryParameters: {'path':'/'});
            }
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppSecurity.instance.isLoggedIn() ? Colors.green[400] : Colors.red[400],
          ),
          width: widget.maxWidth == -1 ? 100 : widget.maxWidth,
          height: widget.maxHeight == -1 ? double.infinity : widget.maxHeight,
          child: OverflowBox(
            minWidth: 0,
            minHeight: 0,
            maxWidth: double.infinity,
            maxHeight: widget.maxHeight == -1 ? double.infinity : widget.maxHeight,
            child: Text(
              AppSecurity.instance.user?.username ?? 'Not Logged',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallMenu extends StatelessWidget {
  const _SmallMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(

      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 1,
          child: _UserWidget(maxWidth: 300, maxHeight: 40,),
        ),
        const PopupMenuItem(
          value: 1,
          child: _ChangeThemeButton(),
        ),
        const PopupMenuItem(
          value: 1,
          child: _GoToMain(),
        ),
        const PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.chrome_reader_mode),
              Text("Nothing")
            ],
          ),
        ),
      ],
      offset: const Offset(0, 100),
      color: Colors.grey,
      elevation: 2,
    );
  }
}

class _LargeMenu extends StatelessWidget {
  const _LargeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(child: _ChangeThemeButton(), width: 150),
        SizedBox(child: _GoToMain(), width: 150,),
        SizedBox(child: _UserWidget(), width: 150,),
      ],
    );
  }
}

class _GoToMain extends StatelessWidget {
  const _GoToMain({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
                onPressed: () { context.goNamed('main'); },
                child: const Text('Enter')
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeThemeButton extends StatefulWidget {
  const _ChangeThemeButton({super.key});

  @override
  State<_ChangeThemeButton> createState() => _ChangeThemeButtonState();
}

class _ChangeThemeButtonState extends State<_ChangeThemeButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    AppTheme.activeThemeMode.changeThemeMode();
                  });
                },
                child: Text( getActiveThemeModeName() )
            ),
          ),
        ],
      ),
    );
  }
}
