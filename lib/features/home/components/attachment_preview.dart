import 'package:flutter/material.dart';
import '../../../core/widgets/custom_list.dart';
import 'preview_attachment_item.dart';

class AttachmentPreview extends StatefulWidget {
  final List<String> imagePaths;
  final ValueChanged<List<String>>? onChanged;

  const AttachmentPreview({
    super.key,
    required this.imagePaths,
    this.onChanged,
  });

  @override
  State<AttachmentPreview> createState() => _AttachmentPreviewState();
}

class _AttachmentPreviewState extends State<AttachmentPreview> {
  late List<String> _imagePaths;

  @override
  void initState() {
    super.initState();
    _imagePaths = [...widget.imagePaths];
  }

  @override
  void didUpdateWidget(covariant AttachmentPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    _imagePaths = [...widget.imagePaths];
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
    widget.onChanged?.call(_imagePaths);
  }

  @override
  Widget build(BuildContext context) {
    if (_imagePaths.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 6),
      child: CustomList.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        children: List.generate(_imagePaths.length, (index) {
          final imagePath = _imagePaths[index];
          return PreviewAttachmentItem(
            imagePath: imagePath,
            onRemove: () => _removeImage(index),
          );
        }),
      ),
    );
  }
}
