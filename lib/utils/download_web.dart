import 'package:web/web.dart' as web;
import 'dart:js_interop'; // habilita .toJS

void downloadTxt(String content, String filename) {
  // Cria JSArray<BlobPart> a partir de String
  final parts = <web.BlobPart>[content.toJS].toJS;

  final blob = web.Blob(
    parts,
    web.BlobPropertyBag(type: 'text/plain'),
  );
  final url = web.URL.createObjectURL(blob);

  final a = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  a.click();

  web.URL.revokeObjectURL(url);
}
