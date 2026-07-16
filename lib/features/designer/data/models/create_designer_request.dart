class CreateDesignerRequest {
  final String name;
  final String? nickname;
  final String? intro;
  final List<String>? photoUrls;

  const CreateDesignerRequest({
    required this.name,
    this.nickname,
    this.intro,
    this.photoUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nickname': nickname,
      'intro': intro,
      'photoUrls': photoUrls,
    };
  }
}
