import 'package:flutter/material.dart';

Widget? getIcon(String itemName, int categoryId) {
  if (categoryId == 2) {
    if (itemName == "Points d'action (PA)") {
      return Image.asset('assets/icons_effects/pa.png');
    } else if (itemName == "Points de mouvement (PM)") {
      return Image.asset('assets/icons_effects/pm.png');
    } else if (itemName == "Portée") {
      return Image.asset('assets/icons_effects/po.png');
    } else if (itemName == "Vitalité") {
      return Image.asset('assets/icons_effects/pv.png');
    } else if (itemName == "Agilité") {
      return Image.asset('assets/icons_effects/air.png');
    } else if (itemName == "Chance") {
      return Image.asset('assets/icons_effects/eau.png');
    } else if (itemName == "Force") {
      return Image.asset('assets/icons_effects/terre.png');
    } else if (itemName == "Intelligence") {
      return Image.asset('assets/icons_effects/feu.png');
    } else if (itemName == "Puissance") {
      return Image.asset('assets/icons_effects/puissance.png');
    } else if (itemName == "Critique") {
      return Image.asset('assets/icons_effects/critique.png');
    } else if (itemName == "Sagesse") {
      return Image.asset('assets/icons_effects/sagesse.png');
    }
  } else if (categoryId == 3) {
    if (itemName == "Retrait PA") {
      return Image.asset('assets/icons_effects/retraitPA.png');
    } else if (itemName == "Esquive PA") {
      return Image.asset('assets/icons_effects/esquivePA.png');
    } else if (itemName == "Retrait PM") {
      return Image.asset('assets/icons_effects/retraitPM.png');
    } else if (itemName == "Esquive PM") {
      return Image.asset('assets/icons_effects/esquivePM.png');
    } else if (itemName == "Soins") {
      return Image.asset('assets/icons_effects/soin.png');
    } else if (itemName == "Tacle") {
      return Image.asset('assets/icons_effects/tacle.png');
    } else if (itemName == "Fuite") {
      return Image.asset('assets/icons_effects/fuite.png');
    } else if (itemName == "Initiative") {
      return Image.asset('assets/icons_effects/initiative.png');
    } else if (itemName == "Invocation") {
      return Image.asset('assets/icons_effects/invocation.png');
    } else if (itemName == "Prospection") {
      return Image.asset('assets/icons_effects/pp.png');
    } else if (itemName == "Pods") {
      return Image.asset('assets/icons_effects/pod.png');
    }
  } else if (categoryId == 4) {
    if (itemName == "Dommages") {
      return Image.asset('assets/icons_effects/dommages.png');
    } else if (itemName == "Dommages critiques") {
      return Image.asset('assets/icons_effects/dmgCritique.png');
    } else if (itemName == "Neutre (fixe)") {
      return Image.asset('assets/icons_effects/neutre.png');
    } else if (itemName == "Terre (fixe)") {
      return Image.asset('assets/icons_effects/terre.png');
    } else if (itemName == "Feu (fixe)") {
      return Image.asset('assets/icons_effects/feu.png');
    } else if (itemName == "Eau (fixe)") {
      return Image.asset('assets/icons_effects/eau.png');
    } else if (itemName == "Air (fixe)") {
      return Image.asset('assets/icons_effects/air.png');
    } else if (itemName == "Renvoi") {
      return Image.asset('assets/icons_effects/renvoi.png');
    } else if (itemName == "Pièges (fixe)" ||
        itemName == "Pièges (Puissance)") {
      return Image.asset('assets/icons_effects/tx_trap.png');
    } else if (itemName == "Poussée") {
      return Image.asset('assets/icons_effects/dmgPoussee.png');
    } else if (itemName == "Sorts") {
      return Image.asset('assets/icons_effects/dmgSort.png');
    } else if (itemName == "Armes") {
      return Image.asset('assets/icons_effects/dmgArme.png');
    } else if (itemName == "Distance") {
      return Image.asset('assets/icons_effects/dmgDistance.png');
    } else if (itemName == "Mêlée") {
      return Image.asset('assets/icons_effects/dmgMelee.png');
    }
  } else if (categoryId == 5) {
    if (itemName == "Neutre (fixe)" || itemName == "Neutre (%)") {
      return Image.asset('assets/icons_effects/resNeutre.png');
    } else if (itemName == "Terre (fixe)" || itemName == "Terre (%)") {
      return Image.asset('assets/icons_effects/resTerre.png');
    } else if (itemName == "Feu (fixe)" || itemName == "Feu (%)") {
      return Image.asset('assets/icons_effects/resFeu.png');
    } else if (itemName == "Eau (fixe)" || itemName == "Eau (%)") {
      return Image.asset('assets/icons_effects/resEau.png');
    } else if (itemName == "Air (fixe)" || itemName == "Air (%)") {
      return Image.asset('assets/icons_effects/resAir.png');
    } else if (itemName == "Coups critiques (fixe)") {
      return Image.asset('assets/icons_effects/resCrit.png');
    } else if (itemName == "Poussée (fixe)") {
      return Image.asset('assets/icons_effects/resPoussee.png');
    } else if (itemName == "Sorts") {
      return Image.asset('assets/icons_effects/resSort.png');
    } else if (itemName == "Arme") {
      return Image.asset('assets/icons_effects/resArme.png');
    } else if (itemName == "Distance") {
      return Image.asset('assets/icons_effects/resDistance.png');
    } else if (itemName == "Mêlée") {
      return Image.asset('assets/icons_effects/resMelee.png');
    }
  }
  return null;
}
