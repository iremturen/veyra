import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/data/services/notification_service.dart';
import 'package:veyra/domain/entities/app_notification.dart';
import 'package:veyra/domain/entities/feed_post.dart';
import 'package:veyra/presentation/cubits/feed/feed_state.dart';
import 'package:veyra/presentation/cubits/feed/feed_status.dart';

export 'feed_state.dart';
export 'feed_status.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    NotificationService? notificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _notificationService = notificationService ?? NotificationService(),
        super(const FeedState());

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NotificationService _notificationService;
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
              final rawLikes = data['likes'];
              final likedUserIds = switch (rawLikes) {
                List list => list.whereType<String>().toList(),
                Map map => map.keys.whereType<String>().toList(),
                _ => const <String>[],
              };
              final rawLikeCount = data['likeCount'] ?? data['likesCount'];
              final likeCount = switch (rawLikeCount) {
                num value => value.toInt().clamp(0, 0x7fffffff).toInt(),
                _ => likedUserIds.length,
              };

              return FeedPost(
                id: document.id,
                authorId: stringValue('authorId'),
                likeCount: likeCount,
                likedUserIds: likedUserIds,
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

  Future<void> toggleLike(FeedPost post) async {
    final user = _auth.currentUser;
    if (user == null || !user.emailVerified) return;

    final isLiked = post.isLikedBy(user.uid);
    final postRef = _firestore.collection('posts').doc(post.id);

    try {
      if (isLiked) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([user.uid]),
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([user.uid]),
          'likeCount': FieldValue.increment(1),
        });

        if (post.authorId != null && post.authorId != user.uid) {
          await _notificationService.sendNotification(
            targetUserId: post.authorId!,
            type: AppNotification.typeLike,
            message: AppStrings.likedYourPost,
            postId: post.id,
            postImageUrl: post.imageUrl,
          );
        }
      }
    } catch (e) {
      debugPrint('FeedCubit toggleLike error: $e');
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
