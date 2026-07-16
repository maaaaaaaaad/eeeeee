import 'package:equatable/equatable.dart';

class UpdateDesignerParams extends Equatable {
  final String designerId;
  final String shopId;
  final String? name;
  final String? nickname;
  final String? intro;
  final List<String>? photoUrls;

  const UpdateDesignerParams({
    required this.designerId,
    required this.shopId,
    this.name,
    this.nickname,
    this.intro,
    this.photoUrls,
  });

  @override
  List<Object?> get props =>
      [designerId, shopId, name, nickname, intro, photoUrls];
}
