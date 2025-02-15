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
      _data = _fetchItems();
    });
  }

  void _onMaxLevelChanged(String value) {
    setState(() {
      _maxLevel = int.tryParse(value) ?? 200;
      _data = _fetchItems();
    });
  }

  void _onItemNameSubmitted(String value) {
    setState(() {
      _itemName = value;
      _data = _fetchItems();
    });
  }

  void _onPageChanged(int newSkip) {
    setState(() {
      _skip = newSkip;
      _data = _fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _itemNameController,
            decoration: InputDecoration(labelText: 'Nom de l\'objet'),
            onSubmitted: _onItemNameSubmitted,
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
              _onItemNameSubmitted(_itemNameController.text);
            },
          ),
          ExpansionTile(
            title: Text('Options de recherche avancées'),
            children: [
              FutureBuilder<List<dynamic>>(
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
                                          color: Colors.orange,
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
                                        color: Colors.orange,
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
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: _onMinLevelChanged,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Niveau maximum',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: _onMaxLevelChanged,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
              FutureBuilder<List<dynamic>>(
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
            ],
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
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
                        'Nombre d\'items trouvés: ${snapshot.data!['total']}',
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              leading: Image.network(item['img']),
                              title: Text(item['name']['fr']),
                              subtitle: Text('Level: ${item['level']}'),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          if (_totalItems >= 10)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  (_totalItems / 10).ceil(),
                  (index) => TextButton(
                    onPressed: () => _onPageChanged(index * 10),
                    child: Text('${index + 1}'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
