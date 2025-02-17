import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tp1/widget/almanax.dart';
import 'package:tp1/widget/item_card.dart'; // Importez le fichier item_card.dart
import '../storage.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  PageHomeState createState() => PageHomeState();
}

class PageHomeState extends State<PageHome> {
  final ValueNotifier<bool> _favoritesUpdated = ValueNotifier(false);

  Future<List<int>> _fetchLikedItems() async {
    final storageService = StorageService();
    return await storageService.getLikedItems();
  }

  Future<Map<String, dynamic>?> _fetchItemDetails(int itemId) async {
    final response = await http.get(
      Uri.parse('https://api.dofusdb.fr/items?id[]=$itemId&lang=fr'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'].isNotEmpty) {
        return data['data'][0];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(child: Almanax()),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Favoris',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: _favoritesUpdated,
            builder: (context, _, __) {
              return FutureBuilder<List<int>>(
                future: _fetchLikedItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Pas de favoris'));
                  } else {
                    final likedItems = snapshot.data!;
                    return ListView.builder(
                      itemCount: likedItems.length,
                      itemBuilder: (context, index) {
                        final itemId = likedItems[index];
                        return FutureBuilder<Map<String, dynamic>?>(
                          future: _fetchItemDetails(itemId),
                          builder: (context, itemSnapshot) {
                            if (itemSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (itemSnapshot.hasError) {
                              return Center(
                                child: Text('Error: ${itemSnapshot.error}'),
                              );
                            } else if (!itemSnapshot.hasData) {
                              return Center(child: Text('Item non trouvé'));
                            } else {
                              final item = itemSnapshot.data!;
                              return ItemCard(
                                item: item,
                                onFavoriteChanged: () {
                                  _favoritesUpdated.value =
                                      !_favoritesUpdated.value;
                                },
                              );
                            }
                          },
                        );
                      },
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
