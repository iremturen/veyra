import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_strings.dart';

enum CreatePostStatus { initial, loading, success, failure }

class CreatePostState {
  const CreatePostState({
    this.selectedImage,
    this.status = CreatePostStatus.initial,
    this.message,
  });

  final XFile? selectedImage;
  final CreatePostStatus status;
  final String? message;

  bool get isLoading => status == CreatePostStatus.loading;

  CreatePostState copyWith({
    XFile? selectedImage,
    CreatePostStatus? status,
    String? message,
  }) {
    return CreatePostState(
      selectedImage: selectedImage ?? this.selectedImage,
      status: status ?? this.status,
      message: message,
    );
  }
}

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit({
    required XFile initialImage,
    ImagePicker? imagePicker,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _imagePicker = imagePicker ?? ImagePicker(),
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       super(CreatePostState(selectedImage: initialImage));

  final ImagePicker _imagePicker;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<void> selectPhoto() async {
    if (state.isLoading) return;

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: AppDimensions.createPostImageQuality,
      );

      if (isClosed || image == null) return;

      emit(CreatePostState(selectedImage: image));
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: CreatePostStatus.failure,
            message: AppStrings.photoSelectFailed,
          ),
        );
      }
    }
  }

  Future<void> sharePost({required String caption}) async {
    final image = state.selectedImage;

    if (state.isLoading || image == null) return;

    final user = _auth.currentUser;

    if (user == null || !user.emailVerified) {
      emit(
        state.copyWith(
          status: CreatePostStatus.failure,
          message: AppStrings.postSignInRequired,
        ),
      );
      return;
    }

    emit(state.copyWith(status: CreatePostStatus.loading));

    Reference? storageReference;
    var photoUploaded = false;

    try {
      final postReference = _firestore.collection('posts').doc();
      final extension = _fileExtension(image.name);

      storageReference = _storage.ref().child(
        'posts/${user.uid}/${postReference.id}.$extension',
      );

      // 1. Upload the image to Firebase Storage.
      await storageReference.putFile(
        File(image.path),
        SettableMetadata(contentType: _contentType(extension)),
      );

      photoUploaded = true;

      // 2. Get the image download URL.
      final imageUrl = await storageReference.getDownloadURL();

      // 3. Determine the author's display name.
      final displayName = user.displayName?.trim();
      final emailName = user.email?.split('@').first.trim();

      final authorName = displayName?.isNotEmpty == true
          ? displayName!
          : emailName?.isNotEmpty == true
          ? emailName!
          : AppStrings.feedMemberFallback;

      // 4. Save the post to Firestore.
      await postReference.set({
        'authorId': user.uid,
        'authorName': authorName,
        'authorPhotoUrl': user.photoURL,
        'caption': caption.trim(),
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 5. Report success to the UI.
      if (!isClosed) {
        emit(state.copyWith(status: CreatePostStatus.success));
      }
    } on FirebaseException catch (_) {
      if (photoUploaded) {
        await _removeUploadedPhoto(storageReference);
      }

      if (!isClosed) {
        emit(
          state.copyWith(
            status: CreatePostStatus.failure,
            message: photoUploaded
                ? AppStrings.postPublishFailed
                : AppStrings.photoUploadFailed,
          ),
        );
      }
    } catch (_) {
      if (photoUploaded) {
        await _removeUploadedPhoto(storageReference);
      }

      if (!isClosed) {
        emit(
          state.copyWith(
            status: CreatePostStatus.failure,
            message: photoUploaded
                ? AppStrings.postPublishFailed
                : AppStrings.photoUploadFailed,
          ),
        );
      }
    }
  }

  Future<void> _removeUploadedPhoto(Reference? reference) async {
    if (reference == null) return;

    try {
      await reference.delete();
    } on FirebaseException {
      // Cleanup can fail if Storage rules deny deletion.
    }
  }

  String _fileExtension(String fileName) {
    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'jpg';

    const supportedExtensions = {
      'jpg',
      'jpeg',
      'png',
      'webp',
      'heic',
      'heif',
    };

    return supportedExtensions.contains(extension) ? extension : 'jpg';
  }

  String _contentType(String extension) => switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    'heic' => 'image/heic',
    'heif' => 'image/heif',
    _ => 'image/jpeg',
  };
}