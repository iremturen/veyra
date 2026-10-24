import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/presentation/cubits/auth/password_visibility_state.dart';

export 'password_visibility_state.dart';

class PasswordVisibilityCubit extends Cubit<PasswordVisibilityState> {
  PasswordVisibilityCubit() : super(const PasswordVisibilityState());

  void togglePasswordVisibility() {
    emit(
      PasswordVisibilityState(
        passwordVisible: !state.passwordVisible,
        confirmPasswordVisible: state.confirmPasswordVisible,
      ),
    );
  }

  void toggleConfirmPasswordVisibility() {
    emit(
      PasswordVisibilityState(
        passwordVisible: state.passwordVisible,
        confirmPasswordVisible: !state.confirmPasswordVisible,
      ),
    );
  }
}
