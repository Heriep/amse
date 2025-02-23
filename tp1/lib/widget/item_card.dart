import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tp1/widget/geticon.dart';
import '../storage.dart';

class ItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onFavoriteChanged;

  const ItemCard({
    super.key,
    required this.item,
    required this.onFavoriteChanged,
  });

  @override
  ItemCardState createState() => ItemCardState();
}

class ItemCardState extends State<ItemCard> {
  late Future<List<Map<String, dynamic>>> _effectsData;

  @override
  void initState() {
    super.initState();
    _effectsData = _fetchEffectsData();
  }

  Future<List<Map<String, dynamic>>> _fetchEffectsData() async {
    List<Map<String, dynamic>> effectsData = [];
    if (widget.item['effects'] is List) {
      for (var effect in widget.item['effects']) {
        if (effect['characteristic'] == -1) {
          continue; // Ignore characteristics with value -1
        }
        final characteristic = await _fetchCharacteristic(
          effect['characteristic'],
        );
        if (characteristic.isEmpty) {
          continue; // Ignore characteristics that cannot be fetched
        }
        final effectData = await _fetchEffect(effect['effectId']);
        effectsData.add({
          'characteristic': characteristic,
          'effectData': effectData,
          'effect': effect,
        });
      }
    }
    return effectsData;
  }

  Future<Map<String, dynamic>> _fetchCharacteristic(
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
      return {}; // Ignore characteristics that cannot be fetched
    }
  }

  Future<Map<String, dynamic>> _fetchEffect(int effectId) async {
    final response = await http.get(
      Uri.parse('https://api.dofusdb.fr/effects/$effectId?lang=fr'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load effect data $effectId');
    }
  }

  Future<bool> _isItemLiked(int itemId) async {
    final storageService = StorageService();
    return await storageService.isItemLiked(itemId);
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
    widget.onFavoriteChanged();
  }

  String _cleanDescription(String description) {
    // Récupérer ce qu'il y a après #2
    final regexAfterHash = RegExp(r'#2\s*(.*)');
    final matchAfterHash = regexAfterHash.firstMatch(description);
    if (matchAfterHash != null) {
      description = matchAfterHash.group(1) ?? description;
    }

    // Enlever {{~ps}}{{~zs}} si elle existe
    final regexRemovePsZs = RegExp(r'\s*{{~ps}}{{~zs}}');
    description = description.replaceAll(regexRemovePsZs, '');

    return description;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Image.network(widget.item['img']),
          ),
          title: Text(widget.item['name']['fr']),
          subtitle: Text(
            "${widget.item['type']['name']['fr']} Niv. ${widget.item['level']}",
          ),
          trailing: FutureBuilder<bool>(
            future: _isItemLiked(widget.item['id']),
            builder: (context, likeSnapshot) {
              if (likeSnapshot.connectionState == ConnectionState.waiting) {
                return Icon(Icons.favorite_border);
              } else if (likeSnapshot.hasError) {
                return Icon(Icons.error);
              } else {
                final isLiked = likeSnapshot.data ?? false;
                return IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: () => _toggleLikeItem(widget.item['id']),
                );
              }
            },
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ([
                    'Amulette',
                    'Anneau',
                    'Arc',
                    'Arme magique',
                    'Baguette',
                    'Bâton',
                    'Dague',
                    'Faux',
                    'Hache',
                    'Lance',
                    'Marteau',
                    'Outil',
                    'Pelle',
                    'Pioche',
                    'Épée',
                    'Bouclier',
                    'Ceinture',
                    'Coiffe',
                    'Bottes',
                    'Arme',
                    'Cape',
                  ].contains(widget.item['type']['name']['fr']))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Effets:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _effectsData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    snapshot.data!.map<Widget>((data) {
                                      final characteristic =
                                          data['characteristic'];
                                      final effectData = data['effectData'];
                                      final effect = data['effect'];
                                      final icon = getIcon(
                                        characteristic['name']['fr'],
                                        characteristic['categoryId'],
                                      );
                                      final description =
                                          effect['to'] == 0
                                              ? '${effect['from']}'
                                              : '${effect['from']} à ${effect['to']}';
                                      final cleanedDescription =
                                          _cleanDescription(
                                            effectData['description']['fr'],
                                          );
                                      return Row(
                                        children: [
                                          if (icon != null)
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: icon,
                                            ),
                                          SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              '$description $cleanedDescription',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  Text(""),
                  if (widget.item['itemSet'] is! bool)
                    Text(
                      '${widget.item['itemSet']['name']['fr']}',
                      style: TextStyle(color: Colors.blue),
                    ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Poids: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: '${widget.item['realWeight']} pods',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('\n${widget.item['description']['fr']}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
