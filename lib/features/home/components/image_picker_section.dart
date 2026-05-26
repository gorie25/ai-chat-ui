import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/custom_colors.dart';
import '../../../core/widgets/custom_text.dart';

class ImagePickerSection extends StatelessWidget {
  final Function(List<String> paths) onFilesSelected;
  const ImagePickerSection({super.key, required this.onFilesSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOptionItem(
            icon: Icons.camera_alt,
            title: "Chụp ảnh",
            iconColor: CustomColors.green,
            onTap: () async {
              final picker = ImagePicker();
              final photo = await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 80,
              );
              if (photo != null) {
                onFilesSelected([photo.path]);
                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
          const SizedBox(height: 20),
          _buildOptionItem(
            icon: Icons.image,
            title: "Gửi hình ảnh/Video",
            iconColor: CustomColors.color53B1FD,
            onTap: () async {
              final picker = ImagePicker();
              final result = await picker.pickMultipleMedia();
              if (result.isNotEmpty) {
                onFilesSelected(result.map((e) => e.path).toList());
                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
          const SizedBox(height: 20),
          _buildOptionItem(
            icon: Icons.attach_file,
            title: "Đính kèm file",
            iconColor: CustomColors.color53B1FD,
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          CustomText.base(
            title,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
