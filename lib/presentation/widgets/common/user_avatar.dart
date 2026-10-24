import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/models/custom_icon_model.dart';
import 'package:veyra/app/common/models/custom_image_model.dart';
import 'package:veyra/app/common/widgets/custom_icon.dart';
import 'package:veyra/app/common/widgets/custom_image.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    this.userId,
    this.fallbackPhoto,
    required this.size,
    super.key,
  });

  final String? userId;
  final String? fallbackPhoto;
  final double size;

  @override
  Widget build(BuildContext context) {
    final trimmedId = userId?.trim();
    final fallback = fallbackPhoto?.trim();
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentAuthPhoto =
        (trimmedId != null && trimmedId == currentUser?.uid)
            ? currentUser?.photoURL?.trim()
            : null;

    final baseFallback = (fallback?.isNotEmpty == true)
        ? fallback
        : (currentAuthPhoto?.isNotEmpty == true ? currentAuthPhoto : null);

    if (trimmedId == null || trimmedId.isEmpty) {
      return _avatarImage(baseFallback);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(trimmedId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final firestorePhoto = (data?['photoUrl'] ??
                data?['photoURL'] ??
                data?['profileImageUrl'] ??
                data?['avatarUrl'] ??
                data?['photo'] ??
                data?['imageUrl']) as String?;

        final photoUrl = (firestorePhoto?.trim().isNotEmpty == true)
            ? firestorePhoto!.trim()
            : baseFallback;
        return _avatarImage(photoUrl);
      },
    );
  }

  Widget _avatarImage(String? photoUrl) {
    final url = photoUrl?.trim();
    if (url == null || url.isEmpty) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.primarySoft,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: CustomIcon(
            model: CustomIconModel(
              icon: CupertinoIcons.person_fill,
              size: size * 0.5,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (url.startsWith('assets/')) {
      return CustomImage(
        model: CustomImageModel(
          assetPath: url,
          width: size,
          height: size,
          borderRadius: BorderRadius.circular(size / 2),
        ),
      );
    }

    return CustomImage(
      model: CustomImageModel(
        imageUrl: url,
        width: size,
        height: size,
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }
}
