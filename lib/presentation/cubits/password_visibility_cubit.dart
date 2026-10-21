import 'package:flutter_bloc/flutter_bloc.dart';

class PasswordVisibilityState {
  const PasswordVisibilityState({
    this.passwordVisible = false,
    this.confirmPasswordVisible = false,
  });

  final bool passwordVisible;
  final bool confirmPasswordVisible;
}

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
