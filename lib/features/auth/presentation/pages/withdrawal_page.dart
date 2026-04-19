import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_owner/features/auth/presentation/providers/sign_up_provider.dart';
import 'package:mobile_owner/features/auth/presentation/providers/withdrawal_provider.dart';
import 'package:mobile_owner/features/home/presentation/providers/home_provider.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class WithdrawalPage extends ConsumerStatefulWidget {
  const WithdrawalPage({super.key});

  @override
  ConsumerState<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends ConsumerState<WithdrawalPage> {
  final PageController _pageController = PageController();
  final TextEditingController _emailCodeController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  int _step = 0;

  static const List<String> _reasons = [
    '운영이 어려워요',
    '자주 사용하지 않아요',
    '앱 사용이 불편해요',
    '원하는 기능이 없어요',
    '다른 서비스를 이용할 예정이에요',
    '이용이 만족스럽지 않았어요',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final owner = ref.read(homeNotifierProvider).owner;
      if (owner != null) {
        ref.read(withdrawalNotifierProvider.notifier).setEmail(owner.email);
        ref
            .read(withdrawalNotifierProvider.notifier)
            .setPhoneNumber(owner.phoneNumber);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailCodeController.dispose();
    _smsCodeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _goToStep(int step) async {
    setState(() => _step = step);
    await _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleFinalSubmit() async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('정말 탈퇴하시겠어요?'),
        content: const Text(
          '탈퇴하면 운영 중인 샵, 예약, 리뷰가\n모두 삭제되며 복구할 수 없습니다.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('탈퇴하기'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await ref.read(withdrawalNotifierProvider.notifier).submit();
    if (!mounted) return;
    if (success) {
      messenger.showSnackBar(const SnackBar(content: Text('회원 탈퇴가 완료되었습니다')));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } else {
      final err = ref.read(withdrawalNotifierProvider).error ?? '탈퇴에 실패했습니다';
      messenger.showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(withdrawalNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 탈퇴'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step > 0) {
              _goToStep(_step - 1);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_step + 1) / 8,
            backgroundColor: AppColors.divider,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildNotice(),
                _buildReason(state),
                _buildAgreements(state),
                _buildEmailVerification(state),
                _buildSmsVerification(state),
                _buildPassword(state),
                _buildConfirmText(state),
                _buildFinalStep(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextButton({required bool enabled, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('다음'),
      ),
    );
  }

  Widget _buildNotice() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '회원 탈퇴 시 삭제되는 정보',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _noticeItem('사장님 계정 정보 및 로그인 권한'),
          _noticeItem('운영 중인 모든 샵'),
          _noticeItem('등록한 모든 시술'),
          _noticeItem('진행 중/과거 예약 내역'),
          _noticeItem('샵에 작성된 모든 리뷰'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '탈퇴 후 삭제된 데이터는 복구할 수 없습니다.\n진행 중 예약은 자동 취소되며 고객에게 통지되지 않습니다.',
              style: TextStyle(fontSize: 13, color: AppColors.error),
            ),
          ),
          const Spacer(),
          _nextButton(enabled: true, onTap: () => _goToStep(1)),
        ],
      ),
    );
  }

  Widget _noticeItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildReason(WithdrawalState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '탈퇴 사유를 알려주세요',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('서비스 개선에 참고하겠습니다.'),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _reasons.length,
              itemBuilder: (ctx, i) {
                final reason = _reasons[i];
                final selected = state.reason == reason;
                return InkWell(
                  onTap: () => ref
                      .read(withdrawalNotifierProvider.notifier)
                      .setReason(reason),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: selected
                              ? AppColors.error
                              : AppColors.textHint,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(reason)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _nextButton(
            enabled: state.reason.isNotEmpty,
            onTap: () => _goToStep(2),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreements(WithdrawalState state) {
    const items = [
      '운영 중인 샵이 모두 삭제됨을 이해했습니다',
      '진행 중 예약이 자동 취소됨을 이해했습니다',
      '등록된 시술과 리뷰가 모두 삭제됨을 이해했습니다',
      '삭제된 데이터는 복구할 수 없음을 이해했습니다',
    ];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주의사항 확인',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...List.generate(items.length, (i) {
            return CheckboxListTile(
              value: state.agreements[i],
              title: Text(items[i], style: const TextStyle(fontSize: 14)),
              onChanged: (_) =>
                  ref.read(withdrawalNotifierProvider.notifier).toggleAgreement(i),
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
          const Spacer(),
          _nextButton(enabled: state.allAgreed, onTap: () => _goToStep(3)),
        ],
      ),
    );
  }

  Widget _buildEmailVerification(WithdrawalState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이메일 인증',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('등록된 이메일: ${state.email}'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: state.emailStatus == VerificationStatus.sending ||
                      state.isEmailVerified
                  ? null
                  : () => ref.read(withdrawalNotifierProvider.notifier).sendEmailCode(),
              child: Text(
                state.emailStatus == VerificationStatus.codeSent ||
                        state.isEmailVerified
                    ? '인증코드 재전송'
                    : '이메일 인증코드 전송',
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCodeController,
            decoration: const InputDecoration(
              labelText: '인증코드 (6자리)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            enabled: !state.isEmailVerified,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: state.isEmailVerified ||
                      _emailCodeController.text.isEmpty
                  ? null
                  : () => ref
                      .read(withdrawalNotifierProvider.notifier)
                      .verifyEmailCode(_emailCodeController.text.trim()),
              child: Text(state.isEmailVerified ? '이메일 인증 완료' : '코드 확인'),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                state.error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
          const Spacer(),
          _nextButton(enabled: state.isEmailVerified, onTap: () => _goToStep(4)),
        ],
      ),
    );
  }

  Widget _buildSmsVerification(WithdrawalState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '휴대폰 번호 인증',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('등록된 번호: ${state.phoneNumber}'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: state.smsStatus == VerificationStatus.sending ||
                      state.isSmsVerified
                  ? null
                  : () => ref.read(withdrawalNotifierProvider.notifier).sendSmsCode(),
              child: Text(
                state.smsStatus == VerificationStatus.codeSent ||
                        state.isSmsVerified
                    ? '인증코드 재전송'
                    : 'SMS 인증코드 전송',
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _smsCodeController,
            decoration: const InputDecoration(
              labelText: '인증코드 (6자리)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            enabled: !state.isSmsVerified,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: state.isSmsVerified ||
                      _smsCodeController.text.isEmpty
                  ? null
                  : () => ref
                      .read(withdrawalNotifierProvider.notifier)
                      .verifySmsCode(_smsCodeController.text.trim()),
              child: Text(state.isSmsVerified ? 'SMS 인증 완료' : '코드 확인'),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                state.error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
          const Spacer(),
          _nextButton(enabled: state.isSmsVerified, onTap: () => _goToStep(5)),
        ],
      ),
    );
  }

  Widget _buildPassword(WithdrawalState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '비밀번호 확인',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('본인 확인을 위해 비밀번호를 입력해주세요.'),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '비밀번호',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) =>
                ref.read(withdrawalNotifierProvider.notifier).setPassword(v),
          ),
          const Spacer(),
          _nextButton(
            enabled: state.password.length >= 8,
            onTap: () => _goToStep(6),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmText(WithdrawalState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '확인 문구 입력',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('아래 문구를 정확히 입력해주세요:'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                '회원탈퇴에 동의합니다',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmController,
            onChanged: (v) =>
                ref.read(withdrawalNotifierProvider.notifier).setConfirmText(v),
            decoration: const InputDecoration(
              hintText: '위 문구를 그대로 입력',
              border: OutlineInputBorder(),
            ),
          ),
          const Spacer(),
          _nextButton(
            enabled: state.confirmTextValid,
            onTap: () => _goToStep(7),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStep(WithdrawalState state) {
    final loading = state.withdrawStatus == WithdrawStatus.loading;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '탈퇴 최종 확인',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            '모든 확인이 완료되었습니다.\n아래 버튼을 누르면 회원 탈퇴가 최종 진행됩니다.\n이 작업은 되돌릴 수 없습니다.',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('사유: ${state.reason}'),
                const SizedBox(height: 4),
                Text('이메일: ${state.email}'),
                const SizedBox(height: 4),
                Text('번호: ${state.phoneNumber}'),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : _handleFinalSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('탈퇴하기'),
            ),
          ),
        ],
      ),
    );
  }
}
