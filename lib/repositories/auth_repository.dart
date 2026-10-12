import '../models/app_user.dart';

/// Repositorio de autenticación.
///
/// Es la única capa que conversa con Firebase Auth. Las vistas NUNCA acceden
/// a Firebase directamente: pasan por su ViewModel y este, a su vez, por aquí.
///
/// TODO: implementar los métodos con `firebase_auth`. Este archivo es solo el
/// stub de la estructura.
class AuthRepository {
  const AuthRepository();

  /// Usuario actualmente autenticado, o `null` si no hay sesión.
  ///
  /// TODO: leer de FirebaseAuth.instance.
  AppUser? get currentUser {
    // TODO: implementar lectura del usuario actual.
    return null;
  }

  /// Stream del estado de autenticación (para el guard de rutas).
  ///
  /// TODO: exponer FirebaseAuth.authStateChanges().
  Stream<AppUser?> get authStateChanges => const Stream<AppUser?>.empty();

  /// Registra un usuario con [email] y [password].
  ///
  /// TODO: implementar createUserWithEmailAndPassword.
  Future<void> register({
    required String email,
    required String password,
  }) async {
    // TODO: implementar registro en Firebase Auth.
  }

  /// Inicia sesión con [email] y [password].
  ///
  /// TODO: implementar signInWithEmailAndPassword.
  Future<void> login({required String email, required String password}) async {
    // TODO: implementar inicio de sesión.
  }

  /// Envía el código de verificación al teléfono del usuario.
  ///
  /// TODO: implementar con Firebase Phone Auth o con el servicio elegido.
  Future<void> sendVerificationCode({required String phone}) async {
    // TODO: implementar envío de código.
  }

  /// Confirma el [code] recibido por el usuario.
  ///
  /// TODO: implementar la confirmación del código.
  Future<void> confirmVerificationCode({required String code}) async {
    // TODO: implementar confirmación.
  }

  /// Envía un correo de restablecimiento de contraseña a [email].
  ///
  /// TODO: implementar sendPasswordResetEmail.
  Future<void> sendPasswordReset({required String email}) async {
    // TODO: implementar restablecimiento.
  }

  /// Cierra la sesión del usuario actual.
  ///
  /// TODO: implementar signOut.
  Future<void> logout() async {
    // TODO: implementar cierre de sesión.
  }
}
