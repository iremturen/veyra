import 'package:veyra/presentation/cubits/profile/edit_profile_status.dart';

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
