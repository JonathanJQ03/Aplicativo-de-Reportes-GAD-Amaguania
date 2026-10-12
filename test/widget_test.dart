// Este test fue generado por `flutter create` y ajustado a la estructura
// real del proyecto.
//
// TODO: añadir tests de las vistas y los viewmodels una vez implementada la
// lógica de negocio.
import 'package:amaguana_alerta/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la app arranca y muestra la pantalla de login', (tester) async {
    await tester.pumpWidget(const AmaguanaAlertaApp());

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
