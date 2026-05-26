import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/custom_colors.dart';

class PreviewAttachmentItem extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;

  const PreviewAttachmentItem({
    super.key,
    required this.imagePath,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(imagePath),
            width: 70,
            height: 70,
            cacheHeight: 70,
            filterQuality: FilterQuality.low,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(
                Icons.close,
                size: 14,
                color: CustomColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
