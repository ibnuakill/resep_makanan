import 'dart:convert';
import 'package:http/http.dart' as http;

/// Helper untuk menerjemahkan teks instruksi resep ke Bahasa Indonesia atau bahasa target.
/// Menggunakan kamus cepat untuk istilah kuliner umum + free translation API fallback.
class TranslationService {
  static final Map<String, String> _memoryCache = {};

  /// Kamus istilah kuliner umum dari TheMealDB instructions
  static final Map<String, String> _culinaryTerms = {
    'Preheat the oven to': 'Panaskan oven hingga',
    'Preheat the oven': 'Panaskan oven',
    'Preheat oven to': 'Panaskan oven hingga',
    'In a large bowl,': 'Dalam mangkuk besar,',
    'In a large bowl': 'Dalam mangkuk besar',
    'In a small bowl,': 'Dalam mangkuk kecil,',
    'In a medium bowl,': 'Dalam mangkuk sedang,',
    'In a large pan,': 'Di wajan besar,',
    'In a frying pan,': 'Di wajan penggorengan,',
    'In a large saucepan,': 'Di panci besar,',
    'In a saucepan,': 'Di dalam panci,',
    'In a baking dish,': 'Di loyang pemanggang,',
    'Heat the oil in a': 'Panaskan minyak dalam',
    'Heat oil in a': 'Panaskan minyak dalam',
    'Heat the oil': 'Panaskan minyak',
    'Heat oil': 'Panaskan minyak',
    'Bring to a boil': 'Didihkan hingga mendidih',
    'Bring to the boil': 'Didihkan hingga mendidih',
    'Reduce heat and simmer': 'Kecilkan api dan masak perlahan (simmer)',
    'Simmer for': 'Masak perlahan selama',
    'Cook for': 'Masak selama',
    'Bake for': 'Panggang selama',
    'Fry for': 'Goreng selama',
    'Stir well': 'Aduk rata',
    'Stir occasionally': 'Aduk sesekali',
    'Stir frequently': 'Aduk sering-sering',
    'Season with salt and pepper': 'Bumbui dengan garam dan merica',
    'Season with salt and black pepper': 'Bumbui dengan garam dan lada hitam',
    'Season with': 'Bumbui dengan',
    'Drain and set aside': 'Tiriskan dan sisihkan',
    'Set aside': 'Sisihkan',
    'Serve immediately': 'Sajikan segera selagi hangat',
    'Serve hot': 'Sajikan selagi panas',
    'Serve with': 'Sajikan dengan',
    'Garnish with': 'Beri hiasan / taburan',
    'Chop the': 'Cincang',
    'Dice the': 'Potong dadu',
    'Mince the': 'Cincang halus',
    'Slice the': 'Iris',
    'Cut into': 'Potong menjadi',
    'Mix well': 'Campur hingga rata',
    'Combine all ingredients': 'Campurkan semua bahan',
    'Whisk together': 'Kocok bersama',
    'Melt the butter': 'Lelehkan mentega',
    'medium heat': 'api sedang',
    'low heat': 'api kecil',
    'high heat': 'api besar',
    'golden brown': 'kuning keemasan / kecokelatan',
    'minutes': 'menit',
    'hours': 'jam',
    'tablespoon': 'sendok makan',
    'teaspoon': 'sendok teh',
  };

  /// Terjemahkan teks instruksi resep.
  /// Jika targetLang == 'en', kembalikan teks asli.
  /// Jika targetLang == 'id', terjemahkan teks Inggris ke Bahasa Indonesia.
  static Future<String> translateInstructions(
    String text, {
    String targetLang = 'id',
  }) async {
    if (text.trim().isEmpty) return text;
    if (targetLang == 'en') return text;

    final cacheKey = '$targetLang:${text.hashCode}';
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey]!;
    }

    // 1. Coba gunakan terjemahan online cepat (MyMemory Translation API - free tier tanpa key)
    try {
      final translated = await _fetchOnlineTranslation(text, 'en', targetLang);
      if (translated != null && translated.isNotEmpty) {
        _memoryCache[cacheKey] = translated;
        return translated;
      }
    } catch (_) {
      // Jika offline atau gagal, gunakan kamus pengganti lokal
    }

    // 2. Fallback: terjemahan berbasis kamus istilah kuliner lokal
    final localResult = _applyLocalDictionary(text);
    _memoryCache[cacheKey] = localResult;
    return localResult;
  }

  static Future<String?> _fetchOnlineTranslation(
    String text,
    String from,
    String to,
  ) async {
    // Potong teks jika terlalu panjang untuk request GET URL
    final queryText = text.length > 500 ? text.substring(0, 500) : text;
    final uri = Uri.parse(
      'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(queryText)}&langpair=$from|$to',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 4));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final status = data['responseStatus'];
      if (status == 200 || status == '200') {
        final res = data['responseData']?['translatedText'] as String?;
        if (res != null && res.isNotEmpty && !res.contains('MYMEMORY WARNING')) {
          if (text.length > 500) {
            // Gabungkan sisanya dengan kamus lokal
            final remaining = _applyLocalDictionary(text.substring(500));
            return '$res $remaining';
          }
          return res;
        }
      }
    }
    return null;
  }

  static String _applyLocalDictionary(String text) {
    var result = text;
    for (final entry in _culinaryTerms.entries) {
      result = result.replaceAll(RegExp(RegExp.escape(entry.key), caseSensitive: false), entry.value);
    }
    return result;
  }
}
