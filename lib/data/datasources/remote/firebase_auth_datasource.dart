import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veyra/core/error/auth_failure_type.dart';
import 'package:veyra/data/exceptions/auth_exception.dart';
import 'package:veyra/domain/entities/auth_user.dart';

/// Remote data source that talks directly to Firebase Authentication.
class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_mapUser);
  }

  AuthUser? get currentUser => _mapUser(_firebaseAuth.currentUser);

  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException(AuthFailureType.unexpected);
      }
      return _mapUser(user)!;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } on AuthException {
      rethrow;
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          'Firebase Auth sign-up failed unexpectedly: ${error.runtimeType}',
        );
      }
      throw const AuthException(AuthFailureType.unexpected);
    }
  }

  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException(AuthFailureType.unexpected);
      }
      return _mapUser(user)!;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(AuthFailureType.unexpected);
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (_) {
      throw const AuthException(AuthFailureType.unexpected);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(AuthFailureType.userNotFound);
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(AuthFailureType.unexpected);
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (_) {
      throw const AuthException(AuthFailureType.unexpected);
    }
  }

  Future<AuthUser> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(AuthFailureType.userNotFound);
      }
      await user.reload();
      final refreshed = _firebaseAuth.currentUser;
      if (refreshed == null) {
        throw const AuthException(AuthFailureType.userNotFound);
      }
      return _mapUser(refreshed)!;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(AuthFailureType.unexpected);
    }
  }

  Future<bool> checkEmailVerified({bool reload = true}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(AuthFailureType.userNotFound);
      }
      if (reload) {
        await user.reload();
      }
      return _firebaseAuth.currentUser?.emailVerified ?? false;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(AuthFailureType.unexpected);
    }
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      id: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  AuthException _mapFirebaseException(FirebaseAuthException exception) {
    if (kDebugMode) {
      debugPrint(
        'Firebase Auth error code: ${exception.code}; '
        'message: ${exception.message}',
      );
    }
    final type = switch (exception.code) {
      'invalid-email' => AuthFailureType.invalidEmail,
      'wrong-password' => AuthFailureType.wrongPassword,
      'user-not-found' => AuthFailureType.userNotFound,
      'email-already-in-use' => AuthFailureType.emailAlreadyInUse,
      'weak-password' => AuthFailureType.weakPassword,
      'network-request-failed' => AuthFailureType.networkError,
      'user-disabled' => AuthFailureType.userDisabled,
      'too-many-requests' => AuthFailureType.tooManyRequests,
      'operation-not-allowed' => AuthFailureType.operationNotAllowed,
      'requires-recent-login' => AuthFailureType.requiresRecentLogin,
      'invalid-credential' => AuthFailureType.invalidCredential,
      'invalid-login-credentials' => AuthFailureType.invalidCredential,
      _ => AuthFailureType.unexpected,
    };
    return AuthException(type, code: exception.code);
  }
}
