import 'package:flutter/material.dart';

/// 스크롤/Column 콘텐츠 마지막에 넣어 하단 시스템 인셋만큼 여백을 확보한다.
///
/// [AppScaffold]가 `SafeArea(bottom: false)`로 body를 감싸므로, 이 위젯이
/// `viewPadding.bottom`(시스템 nav/제스처 바 높이)를 명시적으로 계산해야
/// 어떤 기기에서도 마지막 콘텐츠가 잘리지 않는다.
class AppBottomInset extends StatelessWidget {
  final double additional;

  const AppBottomInset({super.key, this.additional = 0});

  @override
  Widget build(BuildContext context) {
    final systemBottom = MediaQuery.viewPaddingOf(context).bottom;
    return SizedBox(height: systemBottom + additional);
  }
}
