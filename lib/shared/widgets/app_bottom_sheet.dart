import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

/// 시스템 UI(상태 바, 노치, 제스처 바, 홈 인디케이터)와 키보드를 자동 회피하는
/// BottomSheet wrapper.
///
/// `showModalBottomSheet`를 직접 호출하지 말고 항상 이 함수를 사용한다.
/// Architecture Test가 `lib/` 안에서 raw `showModalBottomSheet(` 호출을 거부한다.
///
/// 동작:
/// 1. `useSafeArea: true` — Flutter가 상단(status bar/노치) 및 좌우 시스템 UI를
///    자동 회피한다. 시트가 상태바 위로 확장되지 않는다.
/// 2. `Padding(bottom: viewInsets.bottom)` — 소프트 키보드 높이만큼 시트 콘텐츠를
///    위로 밀어올린다. Flutter는 modal bottom sheet에 대해 키보드 회피를 자동으로
///    처리하지 않으므로 wrapper가 반드시 수동 처리해야 한다.
/// 3. `SafeArea(top: false)` — 홈 인디케이터/제스처 바(bottom safe area)를 회피한다.
///    `useSafeArea:true`는 `SafeArea(bottom:false)`로 감싸므로 하단은 별도 처리.
///
/// 이 wrapper는 시트 콘텐츠의 자연스러운 높이를 존중한다 — 별도 maxHeight를
/// 강제하지 않는다. 콘텐츠가 화면보다 크면 SingleChildScrollView 안에서 스크롤한다.
///
/// DecoratedBox는 Padding 안쪽에 두어, 키보드 애니메이션 도중 padding 영역(=키보드
/// 뒤로 들어가는 영역)이 배경색으로 채워져 콘텐츠 위를 덮는 것처럼 보이지 않게 한다.
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
    useSafeArea: true,
    builder: (innerContext) {
      final keyboardInset = MediaQuery.viewInsetsOf(innerContext).bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor ??
                Theme.of(innerContext).scaffoldBackgroundColor,
          ),
          child: SafeArea(top: false, child: builder(innerContext)),
        ),
      );
    },
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
