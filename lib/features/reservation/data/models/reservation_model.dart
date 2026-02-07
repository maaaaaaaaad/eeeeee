import 'package:mobile_owner/features/reservation/domain/entities/reservation.dart';
import 'package:mobile_owner/features/reservation/domain/entities/reservation_status.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    required super.shopId,
    required super.memberId,
    required super.treatmentId,
    super.shopName,
    super.treatmentName,
    super.treatmentPrice,
    super.treatmentDuration,
    super.memberNickname,
    required super.reservationDate,
    required super.startTime,
    required super.endTime,
    required super.status,
    super.memo,
    super.rejectionReason,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      memberId: json['memberId'] as String,
      treatmentId: json['treatmentId'] as String,
      shopName: json['shopName'] as String?,
      treatmentName: json['treatmentName'] as String?,
      treatmentPrice: (json['treatmentPrice'] as num?)?.toInt(),
      treatmentDuration: (json['treatmentDuration'] as num?)?.toInt(),
      memberNickname: json['memberNickname'] as String?,
      reservationDate: json['reservationDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: ReservationStatus.fromString(json['status'] as String),
      memo: json['memo'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
