import 'package:veyra/core/error/auth_failure_type.dart';
import 'package:veyra/core/error/failure.dart';

/// Data-layer exception that wraps provider-specific auth errors
/// without exposing Firebase types to the repository interface.
class AuthException implements Exception {
  const AuthException(this.type, {this.code});

  final AuthFailureType type;
  final String? code;

  AuthFailure toFailure() => AuthFailure.fromType(type);

  @override
  String toString() => 'AuthException(type: $type, code: $code)';
}
