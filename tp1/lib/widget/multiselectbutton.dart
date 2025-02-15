import 'package:flutter/material.dart';

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
                    avatar: () {
                      final itemName = item['name']['fr'];
                      final categoryId = item['categoryId'];
                      if (categoryId == 2) {
                        if (itemName == "Points d'action (PA)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/pa.png',
                          );
                        } else if (itemName == "Points de mouvement (PM)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/pm.png',
                          );
                        } else if (itemName == "Portée") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/po.png',
                          );
                        } else if (itemName == "Vitalité") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/pv.png',
                          );
                        } else if (itemName == "Agilité") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/air.png',
                          );
                        } else if (itemName == "Chance") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/eau.png',
                          );
                        } else if (itemName == "Force") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/terre.png',
                          );
                        } else if (itemName == "Intelligence") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/feu.png',
                          );
                        } else if (itemName == "Puissance") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/puissance.png',
                          );
                        } else if (itemName == "Critique") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/critique.png',
                          );
                        } else if (itemName == "Sagesse") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/sagesse.png',
                          );
                        }
                      } else if (categoryId == 3) {
                        if (itemName == "Retrait PA") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/retraitPA.png',
                          );
                        } else if (itemName == "Esquive PA") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/esquivePA.png',
                          );
                        } else if (itemName == "Retrait PM") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/retraitPM.png',
                          );
                        } else if (itemName == "Esquive PM") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/esquivePM.png',
                          );
                        } else if (itemName == "Soins") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/soin.png',
                          );
                        } else if (itemName == "Tacle") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/tacle.png',
                          );
                        } else if (itemName == "Fuite") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/fuite.png',
                          );
                        } else if (itemName == "Initiative") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/initiative.png',
                          );
                        } else if (itemName == "Invocation") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/invocation.png',
                          );
                        } else if (itemName == "Prospection") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/pp.png',
                          );
                        } else if (itemName == "Pods") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/pod.png',
                          );
                        }
                      } else if (categoryId == 4) {
                        if (itemName == "Dommages") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/dommages.png',
                          );
                        } else if (itemName == "Dommages critiques") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/dmgCritique.png',
                          );
                        } else if (itemName == "Neutre (fixe)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/neutre.png',
                          );
                        } else if (itemName == "Terre (fixe)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/terre.png',
                          );
                        } else if (itemName == "Feu (fixe)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/feu.png',
                          );
                        } else if (itemName == "Eau (fixe)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/eau.png',
                          );
                        } else if (itemName == "Air (fixe)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/air.png',
                          );
                        } else if (itemName == "Renvoi") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/renvoi.png',
                          );
                        } else if (itemName == "Pièges (fixe)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/characteristics/tx_trap.png',
                          );
                        } else if (itemName == "Pièges (Puissance)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/characteristics/tx_trap.png',
                          );
                        } else if (itemName == "Poussée") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/dmgPoussee.png',
                          );
                        } else if (itemName == "Sorts") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/dmgSort.png',
                          );
                        } else if (itemName == "Armes") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/dmgArme.png',
                          );
                        } else if (itemName == "Distance") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/dmgDistance.png',
                          );
                        } else if (itemName == "Mêlée") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/dmgMelee.png',
                          );
                        }
                      } else if (categoryId == 5) {
                        if (itemName == "Neutre (fixe)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resNeutre.png',
                          );
                        } else if (itemName == "Neutre (%)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resNeutre.png',
                          );
                        } else if (itemName == "Terre (fixe)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resTerre.png',
                          );
                        } else if (itemName == "Terre (%)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resTerre.png',
                          );
                        } else if (itemName == "Feu (fixe)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resFeu.png',
                          );
                        } else if (itemName == "Feu (%)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resFeu.png',
                          );
                        } else if (itemName == "Eau (fixe)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resEau.png',
                          );
                        } else if (itemName == "Eau (%)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resEau.png',
                          );
                        } else if (itemName == "Air (fixe)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resAir.png',
                          );
                        } else if (itemName == "Air (%)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resAir.png',
                          );
                        } else if (itemName == "Coups critiques (fixe)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resCrit.png',
                          );
                        } else if (itemName == "Poussée (fixe)") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resPoussee.png',
                          );
                        } else if (itemName == "Sorts") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resSort.png',
                          );
                        } else if (itemName == "Arme") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resArme.png',
                          );
                        } else if (itemName == "Distance") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resDistance.png',
                          );
                        } else if (itemName == "Mêlée") {
                          return Image.network(
                            'https://dofusdb.fr/icons/effects/resMelee.png',
                          );
                        }
                      }
                      return null;
                    }(),
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
