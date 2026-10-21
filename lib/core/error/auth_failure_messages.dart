/// User-facing messages for authentication failures.
abstract final class AuthFailureMessages {
  static const invalidEmail = 'Please enter a valid email address.';
  static const wrongPassword = 'Incorrect password. Please try again.';
  static const userNotFound = 'No account found with this email address.';
  static const emailAlreadyInUse =
      'An account already exists with this email address.';
  static const weakPassword =
      'Password is too weak. Please choose a stronger password.';
  static const networkError =
      'Network error. Please check your connection and try again.';
  static const userDisabled = 'This account has been disabled.';
  static const tooManyRequests = 'Too many attempts. Please try again later.';
  static const operationNotAllowed = 'This sign-in method is not enabled.';
  static const requiresRecentLogin = 'Please sign in again to continue.';
  static const invalidCredential = 'Invalid email or password.';
  static const unexpected = 'Something went wrong. Please try again.';
}
