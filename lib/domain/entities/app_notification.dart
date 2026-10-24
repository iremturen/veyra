import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  static const String typeLike = 'like';
  static const String typeComment = 'comment';

  final String id;
  final String type;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String postId;
  final String? postImageUrl;
  final String message;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.postId,
    this.postImageUrl,
    required this.message,
    this.createdAt,
  });

  bool get isComment => type == typeComment;
  bool get isLike => type == typeLike;

  @override
  List<Object?> get props => [
    id,
    type,
    senderId,
    senderName,
    senderPhotoUrl,
    postId,
    postImageUrl,
    message,
    createdAt,
  ];
}
