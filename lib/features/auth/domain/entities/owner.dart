import 'package:equatable/equatable.dart';

class Owner extends Equatable {
  final String id;
  final String businessNumber;
  final String phoneNumber;
  final String nickname;
  final String email;

  const Owner({
    required this.id,
    required this.businessNumber,
    required this.phoneNumber,
    required this.nickname,
    required this.email,
  });

  @override
  List<Object?> get props => [id, businessNumber, phoneNumber, nickname, email];
}
