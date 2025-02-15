import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tp1/widget/almanax.dart';
import '../storage.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  PageHomeState createState() => PageHomeState();
}

class PageHomeState extends State<PageHome> {
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

  void _toggleLikeItem(int itemId) async {
    final storageService = StorageService();
    final isLiked = await storageService.isItemLiked(itemId);
    if (isLiked) {
      await storageService.unlikeItem(itemId);
    } else {
      await storageService.likeItem(itemId);
    }
    setState(() {});
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
          child: FutureBuilder<List<int>>(
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
                                trailing: FutureBuilder<bool>(
                                  future: StorageService().isItemLiked(
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
                                        onPressed: () {
                                          _toggleLikeItem(item['id']);
                                        },
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
                                        // Add more item statistics here
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
