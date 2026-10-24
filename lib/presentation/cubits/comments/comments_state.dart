import 'package:veyra/domain/entities/post_comment.dart';
import 'package:veyra/presentation/cubits/comments/comments_status.dart';

class CommentsState {
  final CommentsStatus status;
  final List<PostComment> comments;
  final String? errorMessage;
  final bool isSubmitting;
  final String? submitErrorMessage;

  const CommentsState({
    this.status = CommentsStatus.initial,
    this.comments = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.submitErrorMessage,
  });

  CommentsState copyWith({
    CommentsStatus? status,
    List<PostComment>? comments,
    String? errorMessage,
    bool? isSubmitting,
    String? submitErrorMessage,
  }) {
    return CommentsState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitErrorMessage: submitErrorMessage,
    );
  }
}
