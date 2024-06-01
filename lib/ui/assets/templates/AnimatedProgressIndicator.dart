
import 'package:flutter/material.dart';

class AnimatedProgressIndicator extends StatefulWidget {
  const AnimatedProgressIndicator({
    required this.value,
    required this.startColor,
    this.endColor,
    super.key
  });

  final double value;
  final Color startColor;
  final Color? endColor;

  @override
  State<AnimatedProgressIndicator> createState() => _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.value;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: _currentProgress, end: _currentProgress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _currentProgress) {
      updateProgress(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void updateProgress(double progress) {
    setState(() {
      double startProgress = _currentProgress;
      double endProgress = progress;
      _animation = Tween<double>(begin: startProgress, end: endProgress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      )..addListener(() {
        setState(() {});
      });
      _currentProgress = progress;
      _controller.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LinearProgressIndicator(
          value: _animation.value,
          color: Color.lerp(widget.startColor, widget.endColor ?? widget.startColor, _animation.value),
        ),
      ],
    );
  }
}