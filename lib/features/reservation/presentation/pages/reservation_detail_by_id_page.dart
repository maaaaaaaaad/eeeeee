import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_owner/features/reservation/presentation/pages/reservation_detail_page.dart';
import 'package:mobile_owner/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:mobile_owner/shared/theme/app_colors.dart';

class ReservationDetailByIdPage extends ConsumerStatefulWidget {
  final String reservationId;

  const ReservationDetailByIdPage({super.key, required this.reservationId});

  @override
  ConsumerState<ReservationDetailByIdPage> createState() =>
      _ReservationDetailByIdPageState();
}

class _ReservationDetailByIdPageState
    extends ConsumerState<ReservationDetailByIdPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReservation());
  }

  Future<void> _loadReservation() async {
    final useCase = ref.read(getReservationUseCaseProvider);
    final result = await useCase(widget.reservationId);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
        Navigator.pop(context);
      },
      (reservation) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReservationDetailPage(reservation: reservation),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.pastelPink),
      ),
    );
  }
}
