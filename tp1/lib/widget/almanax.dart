import 'package:flutter/material.dart';
import '../storage.dart';

class Almanax extends StatefulWidget {
  const Almanax({super.key});

  @override
  State<Almanax> createState() => _AlmanaxState();
}

class _AlmanaxState extends State<Almanax> {
  late Future<Map<dynamic, dynamic>> _data;
  DateTime date = DateTime.now();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _data = _storageService.fetchAlmanaxData(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 239, 245, 255),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: FittedBox(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                date = date.subtract(const Duration(days: 1));
                                _data = _storageService.fetchAlmanaxData(date);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(10),
                            ),
                            child: const Icon(Icons.arrow_back),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Almanax du \n ${date.day}/${date.month}/${date.year}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                date = date.add(const Duration(days: 1));
                                _data = _storageService.fetchAlmanaxData(date);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(10),
                            ),
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder<Map<dynamic, dynamic>>(
                      future: _data,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (snapshot.hasData) {
                          final data = snapshot.data!;
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    0,
                                    8,
                                    0,
                                  ),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Image.network(data['item']['img']),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Offrande',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '- ${data['quest']['steps'][0]['objectives'][0]['need']['generated']['quantities'][0]} x ${data['item']['name']['fr']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Center(child: Text('No data available'));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
