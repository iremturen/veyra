import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/domain/entities/app_notification.dart';
import 'package:veyra/presentation/cubits/notifications/notifications_state.dart';
import 'package:veyra/presentation/cubits/notifications/notifications_status.dart';

export 'notifications_state.dart';
export 'notifications_status.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const NotificationsState());

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  StreamSubscription<User?>? _authSubscription;

  void watchNotifications() {
    _authSubscription?.cancel();
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user == null) {
        _subscription?.cancel();
        if (!isClosed) {
          emit(const NotificationsState(status: NotificationsStatus.loaded));
        }
        return;
      }
      _subscribeToUserNotifications(user.uid);
    });
  }

  void _subscribeToUserNotifications(String uid) {
    emit(state.copyWith(status: NotificationsStatus.loading));
    _subscription?.cancel();
    _subscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final notifications = snapshot.docs.map((doc) {
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

          return AppNotification(
            id: doc.id,
            type: stringValue('type') ?? 'like',
            senderId: stringValue('senderId') ??
                stringValue('authorId') ??
                stringValue('userId') ??
                stringValue('senderUid') ??
                stringValue('fromUserId') ??
                '',
            senderName: stringValue('senderName') ??
                stringValue('authorName') ??
                stringValue('username') ??
                stringValue('displayName') ??
                AppStrings.feedMemberFallback,
            senderPhotoUrl: stringValue('senderPhotoUrl') ??
                stringValue('photoUrl') ??
                stringValue('photoURL') ??
                stringValue('authorPhotoUrl') ??
                stringValue('profileImageUrl') ??
                stringValue('avatarUrl') ??
                stringValue('userPhotoUrl') ??
                stringValue('senderPhoto'),
            postId: stringValue('postId') ?? '',
            postImageUrl: stringValue('postImageUrl') ??
                stringValue('imageUrl') ??
                stringValue('mediaUrl'),
            message: stringValue('message') ?? '',
            createdAt: createdAt,
          );
        }).toList();

        if (!isClosed) {
          emit(
            state.copyWith(
              status: NotificationsStatus.loaded,
              notifications: notifications,
            ),
          );
        }
      },
      onError: (Object error) {
        debugPrint('NotificationsCubit error: $error');
        if (!isClosed) {
          emit(
            state.copyWith(
              status: NotificationsStatus.failure,
              errorMessage: AppStrings.notificationsLoadFailed,
            ),
          );
        }
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _authSubscription?.cancel();
    return super.close();
  }
}
