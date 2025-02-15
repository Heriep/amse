import 'package:flutter/material.dart';
import 'geticon.dart';

class MultiSelectDropdown extends StatefulWidget {
  final List<dynamic> items;
  final List<int> selectedIds;
  final ValueChanged<List<int>> onSelectionChanged;

  const MultiSelectDropdown({
    super.key,
    required this.items,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  @override
  MultiSelectDropdownState createState() => MultiSelectDropdownState();
}

class MultiSelectDropdownState extends State<MultiSelectDropdown> {
  @override
  Widget build(BuildContext context) {
    String displayText =
        widget.selectedIds.isEmpty
            ? "Sélectionner des caractéristiques"
            : widget.items
                .where((item) => widget.selectedIds.contains(item['id']))
                .map((item) => item['name']['fr'])
                .join(', ');
    return DropdownButtonHideUnderline(
      child: GestureDetector(
        onTap: () async {
          final selected = await showDialog<List<int>>(
            context: context,
            builder:
                (_) => MultiSelectDialog(
                  items: widget.items,
                  selectedIds: widget.selectedIds,
                ),
          );
          if (selected != null) widget.onSelectionChanged(selected);
        },
        child: InputDecorator(
          decoration: InputDecoration(labelText: "Caractéristiques"),
          child: Text(displayText),
        ),
      ),
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final List<dynamic> items;
  final List<int> selectedIds;

  const MultiSelectDialog({
    super.key,
    required this.items,
    required this.selectedIds,
  });

  @override
  MultiSelectDialogState createState() => MultiSelectDialogState();
}

class MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    Map<int, List<dynamic>> groupedItems = {};
    for (var item in widget.items) {
      final int categoryId = item['categoryId'];
      groupedItems.putIfAbsent(categoryId, () => []).add(item);
    }
    final categories = {
      2: 'Primaire',
      3: 'Secondaire',
      4: 'Dommage',
      5: 'Résistance',
    };

    List<Widget> contentWidgets = [];
    for (var catId in [2, 3, 4, 5]) {
      if (groupedItems.containsKey(catId)) {
        contentWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              categories[catId]!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        );
        contentWidgets.add(
          Wrap(
            spacing: 5.0,
            runSpacing: 0,
            children:
                groupedItems[catId]!.map<Widget>((item) {
                  final id = item['id'] as int;
                  return FilterChip(
                    avatar: getIcon(item['name']['fr'], item['categoryId']),
                    label: Text(
                      item['name']['fr'],
                      style: const TextStyle(fontSize: 11),
                    ),
                    selected: _selected.contains(id),
                    showCheckmark: false,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selected.add(id);
                        } else {
                          _selected.remove(id);
                        }
                      });
                    },
                  );
                }).toList(),
          ),
        );
      }
    }

    return AlertDialog(
      title: const Text("Sélectionner des caractéristiques"),
      content: SingleChildScrollView(child: ListBody(children: contentWidgets)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text("Valider"),
        ),
      ],
    );
  }
}
