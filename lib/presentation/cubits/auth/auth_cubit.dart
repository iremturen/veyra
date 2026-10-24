import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/core/error/result.dart';
import 'package:veyra/domain/entities/auth_user.dart';
import 'package:veyra/domain/repositories/auth_repository.dart';
import 'package:veyra/presentation/cubits/auth/auth_state.dart';
import 'package:veyra/presentation/cubits/auth/auth_status.dart';

export 'auth_state.dart';
export 'auth_status.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> restoreCurrentSession() async {
    final currentUser = _repository.currentUser;
    if (currentUser == null) {
      emit(const AuthState(status: AuthStatus.signedOut));
      return;
    }

    emit(const AuthState(status: AuthStatus.loading));
    final result = await _repository.reloadUser();
    _emitResult(
      result,
      onSuccess: (user) => AuthState(
        status: user.emailVerified
            ? AuthStatus.sessionRestored
            : AuthStatus.emailNotVerified,
        user: user,
      ),
    );
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    emit(const AuthState(status: AuthStatus.loading));
    final result = await _repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
    _emitResult(
      result,
      onSuccess: (user) => AuthState(status: AuthStatus.success, user: user),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthState(status: AuthStatus.loading));
    final result = await _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    _emitResult(
      result,
      onSuccess: (user) => AuthState(status: AuthStatus.success, user: user),
    );
  }

  Future<void> sendVerificationEmail() async {
    emit(const AuthState(status: AuthStatus.loading));
    final result = await _repository.sendEmailVerification();
    _emitResult(
      result,
      onSuccess: (_) =>
          const AuthState(status: AuthStatus.verificationEmailSent),
    );
  }

  Future<void> checkEmailVerified() async {
    emit(const AuthState(status: AuthStatus.loading));
    final result = await _repository.checkEmailVerified(reload: true);
    _emitResult(
      result,
      onSuccess: (isVerified) => AuthState(
        status: isVerified
            ? AuthStatus.emailVerified
            : AuthStatus.emailNotVerified,
      ),
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    emit(const AuthState(status: AuthStatus.loading));
    final result = await _repository.sendPasswordResetEmail(email: email);
    _emitResult(
      result,
      onSuccess: (_) =>
          const AuthState(status: AuthStatus.passwordResetEmailSent),
    );
  }

  Future<void> signOut() async {
    emit(const AuthState(status: AuthStatus.loading));
    final result = await _repository.signOut();
    _emitResult(
      result,
      onSuccess: (_) => const AuthState(status: AuthStatus.signedOut),
    );
  }

  AuthUser? get currentUser => _repository.currentUser;

  void _emitResult<T>(
    Result<T> result, {
    required AuthState Function(T value) onSuccess,
  }) {
    result.when(
      success: (value) => emit(onSuccess(value)),
      failure: (failure) =>
          emit(AuthState(status: AuthStatus.failure, message: failure.message)),
    );
  }
}
