import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/domain/entities/feed_post.dart';

enum FeedStatus { initial, loading, loaded, failure }

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

class FeedCubit extends Cubit<FeedState> {
  FeedCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(const FeedState());

  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  void watchPosts() {
    emit(const FeedState(status: FeedStatus.loading));
    _subscription?.cancel();
    _subscription = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final posts = snapshot.docs.map((document) {
              final data = document.data();

              String? stringValue(String key) {
                final value = data[key];
                return value is String && value.trim().isNotEmpty
                    ? value.trim()
                    : null;
              }

              final createdAtValue = data['createdAt'];
              final createdAt = switch (createdAtValue) {
                Timestamp timestamp => timestamp.toDate(),
                DateTime dateTime => dateTime,
                _ => null,
              };
              final rawLikeCount = data['likeCount'] ?? data['likesCount'];
              final rawLikes = data['likes'];
              final likeCount = switch (rawLikeCount) {
                num value => value.toInt().clamp(0, 0x7fffffff).toInt(),
                _ when rawLikes is List => rawLikes.length,
                _ when rawLikes is Map => rawLikes.length,
                _ => null,
              };

              return FeedPost(
                id: document.id,
                authorId: stringValue('authorId'),
                likeCount: likeCount,
                authorName:
                    stringValue('authorName') ??
                    stringValue('displayName') ??
                    stringValue('username') ??
                    AppStrings.feedMemberFallback,
                caption: stringValue('caption') ?? '',
                createdAt: createdAt,
                authorPhotoUrl:
                    stringValue('authorPhotoUrl') ??
                    stringValue('photoUrl') ??
                    stringValue('profileImageUrl') ??
                    stringValue('userPhotoUrl'),
                imageUrl: stringValue('imageUrl') ?? stringValue('mediaUrl'),
              );
            }).toList();
            emit(FeedState(status: FeedStatus.loaded, posts: posts));
          },
          onError: (Object error) {
            emit(
              FeedState(
                status: FeedStatus.failure,
                errorMessage: error.toString(),
              ),
            );
          },
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
