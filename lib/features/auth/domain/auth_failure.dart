/// Motivos de fallo de autenticación que la interfaz sabe traducir a un
/// mensaje en español.
enum AuthFailureReason {
  invalidCredentials,
  userDisabled,
  tooManyRequests,
  network,
  notAllowed,
  emailAlreadyInUse,
  weakPassword,
  requiresRecentLogin,
  verificationEmailFailed,
  emailChangeFailed,
  profileCreationFailed,
  unknown,
}

/// Error de dominio de autenticación.
///
/// La capa de datos traduce las excepciones de Firebase a este tipo para que
/// la presentación nunca dependa de códigos técnicos.
class AuthFailure implements Exception {
  const AuthFailure(this.reason);

  final AuthFailureReason reason;
}
