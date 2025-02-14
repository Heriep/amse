import 'dart:convert';
import 'package:http/http.dart' as http;

class StorageService {
  // Singleton instance
  static final StorageService _instance = StorageService._internal();

  // Factory constructor
  factory StorageService() {
    return _instance;
  }

  // Internal constructor
  StorageService._internal();

  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheExpiry = {};
  final Duration cacheDuration = const Duration(hours: 1);

  Future<Map<dynamic, dynamic>> fetchAlmanaxData(DateTime date) async {
    final dateString = '${date.month}/${date.day}/${date.year}';
    if (_cache.containsKey(dateString) && !_isCacheExpired(dateString)) {
      return _cache[dateString]!;
    }

    final almanaxResponse = await http.get(
      Uri.parse('https://api.dofusdb.fr/almanax?date=$dateString'),
    );
    if (almanaxResponse.statusCode == 200) {
      final almanaxData = json.decode(almanaxResponse.body);

      final questId = almanaxData['m_id'];
      final questResponse = await http.get(
        Uri.parse(
          'https://api.dofusdb.fr/quests?startCriterion[\$regex]=Ad%3D$questId(\$|%26\\)|\\|)&lang=fr',
        ),
      );
      if (questResponse.statusCode == 200) {
        final questData = json.decode(questResponse.body);
        final itemId =
            questData['data'][0]['steps'][0]['objectives'][0]['need']['generated']['items'][0];

        final itemResponse = await http.get(
          Uri.parse(
            'https://api.dofusdb.fr/items?\$skip=0&id[]=$itemId&lang=fr',
          ),
        );
        if (itemResponse.statusCode == 200) {
          final itemData = json.decode(itemResponse.body);
          final data = {
            'almanax': almanaxData,
            'quest': questData['data'][0],
            'item': itemData['data'][0],
          };
          _cache[dateString] = data;
          _cacheExpiry[dateString] = DateTime.now().add(cacheDuration);
          return data;
        } else {
          throw Exception('Failed to load item data');
        }
      } else {
        throw Exception('Failed to load quest data');
      }
    } else {
      throw Exception('Failed to load almanax data');
    }
  }

  Future<List<dynamic>> fetchChallengesData() async {
    const cacheKey = 'challenges';
    if (_cache.containsKey(cacheKey) && !_isCacheExpired(cacheKey)) {
      return _cache[cacheKey];
    }

    final response = await http.get(
      Uri.parse(
        'https://api.dofusdb.fr/challenges?\$skip=0&\$sort[slug.fr]=1&\$limit=50&categoryId[]=1&iconId[\$ne]=0&lang=fr',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final challenges = data['data'].toList();
      _cache[cacheKey] = challenges;
      _cacheExpiry[cacheKey] = DateTime.now().add(cacheDuration);
      return challenges;
    } else {
      throw Exception('Failed to load challenges data');
    }
  }

  bool _isCacheExpired(String key) {
    return DateTime.now().isAfter(_cacheExpiry[key]!);
  }
}