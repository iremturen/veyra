import 'package:veyra/domain/entities/feed_post.dart';
import 'package:veyra/presentation/cubits/feed/feed_status.dart';

class FeedState {
  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.errorMessage,
  });

  final FeedStatus status;
  final List<FeedPost> posts;
  final String? errorMessage;
}
