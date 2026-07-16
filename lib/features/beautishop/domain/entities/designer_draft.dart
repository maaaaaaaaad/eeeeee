import 'package:equatable/equatable.dart';

class DesignerDraft extends Equatable {
  final String name;
  final String? nickname;
  final String? intro;
  final List<String> photoUrls;

  const DesignerDraft({
    required this.name,
    this.nickname,
    this.intro,
    this.photoUrls = const [],
  });

  DesignerDraft copyWith({
    String? name,
    String? Function()? nickname,
    String? Function()? intro,
    List<String>? photoUrls,
  }) {
    return DesignerDraft(
      name: name ?? this.name,
      nickname: nickname != null ? nickname() : this.nickname,
      intro: intro != null ? intro() : this.intro,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }

  @override
  List<Object?> get props => [name, nickname, intro, photoUrls];
}
