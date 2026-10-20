import 'package:amaguana_alerta/core/theme/app_colors.dart';
import 'package:amaguana_alerta/core/theme/app_theme.dart';
import 'package:amaguana_alerta/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    required TextEditingController controller,
    String? errorText,
    String? helperText,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppTextField(
            controller: controller,
            label: 'Correo electrónico',
            errorText: errorText,
            helperText: helperText,
          ),
        ),
      ),
    );
  }

  testWidgets('muestra el error con icono, mensaje y borde rojo', (
    tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpField(
      tester,
      controller: controller,
      errorText: 'Escribe un correo válido.',
    );

    expect(find.text('Escribe un correo válido.'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);

    final TextField field = tester.widget<TextField>(find.byType(TextField));
    final OutlineInputBorder border =
        field.decoration!.enabledBorder! as OutlineInputBorder;
    expect(border.borderSide.color, AppColors.errorText);
    expect(border.borderSide.width, 2);
  });

  testWidgets('oculta la ayuda mientras hay un error', (tester) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpField(
      tester,
      controller: controller,
      errorText: 'Escribe un correo válido.',
      helperText: 'Usa el correo con el que te registraste.',
    );

    expect(find.text('Escribe un correo válido.'), findsOneWidget);
    expect(find.text('Usa el correo con el que te registraste.'), findsNothing);
  });

  testWidgets('muestra la ayuda cuando no hay error', (tester) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpField(
      tester,
      controller: controller,
      helperText: 'Usa el correo con el que te registraste.',
    );

    expect(
      find.text('Usa el correo con el que te registraste.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.error_outline), findsNothing);
  });
}
