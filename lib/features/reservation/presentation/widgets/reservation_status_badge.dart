import 'package:flutter/material.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';

class ReservationStatusBadge extends StatelessWidget {
  final ReservationStatus status;

  const ReservationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    return switch (status) {
      ReservationStatus.pending => const Color(0xFFFFF3E0),
      ReservationStatus.confirmed => const Color(0xFFE8F5E9),
      ReservationStatus.rejected => const Color(0xFFFFEBEE),
      ReservationStatus.cancelled => const Color(0xFFF5F5F5),
      ReservationStatus.completed => const Color(0xFFE3F2FD),
      ReservationStatus.noShow => const Color(0xFFFCE4EC),
    };
  }

  Color get _textColor {
    return switch (status) {
      ReservationStatus.pending => const Color(0xFFE65100),
      ReservationStatus.confirmed => const Color(0xFF2E7D32),
      ReservationStatus.rejected => const Color(0xFFC62828),
      ReservationStatus.cancelled => const Color(0xFF757575),
      ReservationStatus.completed => const Color(0xFF1565C0),
      ReservationStatus.noShow => const Color(0xFFAD1457),
    };
  }
}
