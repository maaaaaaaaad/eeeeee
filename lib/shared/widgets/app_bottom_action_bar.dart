import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

/// [AppScaffold]의 `bottomAction`에 넣는 스티키 하단 액션바.
///
/// 자동 처리:
/// - `SafeArea(top: false)` — 안드로이드 시스템 nav/제스처 바 및 iOS home indicator 회피
/// - 상위 Scaffold의 `resizeToAvoidBottomInset: true`가 키보드를 처리한다.
///
/// 다수 children이면 각 자식을 `Expanded`로 감싸 균등 분배한다.
/// 단일 child면 폭을 채운다.
class AppBottomActionBar extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool showTopBorder;
  final double gap;

  const AppBottomActionBar({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.backgroundColor,
    this.showTopBorder = true,
    this.gap = 12,
  }) : assert(children.length > 0, 'children은 비어있을 수 없다.');

  @override
  Widget build(BuildContext context) {
    final Widget row;
    if (children.length == 1) {
      row = SizedBox(width: double.infinity, child: children.first);
    } else {
      final laid = <Widget>[];
      for (var i = 0; i < children.length; i++) {
        if (i > 0) laid.add(SizedBox(width: gap));
        laid.add(Expanded(child: children[i]));
      }
      row = Row(children: laid);
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        border: showTopBorder
            ? const Border(
                top: BorderSide(color: AppColors.divider, width: 0.5),
              )
            : null,
      ),
      child: SafeArea(
        top: false,
        child: Padding(padding: padding, child: row),
      ),
    );
  }
}
