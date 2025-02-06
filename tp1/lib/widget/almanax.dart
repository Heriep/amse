import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Almanax extends StatefulWidget {
  const Almanax({super.key});

  @override
  State<Almanax> createState() => _AlmanaxState();
}

class _AlmanaxState extends State<Almanax> {
  late Future<Map<dynamic, dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _data = fetchAlmanaxData();
  }

  Future<Map<dynamic, dynamic>> fetchAlmanaxData() async {
    final almanaxResponse = await http.get(
      Uri.parse('https://api.dofusdb.fr/almanax?date=02/04/2025'),
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
          return {
            'almanax': almanaxData,
            'quest': questData['data'][0],
            'item': itemData['data'][0],
          };
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(20),
          ),
          child: FutureBuilder<Map<dynamic, dynamic>>(
            future: _data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final data = snapshot.data!;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(data['almanax']['m_id'].toString()),
                      Text(
                        data['quest']['steps'][0]['objectives'][0]['need']['generated']['items'][0]
                            .toString(),
                      ),
                      Image.network(data['item']['img']),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('No data available'));
              }
            },
          ),
        ),
      ],
    );
  }
}
