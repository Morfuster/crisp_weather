// Run with: dart run tools/translate.dart
// Calls LibreTranslate (free, no key) to translate en.json into every
// supported language and writes assets/translations/<lang>.json.

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _apiBase = 'https://libretranslate.com';

// All language codes supported as LibreTranslate translation targets from EN
const _targets = [
  'ar', 'az', 'bg', 'bn', 'ca', 'cs', 'da', 'de', 'el', 'eo',
  'es', 'et', 'eu', 'fa', 'fi', 'fr', 'ga', 'gl', 'he', 'hi',
  'hu', 'id', 'it', 'ja', 'ko', 'ky', 'lt', 'lv', 'ms', 'nb',
  'nl', 'pl', 'pt', 'ro', 'ru', 'sk', 'sl', 'sq', 'sr', 'sv',
  'th', 'tl', 'tr', 'uk', 'ur', 'vi', 'zh',
];

// Keys whose values contain Flutter template placeholders — skip translate
// for the placeholder token, translate the surrounding text separately.
// For simplicity: translate the whole string; LibreTranslate preserves {}.
const _sourceFile = 'assets/translations/en.json';
const _outDir = 'assets/translations';

Future<String?> _translate(String text, String target) async {
  for (var attempt = 0; attempt < 3; attempt++) {
    try {
      final resp = await http
          .post(
            Uri.parse('$_apiBase/translate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'q': text,
              'source': 'en',
              'target': target,
              'format': 'text',
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        return body['translatedText'] as String?;
      }
      stderr.writeln('  [$target] HTTP ${resp.statusCode}: ${resp.body}');
    } catch (e) {
      stderr.writeln('  [$target] attempt ${attempt + 1} error: $e');
      await Future.delayed(const Duration(seconds: 2));
    }
  }
  return null;
}

Future<void> main() async {
  final source = jsonDecode(File(_sourceFile).readAsStringSync())
      as Map<String, dynamic>;

  final langDir = Directory(_outDir);
  if (!langDir.existsSync()) langDir.createSync(recursive: true);

  for (final target in _targets) {
    final outFile = File('$_outDir/$target.json');
    stdout.write('Translating → $target ... ');

    final translated = <String, dynamic>{};
    var skipped = 0;

    for (final entry in source.entries) {
      final value = entry.value as String;
      final result = await _translate(value, target);
      if (result != null) {
        // Restore Flutter placeholder format if broken during translation
        translated[entry.key] = result.replaceAll('{ }', '{}');
      } else {
        translated[entry.key] = value; // fallback to English
        skipped++;
      }
      // Polite rate-limiting — LibreTranslate free tier
      await Future.delayed(const Duration(milliseconds: 200));
    }

    outFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(translated),
    );
    stdout.writeln('done${skipped > 0 ? " ($skipped fallback)" : ""}');
  }

  stdout.writeln('\nAll done. ${_targets.length} language files written.');
}
