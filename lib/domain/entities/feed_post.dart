import 'package:equatable/equatable.dart';
//model burda mı olmalı
class FeedPost extends Equatable {
  final String id;
  final String? authorId;
  final int likeCount;
  final List<String> likedUserIds;
  final String authorName;
  final String caption;
  final DateTime? createdAt;
  final String? authorPhotoUrl;
  final String? imageUrl;

  const FeedPost({
    required this.id,
    this.authorId,
    this.likeCount = 0,
    this.likedUserIds = const [],
    required this.authorName,
    required this.caption,
    required this.createdAt,
    this.authorPhotoUrl,
    this.imageUrl,
  });

  bool isLikedBy(String? userId) =>
      userId != null && likedUserIds.contains(userId);

  @override
  List<Object?> get props => [
    id,
    authorId,
    likeCount,
    likedUserIds,
    authorName,
    caption,
    createdAt,
    authorPhotoUrl,
    imageUrl,
  ];
}
