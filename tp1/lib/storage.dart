import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString('cache');
    if (cacheString != null) {
      final cacheData = json.decode(cacheString) as Map<String, dynamic>;
      _cache.addAll(cacheData);
    }
    final cacheExpiryString = prefs.getString('cacheExpiry');
    if (cacheExpiryString != null) {
      final cacheExpiryData =
          json.decode(cacheExpiryString) as Map<String, dynamic>;
      cacheExpiryData.forEach((key, value) {
        _cacheExpiry[key] = DateTime.parse(value);
      });
    }
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cache', json.encode(_cache));
    final cacheExpiryData = _cacheExpiry.map(
      (key, value) => MapEntry(key, value.toIso8601String()),
    );
    prefs.setString('cacheExpiry', json.encode(cacheExpiryData));
  }

  Future<Map<dynamic, dynamic>> fetchAlmanaxData(DateTime date) async {
    await _loadCache();
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
          await _saveCache();
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
    await _loadCache();
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
      await _saveCache();
      return challenges;
    } else {
      throw Exception('Failed to load challenges data');
    }
  }

  Future<List<dynamic>> fetchCharacteristicsData(int skip) async {
    await _loadCache();
    final cacheKey = 'characteristics_$skip';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    final response = await http.get(
      Uri.parse(
        'https://api.dofusdb.fr/characteristics?\$skip=$skip&visible=true&\$limit=50&categoryId[\$in][]=2&categoryId[\$in][]=3&categoryId[\$in][]=4&categoryId[\$in][]=5&\$sort[categoryId]=1&\$sort[order]=1&lang=fr',
      ),
    );

    Future<Map<String, dynamic>> fetchCharacteristic(
      int characteristicId,
    ) async {
      final response = await http.get(
        Uri.parse(
          'https://api.dofusdb.fr/characteristics/$characteristicId?lang=fr',
        ),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load characteristic data');
      }
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final characteristics = (data['data'] as List).toList();
      _cache[cacheKey] = characteristics;
      _cacheExpiry[cacheKey] = DateTime.now().add(cacheDuration);
      await _saveCache();
      return characteristics;
    } else {
      throw Exception('Failed to load characteristics data');
    }
  }

  Future<Map<String, dynamic>> fetchItemsData(
    int typeId,
    int skip,
    int minLevel,
    int maxLevel,
    String itemName,
    List<int> characteristics, // changed from int to List<int>
  ) async {
    final typeFilter = typeId == 0 ? '' : 'typeId[\$in][]=$typeId&';
    final nameFilter =
        itemName.isEmpty
            ? ''
            : 'slug.fr[\$search]=${Uri.encodeComponent(itemName)}&';
    // Build filters for each selected characteristic
    String characteristicFilter = '';
    for (var i = 0; i < characteristics.length; i++) {
      characteristicFilter +=
          '&\$and[$i][effects][\$elemMatch][characteristic]=${characteristics[i]}';
    }

    final response = await http.get(
      Uri.parse(
        'https://api.dofusdb.fr/items?typeId[\$ne]=203&\$sort=-id&'
        '$nameFilter'
        '$typeFilter'
        'level[\$gte]=$minLevel&level[\$lte]=$maxLevel'
        '$characteristicFilter'
        '&\$skip=$skip&lang=fr',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['data'].toList();
      final total = data['total'];
      final result = {'items': items, 'total': total};
      return result;
    } else {
      throw Exception('Failed to load items data');
    }
  }

  Future<List<dynamic>> fetchItemTypes(int skip) async {
    await _loadCache();
    final cacheKey = 'item_types_$skip';
    if (_cache.containsKey(cacheKey) && !_isCacheExpired(cacheKey)) {
      return _cache[cacheKey];
    }

    final response = await http.get(
      Uri.parse(
        'https://api.dofusdb.fr/item-types?\$skip=$skip&\$limit=50&lang=fr',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final itemTypes = data['data'].toList();
      _cache[cacheKey] = itemTypes;
      _cacheExpiry[cacheKey] = DateTime.now().add(cacheDuration);
      await _saveCache();
      return itemTypes;
    } else {
      throw Exception('Failed to load item types');
    }
  }

  Future<void> likeItem(int itemId) async {
    await _loadCache();
    final cacheKey = 'likedItems';
    if (!_cache.containsKey(cacheKey)) {
      _cache[cacheKey] = [];
    }
    final likedItems = List<int>.from(_cache[cacheKey]);
    if (!likedItems.contains(itemId)) {
      likedItems.add(itemId);
    }
    _cache[cacheKey] = likedItems;
    await _saveCache();
  }

  Future<void> unlikeItem(int itemId) async {
    await _loadCache();
    final cacheKey = 'likedItems';
    if (_cache.containsKey(cacheKey)) {
      final likedItems = List<int>.from(_cache[cacheKey]);
      likedItems.remove(itemId);
      _cache[cacheKey] = likedItems;
      await _saveCache();
    }
  }

  Future<bool> isItemLiked(int itemId) async {
    await _loadCache();
    final cacheKey = 'likedItems';
    if (_cache.containsKey(cacheKey)) {
      final likedItems = List<int>.from(_cache[cacheKey]);
      return likedItems.contains(itemId);
    }
    return false;
  }

  Future<List<int>> getLikedItems() async {
    await _loadCache();
    final cacheKey = 'likedItems';
    if (_cache.containsKey(cacheKey)) {
      return List<int>.from(_cache[cacheKey]);
    }
    return [];
  }

  bool _isCacheExpired(String key) {
    return DateTime.now().isAfter(_cacheExpiry[key]!);
  }
}
