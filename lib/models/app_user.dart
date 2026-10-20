/// Roles disponibles para un usuario de la aplicación.
///
/// [firestoreValue] es el valor que se guarda en `users/{uid}.role`. Las
/// reglas de Firestore comparan contra estos mismos textos, así que no deben
/// cambiarse sin actualizar `firestore.rules`.
enum UserRole {
  /// Vecino sin verificar (solo puede reportar).
  vecino('vecino'),

  /// Vecino con cédula verificada por el GAD.
  vecinoVerificado('vecinoVerificado'),

  /// Administrador del GAD: aprueba, atiende y cierra reportes.
  administrador('administrador');

  const UserRole(this.firestoreValue);

  /// Valor usado en el campo `role` de Firestore.
  final String firestoreValue;

  /// Convierte el valor guardado en Firestore a un rol conocido.
  ///
  /// Ante un valor ausente o desconocido devuelve [vecino], el rol con menos
  /// permisos. Así un dato corrupto nunca eleva privilegios.
  static UserRole fromFirestore(Object? value) {
    for (final UserRole role in UserRole.values) {
      if (role.firestoreValue == value) {
        return role;
      }
    }
    return UserRole.vecino;
  }
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
    this.emailVerified = false,
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

  /// Indica si Firebase Auth ya confirmó el correo electrónico.
  ///
  /// Mientras sea `false`, el router mantiene al usuario en la pantalla de
  /// verificación y no permite entrar a la aplicación.
  final bool emailVerified;

  /// Copia el usuario cambiando solo los campos indicados.
  ///
  /// Los campos opcionales conservan su valor cuando se omite el parámetro.
  AppUser copyWith({
    String? uid,
    String? email,
    UserRole? role,
    String? displayName,
    String? cedula,
    String? photoUrl,
    bool? emailVerified,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      cedula: cedula ?? this.cedula,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  // TODO: crear factory AppUser.fromMap(Map<String, dynamic> map).
  // TODO: crear Map<String, dynamic> toMap().
}
