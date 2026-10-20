import '../../../models/app_user.dart';
import 'auth_failure.dart';

/// Contrato de autenticación de VeciApp.
///
/// La implementación concreta vive en `data/` y es la única que conoce
/// Firebase. La presentación depende solo de esta interfaz.
abstract interface class AuthRepository {
  /// Usuario actualmente autenticado, o `null` si no hay sesión.
  AppUser? get currentUser;

  /// Cambios del estado de autenticación, incluida la sesión persistente.
  Stream<AppUser?> get authStateChanges;

  /// Inicia sesión con correo y contraseña.
  ///
  /// Lanza [AuthFailure] cuando las credenciales no son válidas o la cuenta
  /// no puede ingresar.
  Future<AppUser> signIn({required String email, required String password});

  /// Crea una cuenta de vecino con rol `vecino`.
  ///
  /// [phone] es opcional. [consentAccepted] debe ser `true`; sin la aceptación
  /// expresa del aviso de privacidad no se crea la cuenta.
  ///
  /// Lanza [AuthFailure] cuando el correo ya está en uso, la contraseña no es
  /// válida, falta el consentimiento o el perfil no se puede guardar.
  Future<AppUser> signUp({
    required String nombres,
    required String apellidos,
    required String cedula,
    required String email,
    String? phone,
    required String password,
    required bool consentAccepted,
  });

  /// Lee el rol actual del perfil público del usuario.
  ///
  /// La implementación devuelve [UserRole.vecino] si el documento no existe o
  /// no se puede leer: nunca eleva privilegios por un fallo de red o un dato
  /// inesperado.
  Future<UserRole> loadRole(String uid);

  /// Cierra la sesión actual.
  Future<void> signOut();

  /// Envía un nuevo enlace de verificación al correo de la cuenta actual.
  ///
  /// Lanza [AuthFailure] si no hay sesión o si Firebase rechaza el envío.
  Future<void> sendVerificationEmail();

  /// Recarga la cuenta desde Firebase y devuelve su estado actualizado.
  ///
  /// Devuelve `null` si ya no hay sesión. Si el correo quedó verificado,
  /// sincroniza `users_private.email` con el correo actual de Auth.
  Future<AppUser?> reloadCurrentUser();

  /// Solicita cambiar el correo de la cuenta actual.
  ///
  /// Firebase envía un enlace al nuevo correo; el cambio se completa cuando el
  /// usuario lo verifica. Lanza [AuthFailure] si la operación no es posible.
  Future<void> requestEmailChange(String newEmail);

  /// Envía al correo un enlace para restablecer la contraseña.
  ///
  /// La implementación no revela si el correo existe: una dirección no
  /// registrada también termina sin error para evitar enumerar cuentas.
  Future<void> sendPasswordResetEmail(String email);
}
