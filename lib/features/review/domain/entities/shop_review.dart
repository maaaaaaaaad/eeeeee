import 'package:equatable/equatable.dart';

class ShopReview extends Equatable {
  final String id;
  final String shopId;
  final String memberId;
  final String? shopName;
  final String? shopImage;
  final String? authorName;
  final int? rating;
  final String? content;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? ownerReplyContent;
  final DateTime? ownerReplyCreatedAt;

  const ShopReview({
    required this.id,
    required this.shopId,
    required this.memberId,
    this.shopName,
    this.shopImage,
    this.authorName,
    this.rating,
    this.content,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    this.ownerReplyContent,
    this.ownerReplyCreatedAt,
  });

  bool get isEdited => updatedAt != createdAt;

  bool get hasContent => content != null && content!.isNotEmpty;

  bool get hasReply => ownerReplyContent != null;

  String get maskedAuthorName {
    if (authorName == null || authorName!.isEmpty) return '';
    if (authorName!.length <= 1) return authorName!;
    return '${authorName![0]}${'*' * (authorName!.length - 1)}';
  }

  @override
  List<Object?> get props => [id];
}
