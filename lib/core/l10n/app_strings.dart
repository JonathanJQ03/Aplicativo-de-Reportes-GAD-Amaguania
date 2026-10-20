/// Textos visibles de la aplicación, en español.
///
/// Todo texto que vea el usuario vive aquí. Los widgets no deben declarar
/// cadenas literales visibles.
abstract final class AppStrings {
  // Identidad.
  static const String appName = 'VeciApp';
  static const String gadName = 'Gobierno Autónomo Descentralizado de Amaguaña';

  // Acciones comunes.
  static const String loading = 'Cargando';
  static const String retry = 'Reintentar';
  static const String signOut = 'Cerrar sesión';

  // Inicio de sesión.
  static const String loginGreeting = 'Bienvenido a VeciApp';
  static const String loginSubtitle =
      'Reporta fugas de agua y mascotas en tu parroquia. '
      'Ingresa para continuar.';
  static const String emailLabel = 'Correo electrónico';
  static const String emailHint = 'Ej.: nombre@correo.com';
  static const String passwordLabel = 'Contraseña';
  static const String passwordHint = 'Escribe tu contraseña';
  static const String showPassword = 'Mostrar contraseña';
  static const String hidePassword = 'Ocultar contraseña';
  static const String signIn = 'Ingresar';
  static const String loginSupport =
      'Usa el correo y la contraseña con los que te registraste.';
  static const String loginNoAccount = '¿No tienes cuenta?';
  static const String loginGoToRegister = 'Regístrate';

  // Registro.
  static const String registerScreenTitle = 'Registro de vecino';
  static const String registerTitle = 'Crea tu cuenta';
  static const String registerSubtitle =
      'Completa tus datos para reportar en tu parroquia.';
  static const String firstNameLabel = 'Nombres';
  static const String firstNameHint = 'Ej.: María Fernanda';
  static const String lastNameLabel = 'Apellidos';
  static const String lastNameHint = 'Ej.: Pérez Gómez';
  static const String cedulaLabel = 'Cédula';
  static const String cedulaHint = 'Ej.: 1710034065';
  static const String phoneLabel = 'Teléfono (opcional)';
  static const String phoneHint = 'Ej.: 0991234567';
  static const String registerPasswordHelper =
      'Mínimo 8 caracteres, con mayúscula, minúscula, número y símbolo.';
  static const String registerButton = 'Crear cuenta';
  static const String registerHaveAccount = '¿Ya tienes una cuenta?';
  static const String registerGoToLogin = 'Inicia sesión';
  static const String backToLogin = 'Volver al inicio de sesión';

  // Verificación del correo.
  static const String verifyEmailScreenTitle = 'Verifica tu correo';
  static const String verifyEmailTitle = 'Confirma tu correo';
  static const String verifyEmailBody =
      'Abre el enlace que enviamos a tu correo y vuelve aquí. '
      'Hasta confirmarlo, no podrás ingresar.';
  static const String verifyEmailCurrentEmailLabel = 'Correo registrado';
  static const String verifyEmailCheckButton = 'Ya verifiqué mi correo';
  static const String verifyEmailResendButton = 'Reenviar correo';
  static const String verifyEmailChangeButton = 'Cambiar correo';
  static const String verifyEmailCancelButton = 'Cancelar y cerrar sesión';
  static const String verifyEmailSent =
      'Te enviamos un nuevo enlace de verificación. Revisa tu correo.';
  static const String verifyEmailStillPending =
      'Todavía no confirmamos tu correo. Abre el enlace y vuelve a intentarlo.';
  static const String verifyEmailSpamHint =
      'Si no llega en unos minutos, revisa la carpeta de spam.';
  static const String verifyEmailDevelopmentNotice =
      'Modo de desarrollo: la verificación se completará automáticamente en '
      '3 segundos.';
  static const String verifyEmailChangeTitle = 'Cambiar correo electrónico';
  static const String verifyEmailChangeBody =
      'Te enviaremos un enlace al nuevo correo. El cambio se completa cuando '
      'lo verifiques.';
  static const String verifyEmailChangeSubmit = 'Enviar enlace';
  static const String verifyEmailChangeCancel = 'Cancelar';
  static const String verifyEmailChangeSame =
      'Escribe un correo diferente al que tienes registrado.';
  static const String verifyEmailChangeSent =
      'Te enviamos un enlace al nuevo correo. Ábrelo para completar el cambio.';
  static const String verifyEmailChangePendingPrefix =
      'Pendiente de verificar:';
  static const String verifyEmailChangePendingBody =
      'Tu correo actual sigue activo hasta que confirmes el nuevo.';

