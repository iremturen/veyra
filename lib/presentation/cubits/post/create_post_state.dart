import 'package:image_picker/image_picker.dart';
import 'package:veyra/presentation/cubits/post/create_post_status.dart';

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
