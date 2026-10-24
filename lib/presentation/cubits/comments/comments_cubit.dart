import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/data/services/notification_service.dart';
import 'package:veyra/domain/entities/app_notification.dart';
import 'package:veyra/domain/entities/post_comment.dart';
import 'package:veyra/presentation/cubits/comments/comments_state.dart';
import 'package:veyra/presentation/cubits/comments/comments_status.dart';

export 'comments_state.dart';
export 'comments_status.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit({
    required this.postId,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    NotificationService? notificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _notificationService = notificationService ?? NotificationService(),
        super(const CommentsState());

  final String postId;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NotificationService _notificationService;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  void watchComments() {
    emit(state.copyWith(status: CommentsStatus.loading, errorMessage: null));
    _subscription?.cancel();
    _subscription = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen(
      (snapshot) {
        final comments = snapshot.docs.map((doc) {
          final data = doc.data();

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

          return PostComment(
            id: doc.id,
            authorId: stringValue('authorId') ?? '',
            authorName: stringValue('authorName') ??
                stringValue('username') ??
                stringValue('displayName') ??
                AppStrings.feedMemberFallback,
            authorPhotoUrl: stringValue('authorPhotoUrl') ??
                stringValue('photoUrl') ??
                stringValue('profileImageUrl'),
            text: stringValue('text') ?? '',
            createdAt: createdAt,
          );
        }).toList();

        if (!isClosed) {
          emit(
            state.copyWith(
              status: CommentsStatus.loaded,
              comments: comments,
            ),
          );
        }
      },
      onError: (Object error) {
        debugPrint('CommentsCubit watchComments error: $error');
        if (!isClosed) {
          emit(
            state.copyWith(
              status: CommentsStatus.failure,
              errorMessage: AppStrings.commentsLoadFailed,
            ),
          );
        }
      },
    );
  }

  Future<bool> addComment(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty || state.isSubmitting) return false;

    final user = _auth.currentUser;
    if (user == null || !user.emailVerified) {
      emit(
        state.copyWith(
          submitErrorMessage: AppStrings.commentSignInRequired,
        ),
      );
      return false;
    }

    emit(state.copyWith(isSubmitting: true, submitErrorMessage: null));

    try {
      final displayName = user.displayName?.trim();
      final emailName = user.email?.split('@').first.trim();

      var authorName = displayName?.isNotEmpty == true
          ? displayName!
          : emailName?.isNotEmpty == true
              ? emailName!
              : AppStrings.feedMemberFallback;
      var authorPhotoUrl = user.photoURL?.trim();

      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final docData = userDoc.data();
        final docPhoto = docData?['photoUrl'] as String?;
        if (docPhoto?.trim().isNotEmpty == true) {
          authorPhotoUrl = docPhoto!.trim();
        }
        final docUsername = docData?['username'] as String?;
        if (docUsername?.trim().isNotEmpty == true) {
          authorName = docUsername!.trim();
        }
      } catch (_) {}

      final commentRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc();

      await commentRef.set({
        'authorId': user.uid,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'text': trimmedText,
        'createdAt': FieldValue.serverTimestamp(),
      });

      try {
        final postDoc =
            await _firestore.collection('posts').doc(postId).get();
        final postData = postDoc.data();
        final postAuthorId = postData?['authorId'] as String?;
        final postImageUrl = postData?['imageUrl'] as String?;

        if (postAuthorId != null && postAuthorId != user.uid) {
          await _notificationService.sendNotification(
            targetUserId: postAuthorId,
            type: AppNotification.typeComment,
            message: AppStrings.commented(trimmedText),
            postId: postId,
            postImageUrl: postImageUrl,
          );
        }
      } catch (e) {
        debugPrint('CommentsCubit sendNotification error: $e');
      }

      if (!isClosed) {
        emit(state.copyWith(isSubmitting: false));
      }
      return true;
    } on FirebaseException catch (e) {
      debugPrint('CommentsCubit addComment FirebaseException: $e');
      if (!isClosed) {
        emit(
          state.copyWith(
            isSubmitting: false,
            submitErrorMessage: AppStrings.commentSubmitFailed,
          ),
        );
      }
      return false;
    } catch (e) {
      debugPrint('CommentsCubit addComment error: $e');
      if (!isClosed) {
        emit(
          state.copyWith(
            isSubmitting: false,
            submitErrorMessage: AppStrings.commentSubmitFailed,
          ),
        );
      }
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
