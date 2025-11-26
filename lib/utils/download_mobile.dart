// lib/utils/download_mobile.dart
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadTxt(String content, String filename) async {
  // Pega a pasta temporária da aplicação
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');

  await file.writeAsString(content);

  // Abre o diálogo de compartilhamento (WhatsApp, Arquivos, etc.)
  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'Sugestão gerada pelo InsuGuia (protótipo didático).',
  );
}
