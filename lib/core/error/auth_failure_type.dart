/// Categories of authentication failures.
enum AuthFailureType {
  invalidEmail,
  wrongPassword,
  userNotFound,
  emailAlreadyInUse,
  weakPassword,
  networkError,
  userDisabled,
  tooManyRequests,
  operationNotAllowed,
  requiresRecentLogin,
  invalidCredential,
  unexpected,
}
