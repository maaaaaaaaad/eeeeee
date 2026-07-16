import 'package:equatable/equatable.dart';

class Designer extends Equatable {
  final String id;
  final String shopId;
  final String name;
  final String? nickname;
  final String? intro;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Designer({
    required this.id,
    required this.shopId,
    required this.name,
    this.nickname,
    this.intro,
    this.photoUrls = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id];
}
