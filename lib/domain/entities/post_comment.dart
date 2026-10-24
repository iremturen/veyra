import 'package:equatable/equatable.dart';

class PostComment extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String text;
  final DateTime? createdAt;

  const PostComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.text,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    authorId,
    authorName,
    authorPhotoUrl,
    text,
    createdAt,
  ];
}
