import 'package:veyra/core/error/result.dart';
import 'package:veyra/domain/entities/auth_user.dart';

abstract class AuthRepository {

  Stream<AuthUser?> get authStateChanges;

  AuthUser? get currentUser;

  Future<Result<AuthUser>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<AuthUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<void>> sendEmailVerification();

  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  });

  Future<Result<AuthUser>> reloadUser();

  Future<Result<bool>> checkEmailVerified({bool reload = true});
}
