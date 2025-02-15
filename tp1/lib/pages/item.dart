import 'package:flutter/material.dart';
import '../storage.dart';

class PageItem extends StatefulWidget {
  const PageItem({super.key});

  @override
  State<PageItem> createState() => _PageItemState();
}

class _PageItemState extends State<PageItem> {
  late Future<Map<String, dynamic>> _data;
  late Future<List<dynamic>> _itemTypes;
  final StorageService _storageService = StorageService();
  int _typeId = 1;
  int _skip = 0;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _data = _fetchItems();
    _itemTypes = _fetchItemTypes();
  }

  Future<Map<String, dynamic>> _fetchItems() async {
    final result = await _storageService.fetchItemsData(_typeId, _skip);
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

  void _onTypeChanged(int? newValue) {
    if (newValue != null) {
      setState(() {
        _typeId = newValue;
        _skip = 0;
        _data = _fetchItems();
      });
    }
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
          FutureBuilder<List<dynamic>>(
            future: _itemTypes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No item types found'));
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

                return DropdownButton<int>(
                  value: _typeId,
                  items: [
                    DropdownMenuItem<int>(
                      value: 0,
                      child: Text('Tous les types (problème de performance)'),
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
                                top: BorderSide(color: Colors.orange, width: 2.0),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(type['name']['fr']),
                            ),
                          ),
                        ),
                      ];
                    }),
                  ],
                  onChanged: _onTypeChanged,
                );
              }
            },
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
                  return Center(child: Text('No items found'));
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
