import 'package:flutter/material.dart';
import '../theme/custom_colors.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
    this.callback,
  });

  final VoidCallback? callback;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (callback != null) {
            callback!();
          } else {
            Navigator.pop(context);
          }
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomColors.color28247C.withOpacity(0.05),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: CustomColors.color28247C,
            size: 18,
          ),
        ),
      ),
    );
  }
}
