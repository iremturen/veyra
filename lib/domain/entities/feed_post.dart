import 'package:equatable/equatable.dart';

class FeedPost extends Equatable {
  final String id;
  final String? authorId;
  final int? likeCount;
  final String authorName;
  final String caption;
  final DateTime? createdAt;
  final String? authorPhotoUrl;
  final String? imageUrl;

  const FeedPost({
    required this.id,
    this.authorId,
    this.likeCount,
    required this.authorName,
    required this.caption,
    required this.createdAt,
    this.authorPhotoUrl,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    authorId,
    likeCount,
    authorName,
    caption,
    createdAt,
    authorPhotoUrl,
    imageUrl,
  ];
}
