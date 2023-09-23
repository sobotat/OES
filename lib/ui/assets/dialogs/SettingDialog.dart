
import 'package:flutter/material.dart';
import 'package:oes/src/services/LocalStorage.dart';

class SettingDialog extends StatelessWidget {
  const SettingDialog({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: const SizedBox(
        width: 400,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Title(),
              _UseMuck()
            ],
          ),
        ),
      ),
    );
  }
}

class _UseMuck extends StatefulWidget {
  const _UseMuck({
    super.key,
  });

  @override
  State<_UseMuck> createState() => _UseMuckState();
}

class _UseMuckState extends State<_UseMuck> {

  String value = 'default';
  String loadedValue = 'default';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      String? useMuck = await LocalStorage.instance.get('useMuck');
      if (useMuck == null) {
        value = 'default';
      } else if (useMuck == 'true') {
        value = 'yes';
      } else if (useMuck == 'false') {
        value = 'no';
      }
      loadedValue = value;
      setState(() {});
    },);
  }

  setValue(String? value) {
    if (value == null) return;
    this.value = value;

    switch(value) {
      case 'default':
        LocalStorage.instance.remove('useMuck');
        break;
      case 'yes':
        LocalStorage.instance.set('useMuck', 'true');
        break;
      case 'no':
        LocalStorage.instance.set('useMuck', 'false');
        break;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Use Muck Api'),
            DropdownButton(
              items: const [
                DropdownMenuItem(value: 'default',child: Text('Default'),),
                DropdownMenuItem(value: 'yes', child: Text('Yes')),
                DropdownMenuItem(value: 'no', child: Text('No')),
              ],
              value: value,
              onChanged: (value) => setValue(value),
            ),
          ],
        ),
        loadedValue != value ? const Text('Reload Required', style: TextStyle(color: Colors.red),) : Container()
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 20,
      ),
      child: Text('Settings',
        style: TextStyle(fontSize: 30),
      ),
    );
  }
}

