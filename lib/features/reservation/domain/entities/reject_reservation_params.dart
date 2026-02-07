import 'package:equatable/equatable.dart';

class RejectReservationParams extends Equatable {
  final String reservationId;
  final String rejectionReason;

  const RejectReservationParams({
    required this.reservationId,
    required this.rejectionReason,
  });

  @override
  List<Object?> get props => [reservationId, rejectionReason];
}
