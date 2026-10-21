import 'package:equatable/equatable.dart';
import 'package:veyra/core/error/auth_failure_messages.dart';
import 'package:veyra/core/error/auth_failure_type.dart';

/// Base failure type for domain/data error results.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Authentication-specific failures with typed categories.
final class AuthFailure extends Failure {
  final AuthFailureType type;

  const AuthFailure({required this.type, required String message})
    : super(message);

  factory AuthFailure.fromType(AuthFailureType type) {
    return AuthFailure(type: type, message: _messageFor(type));
  }

  static String _messageFor(AuthFailureType type) {
    return switch (type) {
      AuthFailureType.invalidEmail => AuthFailureMessages.invalidEmail,
      AuthFailureType.wrongPassword => AuthFailureMessages.wrongPassword,
      AuthFailureType.userNotFound => AuthFailureMessages.userNotFound,
      AuthFailureType.emailAlreadyInUse =>
        AuthFailureMessages.emailAlreadyInUse,
      AuthFailureType.weakPassword => AuthFailureMessages.weakPassword,
      AuthFailureType.networkError => AuthFailureMessages.networkError,
      AuthFailureType.userDisabled => AuthFailureMessages.userDisabled,
      AuthFailureType.tooManyRequests => AuthFailureMessages.tooManyRequests,
      AuthFailureType.operationNotAllowed =>
        AuthFailureMessages.operationNotAllowed,
      AuthFailureType.requiresRecentLogin =>
        AuthFailureMessages.requiresRecentLogin,
      AuthFailureType.invalidCredential =>
        AuthFailureMessages.invalidCredential,
      AuthFailureType.unexpected => AuthFailureMessages.unexpected,
    };
  }

  @override
  List<Object?> get props => [type, message];
}
