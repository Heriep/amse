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
                      itemCount: 4,
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
          backgroundColor: const Color.fromARGB(255, 153, 209, 92),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.network(challenge['img']),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    challenge['name']['fr'],
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 16.0),
                  child: Text(
                    challenge['description']['fr'],
                    overflow: TextOverflow.clip,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
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
          maxCrossAxisExtent: 150,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: widget.challenges.length,
        itemBuilder: (context, index) {
          final challenge = widget.challenges[index];
          return GestureDetector(
            onTap: () => _toggleTileExpansion(index),
            child: Card(
              color: const Color.fromARGB(255, 153, 209, 92),
              child: Column(
                children: [
                  Expanded(
                    child: Image.network(challenge['img'], fit: BoxFit.contain),
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
          );
        },
      ),
    );
  }
}