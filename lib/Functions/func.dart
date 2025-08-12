import '../models/Cells.dart';

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
