import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    this.message,
  });

  final EditProfileStatus status;
  final String username;
  final String email;
  final String bio;
  final String? message;
}

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(const EditProfileState());

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  void updateBio(String bio) {
    if (state.status == EditProfileStatus.saving ||
        state.status == EditProfileStatus.loading ||
        state.status == EditProfileStatus.loadFailure) {
      return;
    }
    emit(
      EditProfileState(
        status: EditProfileStatus.editing,
        username: state.username,
        email: state.email,
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
    try {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      final username = snapshot.data()?['username'];
      final bio = snapshot.data()?['bio'];
      emit(
        EditProfileState(
          status: EditProfileStatus.loaded,
          username: username is String && username.trim().isNotEmpty
              ? username.trim()
              : AppStrings.profileUsernameUnavailable,
          email: user.email ?? '',
          bio: bio is String ? bio : '',
        ),
      );
    } on FirebaseException catch (error) {
      debugPrint(
        'Edit profile load failed (${error.code}): ${error.message}',
      );
      emit(
        EditProfileState(
          status: EditProfileStatus.loadFailure,
          username: AppStrings.profileUsernameUnavailable,
          email: user.email ?? '',
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
          username: AppStrings.profileUsernameUnavailable,
          email: user.email ?? '',
          message: AppStrings.profileDetailsLoadFailed,
        ),
      );
    }
  }

  Future<void> saveBio(String bio) async {
    if (state.status == EditProfileStatus.saving) return;

    final user = _auth.currentUser;
    if (user == null) {
      emit(
        EditProfileState(
          status: EditProfileStatus.saveFailure,
          username: state.username,
          email: state.email,
          bio: bio,
          message: AppStrings.profileUnavailable,
        ),
      );
      return;
    }

    emit(
      EditProfileState(
        status: EditProfileStatus.saving,
        username: state.username,
        email: state.email,
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
          EditProfileState(
            status: EditProfileStatus.saved,
            username: state.username,
            email: state.email,
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
          EditProfileState(
            status: EditProfileStatus.saveFailure,
            username: state.username,
            email: state.email,
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
          EditProfileState(
            status: EditProfileStatus.saveFailure,
            username: state.username,
            email: state.email,
            bio: bio,
            message: AppStrings.profileSaveFailed,
          ),
        );
      }
    }
  }
}
