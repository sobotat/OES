
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oes/config/AppRouter.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class RefreshWidget extends StatefulWidget {
  const RefreshWidget({
    required this.onRefreshed,
    this.child,
    super.key
  });

  final Widget? child;
  final Function() onRefreshed;

  @override
  State<RefreshWidget> createState() => RefreshWidgetState();
}

class RefreshWidgetState extends State<RefreshWidget> {

  bool shouldRefresh = true;
  bool _refreshing = false;
  Function() _popListener = () {};

  @override
  void initState() {
    super.initState();

    _popListener = () {
      if (!shouldRefresh) return;
      if (mounted) widget.onRefreshed();
    };

    AppRouter.instance.popNotifier.addListener(_popListener);
  }

  @override
  void dispose() {
    AppRouter.instance.popNotifier.removeListener(_popListener);
    super.dispose();
  }

  void refresh({
    Duration delay = const Duration(milliseconds: 250),
  }) {
    _refreshing = true;
    setState(() {});
    Timer(delay, () {
      _refreshing = false;
      if (mounted) setState(() {});
    },);
  }

  void disableRefreshOnPop() {
    shouldRefresh = false;
  }

  Future<void> enableRefreshOnPop({
    Duration delay = const Duration(milliseconds: 500),
    bool refreshAfter = false,
  }) {
    return Future.delayed(delay, () {
      shouldRefresh = true;
      if (refreshAfter && mounted) {
        widget.onRefreshed();
      }
    },);
  }

  @override
  Widget build(BuildContext context) {
    if (_refreshing) return const Center(child: WidgetLoading(),);
    return widget.child ?? Container();
  }
}
