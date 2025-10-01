import 'dart:async';
import 'package:flutter/material.dart';

class InactivityWrapper extends StatefulWidget {
  final Duration timeout;
  final VoidCallback onTimeout;
  final Widget child;

  const InactivityWrapper({
    super.key,
    required this.timeout,
    required this.onTimeout,
    required this.child,
  });

  @override
  State<InactivityWrapper> createState() => _InactivityWrapperState();
}

class _InactivityWrapperState extends State<InactivityWrapper> {
  Timer? _timer;

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeout, widget.onTimeout);
  }

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Qualquer toque/tecla/movimento reinicia o timer
    return Listener(
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerUp: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}