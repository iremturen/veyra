import 'package:veyra/core/error/auth_failure_type.dart';
import 'package:veyra/core/error/failure.dart';
import 'package:veyra/core/error/result.dart';
import 'package:veyra/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:veyra/data/exceptions/auth_exception.dart';
import 'package:veyra/domain/entities/auth_user.dart';
import 'package:veyra/domain/repositories/auth_repository.dart';

/// [AuthRepository] implementation backed by [FirebaseAuthDataSource].
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  const AuthRepositoryImpl({required this._dataSource});

  @override
  Stream<AuthUser?> get authStateChanges => _dataSource.authStateChanges;

  @override
  AuthUser? get currentUser => _dataSource.currentUser;

  @override
  Future<Result<AuthUser>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _guard(
      () => _dataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Result<AuthUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _guard(
      () => _dataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Result<void>> signOut() {
    return _guard(() => _dataSource.signOut());
  }

  @override
  Future<Result<void>> sendEmailVerification() {
    return _guard(() => _dataSource.sendEmailVerification());
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) {
    return _guard(() => _dataSource.sendPasswordResetEmail(email: email));
  }

  @override
  Future<Result<AuthUser>> reloadUser() {
    return _guard(() => _dataSource.reloadUser());
  }

  @override
  Future<Result<bool>> checkEmailVerified({bool reload = true}) {
    return _guard(() => _dataSource.checkEmailVerified(reload: reload));
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      final value = await action();
      return Success(value);
    } on AuthException catch (e) {
      return ResultFailure(e.toFailure());
    } catch (_) {
      return ResultFailure(AuthFailure.fromType(AuthFailureType.unexpected));
    }
  }
}
