/// Compresión de fotos antes de subirlas a Firebase Storage.
///
/// TODO: implementar la compresión real usando el paquete
/// `flutter_image_compress`. Este archivo es solo el stub de la estructura.
class ImageCompressor {
  ImageCompressor._();

  /// Tamaño máximo permitido por foto, en megabytes.
  static const double maxMegabytes = 1;

  /// Comprime la imagen ubicada en [path].
  ///
  /// Reglas por implementar:
  /// 1. Reducir la calidad hasta que el archivo pese 1 MB o menos.
  /// 2. Mantener la proporción original de la imagen.
  /// 3. Conservar la orientación EXIF.
  ///
  /// Devuelve la ruta del archivo comprimido.
  static Future<String> compress(String path) async {
    // TODO: implementar compresión con flutter_image_compress.
    return path;
  }

  /// Comprime varias [paths] y devuelve sus rutas comprimidas.
  ///
  /// TODO: implementar la compresión en lote.
  static Future<List<String>> compressAll(List<String> paths) async {
    // TODO: implementar compresión en lote.
    return paths;
  }
}
