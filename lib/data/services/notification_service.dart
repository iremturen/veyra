import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:veyra/app/common/constants/app_strings.dart';

class NotificationService {
  NotificationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> sendNotification({
    required String targetUserId,
    required String type,
    required String message,
    required String postId,
    String? postImageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.uid == targetUserId) return;

    try {
      final displayName = user.displayName?.trim();
      final emailName = user.email?.split('@').first.trim();

      var senderName = displayName?.isNotEmpty == true
          ? displayName!
          : emailName?.isNotEmpty == true
              ? emailName!
              : AppStrings.feedMemberFallback;
      var senderPhotoUrl = user.photoURL?.trim();

      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final docData = userDoc.data();
        final docPhoto = (docData?['photoUrl'] ??
                docData?['photoURL'] ??
                docData?['profileImageUrl'] ??
                docData?['avatarUrl'] ??
                docData?['photo']) as String?;
        if (docPhoto?.trim().isNotEmpty == true) {
          senderPhotoUrl = docPhoto!.trim();
        }
        final docUsername = (docData?['username'] ??
                docData?['displayName'] ??
                docData?['name']) as String?;
        if (docUsername?.trim().isNotEmpty == true) {
          senderName = docUsername!.trim();
        }
      } catch (_) {}

      if (senderPhotoUrl == null || senderPhotoUrl.isEmpty) {
        try {
          final postsQuery = await _firestore
              .collection('posts')
              .where('authorId', isEqualTo: user.uid)
              .limit(1)
              .get();
          if (postsQuery.docs.isNotEmpty) {
            final postData = postsQuery.docs.first.data();
            final postPhoto = (postData['authorPhotoUrl'] ??
                    postData['photoUrl'] ??
                    postData['profileImageUrl']) as String?;
            if (postPhoto?.trim().isNotEmpty == true) {
              senderPhotoUrl = postPhoto!.trim();
            }
          }
        } catch (_) {}
      }

      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('notifications')
          .add({
        'type': type,
        'senderId': user.uid,
        'senderName': senderName,
        'senderPhotoUrl': senderPhotoUrl,
        'photoUrl': senderPhotoUrl,
        'postId': postId,
        'postImageUrl': postImageUrl,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('NotificationService sendNotification error: $e');
    }
  }
}
