import 'package:mobile_owner/features/auth/domain/entities/owner.dart';

class OwnerModel extends Owner {
  const OwnerModel({
    required super.id,
    required super.businessNumber,
    required super.phoneNumber,
    required super.nickname,
    required super.email,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: json['id'] as String,
      businessNumber: json['businessNumber'] as String,
      phoneNumber: json['phoneNumber'] as String,
      nickname: json['nickname'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessNumber': businessNumber,
      'phoneNumber': phoneNumber,
      'nickname': nickname,
      'email': email,
    };
  }
}
