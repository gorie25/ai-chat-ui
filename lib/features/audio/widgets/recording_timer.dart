import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/extensions/int_extensions.dart';

class RecordingTimerWidget extends StatefulWidget {
  final bool isListening;
  final Widget Function(BuildContext context, int duration, String formattedTime) builder;

  const RecordingTimerWidget({
    super.key,
    required this.isListening,
    required this.builder,
  });

  @override
  State<RecordingTimerWidget> createState() => _RecordingTimerWidgetState();
}

class _RecordingTimerWidgetState extends State<RecordingTimerWidget> {
  Timer? _timer;
  int _duration = 0;
  int _timerSession = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isListening) _startTimer();
  }

  @override
  void didUpdateWidget(covariant RecordingTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      widget.isListening ? _startTimer() : _stopTimer();
    }
  }

  void _startTimer() {
    _timerSession++;
    final session = _timerSession;
    _duration = 0;
    _timer?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isListening || session != _timerSession) return;
      _scheduleNextTick(session);
    });
  }

  void _scheduleNextTick(int session) {
    _timer = Timer(const Duration(seconds: 1), () {
      if (!mounted || !widget.isListening || session != _timerSession) return;
      setState(() => _duration++);
      _scheduleNextTick(session);
    });
  }

  void _stopTimer() {
    _timerSession++;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _duration, _duration.formatTimer());
  }
}