  // Validación de formularios.
  static const String validationEmailRequired =
      'Escribe tu correo electrónico.';
  static const String validationEmailInvalid =
      'Escribe un correo válido, por ejemplo nombre@correo.com.';
  static const String validationPasswordRequired = 'Escribe tu contraseña.';
  static const String validationNameInvalid =
      'Escribe un nombre o apellido válido, solo con letras.';
  static const String validationFirstNameRequired = 'Escribe tus nombres.';
  static const String validationLastNameRequired = 'Escribe tus apellidos.';
  static const String validationCedulaRequired = 'Escribe tu cédula.';
  static const String validationCedulaFormat =
      'La cédula debe tener 10 números, sin espacios.';
  static const String validationCedulaInvalid =
      'La cédula no es válida. Revísala e intenta de nuevo.';
  static const String validationPhoneInvalid =
      'Escribe un teléfono de 10 números, por ejemplo 0991234567.';
  static const String validationPasswordMinLength =
      'Usa al menos 8 caracteres.';
  static const String validationPasswordUppercase =
      'Agrega al menos una letra mayúscula.';
  static const String validationPasswordLowercase =
      'Agrega al menos una letra minúscula.';
  static const String validationPasswordDigit = 'Agrega al menos un número.';
  static const String validationPasswordSymbol =
      'Agrega al menos un símbolo, por ejemplo !, # o \$.';

  // Inicio (marcador temporal hasta la sesión S08).
  static const String homeTitle = 'Inicio';
  static const String homeSessionTitle = 'Sesión iniciada';
  static const String homeSessionBody =
      'Ya puedes usar VeciApp. El panel de reportes estará disponible '
      'en la siguiente etapa.';

  // Títulos de pantallas pendientes de implementar.
  static const String forgotPasswordTitle = 'Recuperar contraseña';
  static const String profileTitle = 'Mi perfil';
  static const String myReportsTitle = 'Mis reportes';
  static const String newLeakReportTitle = 'Nuevo reporte de fuga';
  static const String newPetReportTitle = 'Nuevo reporte de mascota';
  static const String reportDetailTitle = 'Detalle del reporte';

  // Errores de autenticación.
  static const String authMissingCredentials =
      'Escribe tu correo y tu contraseña para ingresar.';
  static const String authInvalidCredentials =
      'El correo o la contraseña no son correctos. Revísalos e intenta de nuevo.';
  static const String authUserDisabled =
      'Tu cuenta está suspendida. Comunícate con el GAD de Amaguaña '
      'para más información.';
  static const String authTooManyRequests =
      'Hubo demasiados intentos. Espera unos minutos e intenta de nuevo.';
  static const String authNetwork =
      'No pudimos conectar. Revisa tu conexión a internet e intenta de nuevo.';
  static const String authNotAllowed =
      'El acceso con correo y contraseña no está disponible. '
      'Comunícate con el GAD de Amaguaña.';
  static const String authUnexpected =
      'No pudimos iniciar sesión. Intenta de nuevo en unos momentos.';
  static const String authUnexpectedSignOut =
      'No pudimos cerrar la sesión. Intenta de nuevo en unos momentos.';
  static const String authEmailAlreadyInUse =
      'Ya existe una cuenta con este correo. Inicia sesión o recupera tu '
      'contraseña.';
  static const String authWeakPassword =
      'La contraseña es demasiado débil. Usa mayúscula, minúscula, número '
      'y símbolo.';
  static const String authProfileCreationFailed =
      'No pudimos completar tu registro. Revisa tu conexión e intenta de '
      'nuevo.';
  static const String authUnexpectedSignUp =
      'No pudimos crear tu cuenta. Intenta de nuevo en unos momentos.';
  static const String authMissingRegistrationData =
      'Completa todos los campos obligatorios.';
  static const String authRequiresRecentLogin =
      'Por seguridad, cierra sesión y vuelve a entrar para cambiar el correo.';
  static const String authVerificationEmailFailed =
      'No pudimos enviar el correo de verificación. Revisa tu conexión e '
      'intenta de nuevo.';
  static const String authEmailChangeFailed =
      'No pudimos cambiar el correo. Revisa la dirección e intenta de nuevo.';

  // Panel de administración (stub hasta S15).
  static const String adminPanelTitle = 'Panel de administración';
  static const String adminPanelComingSoon =
      'El panel para el personal del GAD estará disponible próximamente.';

  // Arranque.
  static const String startupErrorTitle = 'No pudimos iniciar la aplicación';
  static const String startupErrorBody =
      'Revisa tu conexión a internet e intenta abrir la aplicación de nuevo.';
}
