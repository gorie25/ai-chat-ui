import 'package:flutter/material.dart';
import '../theme/custom_colors.dart';
import 'custom_text.dart';

class CustomDialogProvider {
  static final CustomDialogProvider instance = CustomDialogProvider._();
  CustomDialogProvider._();

  static bool isShowingMessage = false;

  Future<bool?> showPermissionDialog(
    BuildContext context, {
    required String message,
  }) async {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CustomColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: CustomText.bold(
            'Yêu cầu quyền truy cập',
            fontSize: FontSizes.big,
            color: CustomColors.color28247C,
          ),
          content: CustomText.regular(
            message,
            fontSize: FontSizes.medium,
            color: CustomColors.color1A202C,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: CustomText.medium(
                'Để sau',
                color: CustomColors.color718096,
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.color28247C,
                foregroundColor: CustomColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: CustomText.medium(
                'Cài đặt',
                color: CustomColors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> showMessageDialog(
    BuildContext context, {
    String title = 'Thông báo',
    required String message,
    bool barrierDismissible = true,
    VoidCallback? callback,
  }) async {
    if (isShowingMessage) {
      return false;
    }
    isShowingMessage = true;
    return showDialog<bool?>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CustomColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: CustomText.bold(
            title,
            fontSize: FontSizes.big,
            color: CustomColors.color28247C,
          ),
          content: CustomText.regular(
            message,
            fontSize: FontSizes.medium,
            color: CustomColors.color1A202C,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
                if (callback != null) {
                  callback();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.color28247C,
                foregroundColor: CustomColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: CustomText.medium(
                'Đóng',
                color: CustomColors.white,
              ),
            ),
          ],
        );
      },
    ).then((value) {
      isShowingMessage = false;
      return null;
    });
  }
}

class CustomBottomSheetHelper {
  const CustomBottomSheetHelper._();
  static CustomBottomSheetHelper? _instance;

  static CustomBottomSheetHelper get instance {
    _instance ??= const CustomBottomSheetHelper._();
    return _instance!;
  }

  Future<dynamic> showView(
    Widget widget, {
    required BuildContext context,
    bool isDismissible = true,
    bool useRootNavigator = false,
    bool enableDrag = true,
  }) async {
    return showModalBottomSheet<dynamic>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      backgroundColor: Colors.transparent,
      builder: (context) => widget,
    );
  }
}

// Reusable FlushProvider using standard floating SnackBar with Yody aesthetic
class CustomFlushProvider {
  const CustomFlushProvider._();
  static CustomFlushProvider? _instance;

  static CustomFlushProvider get instance {
    _instance ??= const CustomFlushProvider._();
    return _instance!;
  }

  void showErrorMessage(
    BuildContext context, {
    required String title,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: CustomColors.white),
            const SizedBox(width: 8),
            Expanded(
              child: CustomText.medium(
                title,
                color: CustomColors.white,
              ),
            ),
          ],
        ),
        backgroundColor: CustomColors.colorF04438,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  void showSuccessMessage(
    BuildContext context, {
    required String title,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: CustomColors.white),
            const SizedBox(width: 8),
            Expanded(
              child: CustomText.medium(
                title,
                color: CustomColors.white,
              ),
            ),
          ],
        ),
        backgroundColor: CustomColors.color12B76A,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }
}
