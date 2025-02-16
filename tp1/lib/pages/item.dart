import 'package:flutter/material.dart';
import 'package:tp1/widget/multiselectbutton.dart';
import '../storage.dart';

class PageItem extends StatefulWidget {
  const PageItem({super.key});

  @override
  State<PageItem> createState() => _PageItemState();
}

class _PageItemState extends State<PageItem> {
  late Future<Map<String, dynamic>> _data;
  late Future<List<dynamic>> _itemTypes;
  late Future<List<dynamic>> _characteristics;
  final StorageService _storageService = StorageService();
  final TextEditingController _itemNameController = TextEditingController();
  int _typeId = 0;
  int _skip = 0;
  int _totalItems = 0;
  int _minLevel = 0;
  int _maxLevel = 200;
  String _itemName = '';
  final List<int> _selectedCharacteristics = [];

  @override
  void initState() {
    super.initState();
    _itemTypes = _fetchItemTypes();
    _characteristics = _fetchCharacteristicsData();
    _data = _fetchItems();

    _itemNameController.addListener(() {
      if (_itemNameController.text.isNotEmpty) {
        _itemName = _itemNameController.text;
      }
    });
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchItems() async {
    if (_typeId == 0 &&
        _minLevel == 0 &&
        _maxLevel == 200 &&
        _itemName.isEmpty &&
        _selectedCharacteristics.isEmpty) {
      _totalItems = 0;
      return {'items': [], 'total': 0};
    }
    final result = await _storageService.fetchItemsData(
      _typeId,
      _skip,
      _minLevel,
      _maxLevel,
      _itemName,
      _selectedCharacteristics,
    );
    setState(() {
      _totalItems = result['total'];
    });
    return result;
  }

  Future<List<dynamic>> _fetchItemTypes() async {
    List<dynamic> allItemTypes = [];
    for (int i = 0; i < 225; i += 50) {
      final itemTypes = await _storageService.fetchItemTypes(i);
      allItemTypes.addAll(itemTypes);
    }
    allItemTypes.sort((a, b) {
      int superTypeComparison = a['superType']['name']['fr'].compareTo(
        b['superType']['name']['fr'],
      );
      if (superTypeComparison != 0) {
        return superTypeComparison;
      }
      return a['name']['fr'].compareTo(b['name']['fr']);
    });
    return allItemTypes;
  }

  Future<List<dynamic>> _fetchCharacteristicsData() async {
    List<dynamic> allCharacteristics = [];
    // Comme il y a 53 caractéristiques et que l'API limite à 50, on réalise deux appels.
    for (int i = 0; i < 100; i += 50) {
      final characteristicsChunk = await _storageService
          .fetchCharacteristicsData(i);
      if (characteristicsChunk.isEmpty) break;
      allCharacteristics.addAll(characteristicsChunk);
      if (characteristicsChunk.length < 50) break;
    }
    return allCharacteristics;
  }

  void _onTypeChanged(int? newValue) {
    if (newValue != null) {
      setState(() {
        _typeId = newValue;
        _skip = 0;
        _data = _fetchItems();
      });
    }
  }

  void _onMinLevelChanged(String value) {
    setState(() {
      _minLevel = int.tryParse(value) ?? 0;
      _skip = 0;
      _data = _fetchItems();
    });
  }

  void _onMaxLevelChanged(String value) {
    setState(() {
      _maxLevel = int.tryParse(value) ?? 200;
      _skip = 0;
      _data = _fetchItems();
    });
  }

  void _onItemNameSubmitted(String value) {
    setState(() {
      _itemName = value;
      _skip = 0;
      _data = _fetchItems();
    });
  }

  void _onPageChanged(int newSkip) {
    setState(() {
      _skip = newSkip;
      _data = _fetchItems();
    });
  }

  void _toggleLikeItem(int itemId) async {
    final isLiked = await _storageService.isItemLiked(itemId);
    if (isLiked) {
      await _storageService.unlikeItem(itemId);
    } else {
      await _storageService.likeItem(itemId);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _itemNameController,
                decoration: InputDecoration(
                  labelText: 'Nom de l\'objet',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: _onItemNameSubmitted,
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                  _onItemNameSubmitted(_itemNameController.text);
                },
              ),
            ),
            ExpansionTile(
              title: Text(
                'Options de recherche avancées',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder<List<dynamic>>(
                    future: _itemTypes,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Pas de catégorie trouvée'));
                      } else {
                        final itemTypes = snapshot.data!;
                        final groupedItemTypes = <String, List<dynamic>>{};

                        for (var type in itemTypes) {
                          final superTypeName = type['superType']['name']['fr'];
                          if (!groupedItemTypes.containsKey(superTypeName)) {
                            groupedItemTypes[superTypeName] = [];
                          }
                          groupedItemTypes[superTypeName]!.add(type);
                        }

                        return Column(
                          children: [
                            DropdownButton<int>(
                              value: _typeId,
                              items: [
                                DropdownMenuItem<int>(
                                  value: 0,
                                  child: Text('Catégorie'),
                                ),
                                ...groupedItemTypes.entries.expand((entry) {
                                  final superTypeName = entry.key;
                                  final types = entry.value;
                                  return [
                                    DropdownMenuItem<int>(
                                      value: -1,
                                      enabled: false,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.blue,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          superTypeName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ...types.map(
                                      (type) => DropdownMenuItem<int>(
                                        value: type['id'],
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                          ),
                                          child: Text(type['name']['fr']),
                                        ),
                                      ),
                                    ),
                                  ];
                                }),
                              ],
                              onChanged: _onTypeChanged,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Niveau minimum',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onSubmitted: _onMinLevelChanged,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Niveau maximum',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onSubmitted: _onMaxLevelChanged,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder<List<dynamic>>(
                    future: _characteristics,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text('Pas de caractéristique trouvée'),
                        );
                      } else {
                        final characteristics = snapshot.data!;
                        return MultiSelectDropdown(
                          items: characteristics,
                          selectedIds: _selectedCharacteristics,
                          onSelectionChanged: (selected) {
                            setState(() {
                              _selectedCharacteristics.clear();
                              _selectedCharacteristics.addAll(selected);
                              _skip = 0;
                              _data = _fetchItems();
                            });
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    snapshot.data!['items'].isEmpty) {
                  return Center(child: Text('Pas d\'objet trouvé'));
                } else {
                  final items = snapshot.data!['items'];
                  return Column(
                    children: [
                      Text(
                        'Nombre d\'objets trouvés: ${snapshot.data!['total']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                              expansionTileTheme: ExpansionTileThemeData(
                                tilePadding: EdgeInsets.zero,
                                childrenPadding: EdgeInsets.zero,
                              ),
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.all(8.0),
                              child: ExpansionTile(
                                leading: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Image.network(item['img']),
                                ),
                                title: Text(item['name']['fr']),
                                subtitle: Text(
                                  "${item['type']['name']['fr']} Niv. ${item['level']}",
                                ),
                                trailing: FutureBuilder<bool>(
                                  future: _storageService.isItemLiked(
                                    item['id'],
                                  ),
                                  builder: (context, likeSnapshot) {
                                    if (likeSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Icon(Icons.favorite_border);
                                    } else if (likeSnapshot.hasError) {
                                      return Icon(Icons.error);
                                    } else {
                                      final isLiked =
                                          likeSnapshot.data ?? false;
                                      return IconButton(
                                        icon: Icon(
                                          isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isLiked ? Colors.red : null,
                                        ),
                                        onPressed:
                                            () => _toggleLikeItem(item['id']),
                                      );
                                    }
                                  },
                                ),
                                children: [
                                  ListTile(
                                    title: Text('Statistiques de l\'objet'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Level: ${item['level']}'),
                                        Text(
                                          'Type: ${item['type']['name']['fr']}',
                                        ),
                                        Text(
                                          'Description: ${item['description']['fr']}',
                                        ),
                                        // Text(
                                        //   'Panoplie: ${item['itemSet']?['name']?['fr'] ?? 'N/A'}',
                                        // ),

                                        // Add more item statistics here
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            if (_totalItems > 0)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      (_totalItems / 10).ceil(),
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () => _onPageChanged(index * 10),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  (_skip / 10).round() == index
                                      ? Colors.blue
                                      : Colors.transparent,
                              border: Border.all(color: Colors.blue),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color:
                                      (_skip / 10).round() == index
                                          ? Colors.white
                                          : Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
