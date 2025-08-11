import 'package:flutter/material.dart';
import '../models/Cells.dart';
import '../main.dart';

bool isNumeric(String s) {
  return int.tryParse(s) != null;
}

getCellType(barcode) {
  if (barcode == "") {
    return;
  }
  var celltype = "";
  var bc = barcode;
  if (bc.length <= 3) {
    if (bc.substring(0, 2).toLowerCase() == "va" ||
        bc.substring(0, 1).toLowerCase() == "a") {
      celltype = "Vanadium A";
    } else if (bc.substring(0, 2).toLowerCase() == "vb") {
      celltype = "Vanadium B";
    } else if (bc.substring(0, 1).toLowerCase() == "b") {
      celltype = "Vanadium B";
    } else if (bc.substring(0, 2).toLowerCase() == "vc" ||
        bc.substring(0, 1).toLowerCase() == "c") {
      celltype = "Vanadium C";
    } else if (bc.substring(0, 2).toLowerCase() == "vd" ||
        bc.substring(0, 1).toLowerCase() == "d") {
      celltype = "Vanadium D";
    } else if (bc.substring(0, 1).toLowerCase() == "d" &&
        isNumeric(bc.substring(1, 1))) {
      celltype = "Vanadium D";
    } else if (bc.substring(0, 3).toLowerCase() == "bhl") {
      celltype = "Brookhaven SC";
    } else if (bc.substring(0, 2).toLowerCase() == "ve" ||
        bc.substring(0, 1).toLowerCase() == "e") {
      celltype = "Vanadium E";
    } else {
      celltype = "a generic cell";
    }
  } else {
    if (bc.substring(0, 2).toLowerCase() == "va" ||
        bc.substring(0, 1).toLowerCase() == "a") {
      celltype = "Vanadium A";
    } else if (bc.substring(0, 2).toLowerCase() == "vb") {
      celltype = "Vanadium B";
    } else if (bc.substring(0, 1).toLowerCase() == "b" &&
        isNumeric(bc.substring(1, 1))) {
      celltype = "Vanadium B";
    } else if (bc.substring(0, 2).toLowerCase() == "vc" ||
        bc.substring(0, 1).toLowerCase() == "c") {
      celltype = "Vanadium C";
    } else if (bc.substring(0, 2).toLowerCase() == "vd") {
      celltype = "Vanadium D";
    } else if (bc.substring(0, 1).toLowerCase() == "d" &&
        isNumeric(bc.substring(1, 1))) {
      celltype = "Vanadium D";
    } else if (bc.substring(0, 3).toLowerCase() == "bhl") {
      celltype = "Brookhaven SC";
    } else if (bc.substring(0, 2).toLowerCase() == "ve" ||
        bc.substring(0, 1).toLowerCase() == "e") {
      celltype = "Vanadium E";
    } else if (bc.substring(0, 3).toLowerCase() == "ssc") {
      celltype = "Single Crystal Small";
    } else if (bc.substring(0, 3).toLowerCase() == "lsc") {
      celltype = "Single Crystal Large";
    } else if (bc.substring(0, 3).toLowerCase() == "dcs" ||
        bc.substring(0, 3).toLowerCase() == "dsc") {
      celltype = "DCS Al";
    } else if (bc.substring(0, 3).toLowerCase() == "g12") {
      celltype = "Al 1.2cc";
    } else if (bc.substring(0, 3).toLowerCase() == "g16") {
      celltype = "Al 1.6cc";
    } else if (bc.substring(0, 3).toLowerCase() == "g31") {
      celltype = "Al 3.1cc";
    } else if (bc.substring(0, 3).toLowerCase() == "g63") {
      celltype = "Al 6.3cc";
    } else {
      celltype = "a generic cell";
    }
  }
  return celltype;
}

void addToEmptyCells({BuildContext? context, Cells? cell}) {
  final container = MyInheritedWidget.of(context, false);
  var selected = cell!.description;
  if (selected == "Vanadium A") {
    container.addEmptyVanA(cell);
  } else if (selected == "Vanadium B") {
    container.addEmptyVanB(cell);
  } else if (selected == "Vanadium C") {
    container.addEmptyVanC(cell);
  } else if (selected == "Vanadium D") {
    container.addEmptyVanD(cell);
  } else if (selected == "Vanadium E") {
    container.addEmptyVanE(cell);
  } else if (selected == "Brookhaven SC") {
    container.addEmptyBrookhaven(cell);
  } else if (selected == "Al 6.3cc") {
    container.addEmptyAl63(cell);
  } else if (selected == "Al 3.1cc") {
    container.addEmptyAl31(cell);
  } else if (selected == "Al 1.6cc") {
    container.addEmptyAl16(cell);
  } else if (selected == "Al 1.2cc") {
    container.addEmptyAl12(cell);
  } else if (selected == "DCS Al") {
    container.addEmptyDCS(cell);
  } else if (selected == "Single Crystal Small") {
    container.addEmptySS(cell);
  } else if (selected == "Single Crystal Large") {
    container.addEmptySS(cell);
  } else {
    container.addEmptyOther(cell);
  }
}

void addToFullCells({BuildContext? context, Cells? cell}) {
  final container = MyInheritedWidget.of(context, false);
  var selected = cell!.description;
  if (selected == "Vanadium A") {
    container.addFullVanA(cell);
  } else if (selected == "Vanadium B") {
    container.addFullVanB(cell);
  } else if (selected == "Vanadium C") {
    container.addFullVanC(cell);
  } else if (selected == "Vanadium D") {
    container.addFullVanD(cell);
  } else if (selected == "Vanadium E") {
    container.addFullVanE(cell);
  } else if (selected == "Brookhaven SC") {
    container.addFullBrookhaven(cell);
  } else if (selected == "Al 6.3cc") {
    container.addFullAl63(cell);
  } else if (selected == "Al 3.1cc") {
    container.addFullAl31(cell);
  } else if (selected == "Al 1.6cc") {
    container.addFullAl16(cell);
  } else if (selected == "Al 1.2cc") {
    container.addFullAl12(cell);
  } else if (selected == "DCS Al") {
    container.addFullDCS(cell);
  } else if (selected == "Single Crystal Small") {
    container.addFullSS(cell);
  } else if (selected == "Single Crystal Large") {
    container.addFullSS(cell);
  } else {
    container.addFullOther(cell);
  }
}
