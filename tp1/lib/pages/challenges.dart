import 'package:flutter/material.dart';
import '../storage.dart';

class PageChallenges extends StatefulWidget {
  const PageChallenges({super.key});

  @override
  State<PageChallenges> createState() => _PageChallengesState();
}

class _PageChallengesState extends State<PageChallenges> {
  late Future<List<dynamic>> _data;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _data = _storageService.fetchChallengesData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 150,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return Card(
                          color: const Color.fromARGB(255, 153, 209, 92),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final challenges = snapshot.data!;
                  return GridChallenge(challenges: challenges);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GridChallenge extends StatefulWidget {
  const GridChallenge({super.key, required this.challenges});

  final List challenges;

  @override
  GridChallengeState createState() => GridChallengeState();
}

class GridChallengeState extends State<GridChallenge> {
  @override
  void initState() {
    super.initState();
  }

  void _toggleTileExpansion(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final challenge = widget.challenges[index];
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFa8e063),
                          Color(0xFF56ab2f),
                        ], // Gradient de vert
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51), // 0.2 * 255 = 51
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // décalage de l'ombre
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        challenge['img'],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    challenge['name']['fr'],
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    challenge['description']['fr'],
                    overflow: TextOverflow.clip,
                    style: const TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Fermer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 100,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: widget.challenges.length,
        itemBuilder: (context, index) {
          final challenge = widget.challenges[index];
          return GestureDetector(
            onTap: () => _toggleTileExpansion(index),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFa8e063),
                    Color(0xFF56ab2f),
                  ], // Gradient de vert
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51), // 0.2 * 255 = 51
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // décalage de l'ombre
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Card(
                color:
                    Colors
                        .transparent, // rendre la carte transparente pour voir le gradient
                elevation: 0, // enlever l'élévation de la carte
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        challenge['img'],
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FittedBox(
                        child: Text(
                          challenge['name']['fr'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
