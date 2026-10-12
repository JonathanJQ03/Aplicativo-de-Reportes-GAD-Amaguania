/// Repositorio de almacenamiento (Firebase Storage).
///
/// Única capa que sube y descarga archivos. Las vistas NUNCA acceden a
/// Firebase directamente.
///
/// TODO: implementar los métodos con `firebase_storage`. Este archivo es solo
/// el stub de la estructura.
class StorageRepository {
  const StorageRepository();

  /// Sube una foto ya comprimida y devuelve su URL de descarga.
  ///
  /// [localPath] es la ruta del archivo en el dispositivo y [remoteName] el
  /// nombre que tendrá dentro de Storage.
  ///
  /// TODO: implementar putFile y getDownloadURL.
  Future<String> uploadPhoto({
    required String localPath,
    required String remoteName,
  }) async {
    // TODO: implementar subida de foto.
    return '';
  }

  /// Elimina un archivo por su [path] dentro de Storage.
  ///
  /// TODO: implementar delete.
  Future<void> deleteFile(String path) async {
    // TODO: implementar eliminación.
  }
}
