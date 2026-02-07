class RejectReservationRequest {
  final String rejectionReason;

  const RejectReservationRequest({required this.rejectionReason});

  Map<String, dynamic> toJson() {
    return {'rejectionReason': rejectionReason};
  }
}
