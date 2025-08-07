import 'Sample.dart';

class Cells {
  String? id;
  String? barcode;
  String? description;
  String? archived;
  String? modified;
  String? added;
  Sample? sample;

  Cells(
      {this.id,
      this.barcode,
      this.description,
      this.archived,
      this.modified,
      this.added,
      this.sample});

  Cells.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    barcode = json['barcode'];
    description = json['description'];
    archived = json['archived'];
    modified = json['modified'];
    added = json['added'];
    sample =
        json['sample'] != null ? Sample.fromJson(json['sample']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['barcode'] = barcode;
    data['description'] = description;
    data['archived'] = archived;
    data['modified'] = modified;
    data['added'] = added;
    if (sample != null) {
      data['sample'] = sample!.toJson();
    }
    return data;
  }
}
