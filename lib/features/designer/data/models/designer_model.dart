import 'package:mobile_owner/features/designer/domain/entities/designer.dart';

class DesignerModel extends Designer {
  const DesignerModel({
    required super.id,
    required super.shopId,
    required super.name,
    super.nickname,
    super.intro,
    super.photoUrls,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DesignerModel.fromJson(Map<String, dynamic> json) {
    final rawPhotoUrls = json['photoUrls'];
    final photoUrls = rawPhotoUrls is List
        ? rawPhotoUrls.map((e) => e as String).toList()
        : const <String>[];

    return DesignerModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String?,
      intro: json['intro'] as String?,
      photoUrls: photoUrls,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'nickname': nickname,
      'intro': intro,
      'photoUrls': photoUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
