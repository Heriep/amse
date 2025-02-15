import 'package:flutter/material.dart';

Widget? getIcon(String itemName, int categoryId) {
  if (categoryId == 2) {
    if (itemName == "Points d'action (PA)") {
      return Image.network('https://dofusdb.fr/icons/effects/pa.png');
    } else if (itemName == "Points de mouvement (PM)") {
      return Image.network('https://dofusdb.fr/icons/effects/pm.png');
    } else if (itemName == "Portée") {
      return Image.network('https://dofusdb.fr/icons/effects/po.png');
    } else if (itemName == "Vitalité") {
      return Image.network('https://dofusdb.fr/icons/effects/pv.png');
    } else if (itemName == "Agilité") {
      return Image.network('https://dofusdb.fr/icons/effects/air.png');
    } else if (itemName == "Chance") {
      return Image.network('https://dofusdb.fr/icons/effects/eau.png');
    } else if (itemName == "Force") {
      return Image.network('https://dofusdb.fr/icons/effects/terre.png');
    } else if (itemName == "Intelligence") {
      return Image.network('https://dofusdb.fr/icons/effects/feu.png');
    } else if (itemName == "Puissance") {
      return Image.network('https://dofusdb.fr/icons/effects/puissance.png');
    } else if (itemName == "Critique") {
      return Image.network('https://dofusdb.fr/icons/effects/critique.png');
    } else if (itemName == "Sagesse") {
      return Image.network('https://dofusdb.fr/icons/effects/sagesse.png');
    }
  } else if (categoryId == 3) {
    if (itemName == "Retrait PA") {
      return Image.network('https://dofusdb.fr/icons/effects/retraitPA.png');
    } else if (itemName == "Esquive PA") {
      return Image.network('https://dofusdb.fr/icons/effects/esquivePA.png');
    } else if (itemName == "Retrait PM") {
      return Image.network('https://dofusdb.fr/icons/effects/retraitPM.png');
    } else if (itemName == "Esquive PM") {
      return Image.network('https://dofusdb.fr/icons/effects/esquivePM.png');
    } else if (itemName == "Soins") {
      return Image.network('https://dofusdb.fr/icons/effects/soin.png');
    } else if (itemName == "Tacle") {
      return Image.network('https://dofusdb.fr/icons/effects/tacle.png');
    } else if (itemName == "Fuite") {
      return Image.network('https://dofusdb.fr/icons/effects/fuite.png');
    } else if (itemName == "Initiative") {
      return Image.network('https://dofusdb.fr/icons/effects/initiative.png');
    } else if (itemName == "Invocation") {
      return Image.network('https://dofusdb.fr/icons/effects/invocation.png');
    } else if (itemName == "Prospection") {
      return Image.network('https://dofusdb.fr/icons/effects/pp.png');
    } else if (itemName == "Pods") {
      return Image.network('https://dofusdb.fr/icons/effects/pod.png');
    }
  } else if (categoryId == 4) {
    if (itemName == "Dommages") {
      return Image.network('https://dofusdb.fr/icons/effects/dommages.png');
    } else if (itemName == "Dommages critiques") {
      return Image.network('https://dofusdb.fr/icons/effects/dmgCritique.png');
    } else if (itemName == "Neutre (fixe)") {
      return Image.network('https://dofusdb.fr/icons/effects/neutre.png');
    } else if (itemName == "Terre (fixe)") {
      return Image.network('https://dofusdb.fr/icons/effects/terre.png');
    } else if (itemName == "Feu (fixe)") {
      return Image.network('https://dofusdb.fr/icons/effects/feu.png');
    } else if (itemName == "Eau (fixe)") {
      return Image.network('https://dofusdb.fr/icons/effects/eau.png');
    } else if (itemName == "Air (fixe)") {
      return Image.network('https://dofusdb.fr/icons/effects/air.png');
    } else if (itemName == "Renvoi") {
      return Image.network('https://dofusdb.fr/icons/effects/renvoi.png');
    } else if (itemName == "Pièges (fixe)" ||
        itemName == "Pièges (Puissance)") {
      return Image.network(
        'https://dofusdb.fr/icons/characteristics/tx_trap.png',
      );
    } else if (itemName == "Poussée") {
      return Image.network('https://dofusdb.fr/icons/effects/dmgPoussee.png');
    } else if (itemName == "Sorts") {
      return Image.network('https://dofusdb.fr/icons/effects/dmgSort.png');
    } else if (itemName == "Armes") {
      return Image.network('https://dofusdb.fr/icons/effects/dmgArme.png');
    } else if (itemName == "Distance") {
      return Image.network('https://dofusdb.fr/icons/effects/dmgDistance.png');
    } else if (itemName == "Mêlée") {
      return Image.network('https://dofusdb.fr/icons/effects/dmgMelee.png');
    }
  } else if (categoryId == 5) {
    if (itemName == "Neutre (fixe)" || itemName == "Neutre (%)") {
      return Image.network('https://dofusdb.fr/icons/effects/resNeutre.png');
    } else if (itemName == "Terre (fixe)" || itemName == "Terre (%)") {
      return Image.network('https://dofusdb.fr/icons/effects/resTerre.png');
    } else if (itemName == "Feu (fixe)" || itemName == "Feu (%)") {
      return Image.network('https://dofusdb.fr/icons/effects/resFeu.png');
    } else if (itemName == "Eau (fixe)" || itemName == "Eau (%)") {
      return Image.network('https://dofusdb.fr/icons/effects/resEau.png');
    } else if (itemName == "Air (fixe)" || itemName == "Air (%)") {
      return Image.network('https://dofusdb.fr/icons/effects/resAir.png');
    } else if (itemName == "Coups critiques (fixe)") {
      return Image.network('https://dofusdb.fr/icons/effects/resCrit.png');
    } else if (itemName == "Poussée (fixe)") {
      return Image.network('https://dofusdb.fr/icons/effects/resPoussee.png');
    } else if (itemName == "Sorts") {
      return Image.network('https://dofusdb.fr/icons/effects/resSort.png');
    } else if (itemName == "Arme") {
      return Image.network('https://dofusdb.fr/icons/effects/resArme.png');
    } else if (itemName == "Distance") {
      return Image.network('https://dofusdb.fr/icons/effects/resDistance.png');
    } else if (itemName == "Mêlée") {
      return Image.network('https://dofusdb.fr/icons/effects/resMelee.png');
    }
  }
  return null;
}
