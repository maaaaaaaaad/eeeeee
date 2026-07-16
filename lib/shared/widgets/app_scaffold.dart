import 'package:flutter/material.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

/// 전역 Scaffold wrapper — 시스템 UI(상단 status bar/노치, 하단 nav/제스처 바)와
/// 키보드 인셋을 자동 처리해 모든 기기에서 콘텐츠가 시스템 UI 뒤로 숨지 않도록 한다.
///
/// 사용 규칙 (Architecture Test로 강제):
/// - lib/ 안에서는 raw `Scaffold(` 대신 항상 `AppScaffold`를 쓴다.
/// - `bottomAction`은 스티키 액션바 ([AppBottomActionBar] 등). AppBar와 body 사이에
///   자체 SafeArea/viewInsets 처리를 포함하므로 별도 SafeArea 감쌈 불필요.
/// - `bottomNavigationBar`는 탭 nav 전용. Material [NavigationBar]는 자체
///   SafeArea 처리하므로 그대로 넘겨도 된다.
class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomAction;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final bool resizeToAvoidBottomInset;
  final bool useSafeArea;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomAction,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.floatingActionButton,
    this.backgroundColor,
    this.backgroundGradient,
    this.resizeToAvoidBottomInset = true,
    this.useSafeArea = true,
  }) : assert(
          bottomAction == null || bottomNavigationBar == null,
          'bottomAction과 bottomNavigationBar는 동시에 사용할 수 없다.',
        );

  @override
  Widget build(BuildContext context) {
    Widget content = useSafeArea
        ? SafeArea(bottom: false, child: body)
        : body;

    if (backgroundGradient != null) {
      content = Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: content,
      );
    }

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor ?? AppColors.backgroundMedium,
      extendBodyBehindAppBar: appBar != null,
      extendBody: bottomNavigationBar != null,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      body: SizedBox.expand(child: content),
      bottomNavigationBar: bottomAction ?? bottomNavigationBar,
      bottomSheet: bottomSheet,
    );
  }
}
