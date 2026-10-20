import 'package:amaguana_alerta/models/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRole', () {
    test('convierte los valores conocidos de Firestore', () {
      expect(UserRole.fromFirestore('vecino'), UserRole.vecino);
      expect(
        UserRole.fromFirestore('vecinoVerificado'),
        UserRole.vecinoVerificado,
      );
      expect(UserRole.fromFirestore('administrador'), UserRole.administrador);
    });

    test('usa vecino ante valores ausentes o desconocidos', () {
      expect(UserRole.fromFirestore(null), UserRole.vecino);
      expect(UserRole.fromFirestore(''), UserRole.vecino);
      expect(UserRole.fromFirestore('superadmin'), UserRole.vecino);
    });
  });

  group('AppUser', () {
    test('copyWith cambia solo el rol y conserva los demás datos', () {
      const AppUser user = AppUser(
        uid: 'uid-1',
        email: 'vecino@ejemplo.com',
        role: UserRole.vecino,
        displayName: 'María Pérez',
        emailVerified: true,
      );

      final AppUser admin = user.copyWith(role: UserRole.administrador);

      expect(admin.uid, user.uid);
      expect(admin.email, user.email);
      expect(admin.displayName, user.displayName);
      expect(admin.emailVerified, isTrue);
      expect(admin.role, UserRole.administrador);
      expect(user.role, UserRole.vecino);
    });
  });
}
