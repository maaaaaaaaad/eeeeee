import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

/// 시스템 UI(안드로이드 네비/제스처 바)와 키보드를 자동 회피하는 BottomSheet wrapper.
///
/// `showModalBottomSheet`를 직접 호출하지 말고 항상 이 함수를 사용한다.
/// Architecture Test가 `lib/` 안에서 raw `showModalBottomSheet(` 호출을 거부한다.
///
/// 자동 처리:
/// - `SafeArea(top: false)` — 하단 시스템 인셋 (제스처 바, 네비 바, 노치)
/// - `viewInsets.bottom` — 키보드 높이
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  ShapeBorder? shape,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    shape: shape,
    builder: (innerContext) => DecoratedBox(
      decoration: BoxDecoration(
        color:
            backgroundColor ?? Theme.of(innerContext).scaffoldBackgroundColor,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(innerContext).viewInsets.bottom,
        ),
        child: SafeArea(top: false, child: builder(innerContext)),
      ),
    ),
  );
}

/// 시스템 UI를 자동 회피하는 Dialog wrapper.
///
/// `showDialog`를 직접 호출하지 말고 항상 이 함수를 사용한다.
/// Architecture Test가 `lib/` 안에서 raw `showDialog(` 호출을 거부한다.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    builder: (innerContext) => SafeArea(child: builder(innerContext)),
  );
}

/// 삭제/취소 등 확인이 필요한 액션용 표준 다이얼로그.
///
/// `isDestructive: true`이면 confirm 버튼이 error 컬러로 표시된다.
/// `insetPadding.bottom`에 `viewPadding.bottom`을 더해 안드로이드 시스템
/// 네비 바가 다이얼로그 하단을 가리지 않도록 한다.
Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = '확인',
  String cancelLabel = '취소',
  bool isDestructive = false,
}) async {
  final result = await showAppDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final systemNavPadding =
          MediaQuery.viewPaddingOf(dialogContext).bottom;
      return AlertDialog(
        insetPadding: EdgeInsets.only(
          left: 40,
          right: 40,
          top: 24,
          bottom: 24 + systemNavPadding,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: AppColors.error)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
