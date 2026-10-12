/// Roles disponibles para un usuario de la aplicación.
enum UserRole {
  /// Vecino sin verificar (solo puede reportar).
  vecino,

  /// Vecino con cédula verificada por el GAD.
  vecinoVerificado,

  /// Administrador del GAD: aprueba, atiende y cierra reportes.
  administrador,
}

/// Usuario de la aplicación (vecino o administrador del GAD de Amaguaña).
///
/// TODO: implementar los métodos de serialización cuando se defina el
/// esquema final de la colección `users` en Firestore.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.cedula,
    this.photoUrl,
  });

  /// Identificador único del usuario (Firebase Auth uid).
  final String uid;

  /// Correo electrónico registrado.
  final String email;

  /// Rol del usuario dentro de la aplicación.
  final UserRole role;

  /// Nombre completo mostrado en la interfaz.
  final String? displayName;

  /// Cédula de identidad ecuatoriana (solo se guarda si está verificada).
  final String? cedula;

  /// URL de la foto de perfil en Firebase Storage.
  final String? photoUrl;

  // TODO: crear factory AppUser.fromMap(Map<String, dynamic> map).
  // TODO: crear Map<String, dynamic> toMap().
  // TODO: crear AppUser copyWith(...).
}
