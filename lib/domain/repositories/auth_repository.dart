import 'package:veyra/core/error/result.dart';
import 'package:veyra/domain/entities/auth_user.dart';

/// Abstraction for authentication operations.
///
/// Implementations live in the data layer; this interface must not
/// depend on Firebase SDK types.
abstract class AuthRepository {
  /// Emits the current user whenever auth state changes.
  /// Emits `null` when signed out.
  Stream<AuthUser?> get authStateChanges;

  /// Currently signed-in user, or `null` if none.
  AuthUser? get currentUser;

  /// Registers a new user with [email] and [password].
  Future<Result<AuthUser>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs in an existing user with [email] and [password].
  Future<Result<AuthUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<Result<void>> signOut();

  /// Sends an email verification message to the current user.
  Future<Result<void>> sendEmailVerification();

  /// Sends a password-reset email to [email].
  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  });

  /// Reloads the current user from the auth provider and returns
  /// the refreshed domain user (useful after email verification).
  Future<Result<AuthUser>> reloadUser();

  /// Returns whether the current user's email is verified.
  /// Reloads user data first when [reload] is `true`.
  Future<Result<bool>> checkEmailVerified({bool reload = true});
}
