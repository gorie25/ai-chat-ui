import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../services/enums/message_type.dart';
import '../../../services/models/message.dart';

class StreamingMarkdown extends StatefulWidget {
  final Message message;
  final Duration typingSpeed;
  final MarkdownStyleSheet styleSheet;
  final VoidCallback? onComplete;

  const StreamingMarkdown({
    super.key,
    required this.message,
    required this.styleSheet,
    this.typingSpeed = const Duration(milliseconds: 15),
    this.onComplete,
  });

  @override
  State<StreamingMarkdown> createState() => _StreamingMarkdownState();
}

class _StreamingMarkdownState extends State<StreamingMarkdown> {
  final StringBuffer _displayedTextBuffer = StringBuffer();
  String get _displayedText => _displayedTextBuffer.toString();

  Timer? _typeTimer;
  bool _isComplete = false;

  String get _targetText => widget.message.text ?? "";

  @override
  void initState() {
    super.initState();

    if (widget.message.type != MessageType.streaming) {
      _displayedTextBuffer.write(_targetText);
      _isComplete = true;
    } else {
      _handleTyping();
    }
  }

  @override
  void didUpdateWidget(StreamingMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_targetText.length > _displayedText.length) {
      _handleTyping();
    }

    if (widget.message.type != MessageType.streaming &&
        _displayedText.length == _targetText.length) {
      _finalize();
    }
  }

  void _handleTyping() {
    if (_typeTimer?.isActive ?? false) return;

    _typeTimer = Timer.periodic(widget.typingSpeed, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_displayedText.length < _targetText.length) {
        setState(() {
          final nextChar = _targetText[_displayedText.length];
          _displayedTextBuffer.write(nextChar);
        });
      } else {
        timer.cancel();

        if (widget.message.type != MessageType.streaming) {
          _finalize();
        }
      }
    });
  }

  void _finalize() {
    if (!_isComplete) {
      setState(() => _isComplete = true);
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: _displayedText,
      selectable: true,
      styleSheet: widget.styleSheet,
    );
  }
}
