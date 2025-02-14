import 'package:flutter/material.dart';
import '../storage.dart';

class PageItem extends StatefulWidget {
  const PageItem({super.key});

  @override
  State<PageItem> createState() => _PageItemState();
}

class _PageItemState extends State<PageItem> {
  late Future<Map<String, dynamic>> _data;
  final StorageService _storageService = StorageService();
  int _typeId = 1;
  int _skip = 0;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _data = _fetchItems();
  }

  Future<Map<String, dynamic>> _fetchItems() async {
    final result = await _storageService.fetchItemsData(_typeId, _skip);
    setState(() {
      _totalItems = result['total'];
    });
    return result;
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
      appBar: AppBar(title: Text('Items')),
      body: Column(
        children: [
          DropdownButton<int>(
            value: _typeId,
            items:
                List.generate(10, (index) => index + 1)
                    .map(
                      (e) => DropdownMenuItem<int>(
                        value: e,
                        child: Text('Type $e'),
                      ),
                    )
                    .toList(),
            onChanged: _onTypeChanged,
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
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item['name']['fr']),
                        subtitle: Text('Level: ${item['level']}'),
                      );
                    },
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
