import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_strings.dart';

enum EditProfileStatus {
  initial,
  loading,
  loaded,
  editing,
  saving,
  saved,
  loadFailure,
  saveFailure,
}

class EditProfileState {
  const EditProfileState({
    this.status = EditProfileStatus.initial,
    this.username = '',
    this.email = '',
    this.bio = '',
    this.photoUrl,
    this.message,
    this.isUploadingPhoto = false,
  });

  final EditProfileStatus status;
  final String username;
  final String email;
  final String bio;
  final String? photoUrl;
  final String? message;
  final bool isUploadingPhoto;

  EditProfileState copyWith({
    EditProfileStatus? status,
    String? username,
    String? email,
    String? bio,
    String? photoUrl,
    String? message,
    bool? isUploadingPhoto,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      message: message,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
    );
  }
}

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    ImagePicker? imagePicker,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _imagePicker = imagePicker ?? ImagePicker(),
       super(const EditProfileState());

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final ImagePicker _imagePicker;

  void updateBio(String bio) {
    if (state.status == EditProfileStatus.saving ||
        state.status == EditProfileStatus.loading ||
        state.status == EditProfileStatus.loadFailure) {
      return;
    }
    emit(
      state.copyWith(
        status: EditProfileStatus.editing,
        bio: bio,
      ),
    );
  }

  Future<void> loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(
        const EditProfileState(
          status: EditProfileStatus.loadFailure,
          message: AppStrings.profileUnavailable,
        ),
      );
      return;
    }

    emit(const EditProfileState(status: EditProfileStatus.loading));
    final displayName = user.displayName?.trim();
    final emailName = user.email?.split('@').first.trim();
    final fallbackUsername = displayName?.isNotEmpty == true
        ? displayName!
        : emailName?.isNotEmpty == true
            ? emailName!
            : AppStrings.profileUsernameUnavailable;

    try {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      final username = snapshot.data()?['username'];
      final bio = snapshot.data()?['bio'];
      final photoUrl = snapshot.data()?['photoUrl'] as String?;
      emit(
        EditProfileState(
          status: EditProfileStatus.loaded,
          username: username is String && username.trim().isNotEmpty
              ? username.trim()
              : fallbackUsername,
          email: user.email ?? '',
          bio: bio is String ? bio : '',
          photoUrl: photoUrl?.trim().isNotEmpty == true
              ? photoUrl!.trim()
              : user.photoURL,
        ),
      );
    } on FirebaseException catch (error) {
      debugPrint(
        'Edit profile load failed (${error.code}): ${error.message}',
      );
      emit(
        EditProfileState(
          status: EditProfileStatus.loadFailure,
          username: fallbackUsername,
          email: user.email ?? '',
          photoUrl: user.photoURL,
          message: error.code == 'permission-denied'
              ? AppStrings.profileReadPermissionDenied
              : AppStrings.profileDetailsLoadFailed,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Edit profile load failed: $error\n$stackTrace');
      emit(
        EditProfileState(
          status: EditProfileStatus.loadFailure,
          username: fallbackUsername,
          email: user.email ?? '',
          photoUrl: user.photoURL,
          message: AppStrings.profileDetailsLoadFailed,
        ),
      );
    }
  }

  Future<void> updateProfilePhoto() async {
    final user = _auth.currentUser;
    if (user == null || state.isUploadingPhoto) return;

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: AppDimensions.createPostImageQuality,
      );
      if (image == null || isClosed) return;

      emit(state.copyWith(isUploadingPhoto: true));

      final extension = _fileExtension(image.name);
      final storageRef = _storage.ref().child(
        'users/${user.uid}/profile_${DateTime.now().millisecondsSinceEpoch}.$extension',
      );

      await storageRef.putFile(
        File(image.path),
        SettableMetadata(contentType: _contentType(extension)),
      );

      final downloadUrl = await storageRef.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);

      await _firestore.collection('users').doc(user.uid).set({
        'photoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!isClosed) {
        emit(
          state.copyWith(
            photoUrl: downloadUrl,
            isUploadingPhoto: false,
          ),
        );
      }
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'Edit profile photo upload failed (${error.code}): ${error.message}\n$stackTrace',
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            isUploadingPhoto: false,
            message: AppStrings.photoUploadFailed,
          ),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Edit profile photo upload failed: $error\n$stackTrace');
      if (!isClosed) {
        emit(
          state.copyWith(
            isUploadingPhoto: false,
            message: AppStrings.photoUploadFailed,
          ),
        );
      }
    }
  }

  Future<void> saveBio(String bio) async {
    if (state.status == EditProfileStatus.saving) return;

    final user = _auth.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          status: EditProfileStatus.saveFailure,
          bio: bio,
          message: AppStrings.profileUnavailable,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: EditProfileStatus.saving,
        bio: bio,
      ),
    );
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'bio': bio.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!isClosed) {
        emit(
          state.copyWith(
            status: EditProfileStatus.saved,
            bio: bio.trim(),
          ),
        );
      }
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'Edit profile save failed (${error.code}): ${error.message}\n$stackTrace',
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            status: EditProfileStatus.saveFailure,
            bio: bio,
            message: error.code == 'permission-denied'
                ? AppStrings.profileWritePermissionDenied
                : AppStrings.profileSaveFailed,
          ),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Edit profile save failed: $error\n$stackTrace');
      if (!isClosed) {
        emit(
          state.copyWith(
            status: EditProfileStatus.saveFailure,
            bio: bio,
            message: AppStrings.profileSaveFailed,
          ),
        );
      }
    }
  }
}

String _fileExtension(String fileName) {
  final dotIndex = fileName.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == fileName.length - 1) {
    return 'jpg';
  }
  return fileName.substring(dotIndex + 1).toLowerCase();
}

String _contentType(String extension) {
  return switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    'gif' => 'image/gif',
    'heic' => 'image/heic',
    _ => 'image/jpeg',
  };
}
