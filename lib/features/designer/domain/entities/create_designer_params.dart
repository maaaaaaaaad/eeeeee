import 'package:equatable/equatable.dart';

class CreateDesignerParams extends Equatable {
  final String shopId;
  final String name;
  final String? nickname;
  final String? intro;
  final List<String> photoUrls;

  const CreateDesignerParams({
    required this.shopId,
    required this.name,
    this.nickname,
    this.intro,
    this.photoUrls = const [],
  });

  @override
  List<Object?> get props => [shopId, name, nickname, intro, photoUrls];
}
