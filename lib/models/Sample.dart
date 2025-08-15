//import 'dart:convert';

class Sample {
  String? id;
  String? sampleId;
  String? sampleName;
  String? chemical;
  String? owner;
  String? username;
  String? cellbarcode;
  String? sampenvbarcode;
  String? unit;
  String? parent;
  String? archived;
  String? added;
  String? externalUser;
  String? quantity;
  String? form;
  String? date;
  String? extraNotes;
  String? ip;
  String? modified;
  List<Hazards>? hazards;
  String? haz1;
  String? haz2;
  String? haz3;
  String? haz4;
  String? imageURL;
  String?
      locationString; // this is composed of the following 4 fields seperated by "slash"
  String? place;
  String? location;
  String? locationid;
  String? drawer;
  bool? selected = false;

  String? get userName {
    return username;
  }

  Sample copyWith({
    String? id,
    String? sampleId,
    String? sampleName,
    String? chemical,
    String? owner,
    String? username,
    String? cellbarcode,
    String? sampenvbarcode,
    String? unit,
    String? parent,
    String? archived,
    String? added,
    String? externalUser,
    String? quantity,
    String? form,
    String? date,
    String? extraNotes,
    String? ip,
    String? modified,
    List<Hazards>? hazards,
    String? haz1,
    String? haz2,
    String? haz3,
    String? haz4,
    String? imageURL,
    bool? selected,
    String? location,
    String? place,
    String? locationid,
    String? drawer,
    String? locationString,
  }) {
    return Sample(
      id: id ?? this.id,
      sampleId: sampleId ?? this.sampleId,
      sampleName: sampleName ?? this.sampleName,
      chemical: chemical ?? this.chemical,
      owner: owner ?? this.owner,
      username: username ?? this.username,
      cellbarcode: cellbarcode ?? this.cellbarcode,
      sampenvbarcode: sampenvbarcode ?? this.sampenvbarcode,
      unit: unit ?? this.unit,
      parent: parent ?? this.parent,
      archived: archived ?? this.archived,
      added: added ?? this.added,
      externalUser: externalUser ?? this.externalUser,
      quantity: quantity ?? this.quantity,
      form: form ?? this.form,
      date: date ?? this.date,
      extraNotes: extraNotes ?? this.extraNotes,
      ip: ip ?? this.ip,
      modified: modified ?? this.modified,
      hazards: hazards ?? this.hazards,
      haz1: haz1 ?? this.haz1,
      haz2: haz2 ?? this.haz2,
      haz3: haz3 ?? this.haz3,
      haz4: haz4 ?? this.haz4,
      imageURL: imageURL ?? this.imageURL,
      selected: selected ?? this.selected,
      location: location ?? this.location,
      place: place ?? this.place,
      locationid: locationid ?? this.locationid,
      drawer: drawer ?? this.drawer,
      locationString: locationString ?? this.locationString,
    );
  }

  Sample(
      {this.id,
      this.sampleId,
      this.sampleName,
      this.chemical,
      this.owner,
      this.username,
      this.cellbarcode,
      this.sampenvbarcode,
      this.unit,
      this.parent,
      this.archived,
      this.added,
      this.externalUser,
      this.quantity,
      this.form,
      this.date,
      this.extraNotes,
      this.ip,
      this.modified,
      this.hazards,
      this.haz1,
      this.haz2,
      this.haz3,
      this.haz4,
      this.imageURL,
      this.selected,
      this.location,
      this.place,
      this.locationid,
      this.drawer,
      this.locationString});

  Sample.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['id'];
    sampleId = json['sample_id'] ?? json['sample_id'];
    sampleName = json['sample_name'] ?? json['sample_name'];
    chemical = json['chemical'] ?? json['chemical'];
    owner = json['owner'] ?? json['owner'];
    username = json['username'] ?? json['username'];
    cellbarcode = json['cellbarcode'] ?? json['cellbarcode'];
    // if (json['cellbarcode'] != null) {
    //   print("ID: " +
    //       (json['sample_id'].toString()) +
    //       " " +
    //       (json['cellbarcode'].toString()));
    // }
    sampenvbarcode = json['sampenvbarcode'] ?? json['sampenvbarcode'];
    unit = json['unit'] ?? json['unit'];
    parent = json['parent'] ?? json['parent'];
    archived = json['archived'] ?? json['archived'];
    added = json['added'] ?? json['added'];
    externalUser = json['external_user'] ?? json['external_user'];
    quantity = json['quantity'] ?? json['quantity'];
    form = json['form'] ?? json['form'];
    date = json['date'] ?? json['date'];
    extraNotes = json['extra_notes'] ?? json['extra_notes'];
    ip = json['ip'] ?? json['ip'];
    modified = json['modified'] ?? json['modified'];
    imageURL = json['imageURL'];
    if (json['hazards'] != null) {
      var i = 0;
      hazards = List<Hazards>.empty(growable: true);
      json['hazards'].forEach((v) {
        hazards!.add(Hazards.fromJson(v));
        // print(i.toString());
        // print(Hazards.fromJson(v).Haz);
        if (i == 0) {
          haz1 = Hazards.fromJson(v).haz!;
        }
        if (i == 1) {
          haz2 = Hazards.fromJson(v).haz!;
        }
        if (i == 2) {
          haz3 = Hazards.fromJson(v).haz!;
        }
        if (i == 3) {
          haz4 = Hazards.fromJson(v).haz!;
        }
        i++;
      });
    }
    // location = json['location'] != null
    //     ? new Location.fromJson(json['location'])
    //     : null;
    locationString = json['locationString'];
    if (locationString != "") {
      try {
        place = locationString!.split("/").toList()[0];
      } catch (e) {
        print("error in Samples.dart line 125 $sampleId ${sampleName!}");
        place = '';
      }
      try {
        location = locationString!.split("/").toList()[1];
      } catch (e) {
        print("error in Samples.dart line 130 $sampleId ${sampleName!}");
        location = '';
      }
      try {
        locationid = locationString!.split("/").toList()[2];
      } catch (e) {
        print("error in Samples.dart line 135 $sampleId ${sampleName!}");
        locationid = '';
      }
      try {
        drawer = locationString!.split("/").toList()[3];
      } catch (e) {
        print("error in Samples.dart line 140 $sampleId ${sampleName!}");
        drawer = '';
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (sampleId != "") {
      data['sample_id'] = (int.parse(sampleId!)).toString();
    }
    data['sample_name'] = sampleName;
    data['chemical'] = chemical;
    data['owner'] = owner;
    data['username'] = username;
    data['cellbarcode'] = cellbarcode;
    data['sampenvbarcode'] = sampenvbarcode;
    data['added'] = added;
    data['date'] = date;
    data['unit'] = unit;
    data['parent'] = parent;
    data['archived'] = archived;
    data['external_user'] = externalUser;
    data['quantity'] = quantity;
    data['form'] = form;
    data['extra_notes'] = extraNotes;
    data['hazards'] = [
      haz1 != null ? _Hazards(haz1!) : null,
      haz2 != null ? _Hazards(haz2!) : null,
      haz3 != null ? _Hazards(haz3!) : null,
      haz4 != null ? _Hazards(haz4!) : null
    ];
    // data['hazard1'] = this.haz1;
    // data['hazard2'] = this.haz2;
    // data['hazard3'] = this.haz3;
    // data['hazard4'] = this.haz4;
    data['place'] = place;
    data['location'] = location;
    data['locationid'] = locationid;
    data['drawer'] = drawer;
    return data;
  }
}

class _Hazards {
  String haz;
  _Hazards(this.haz);

  Map toJson() => {
        'hazard': haz,
      };
}

class Hazards {
  String? id;
  String? sampleKey;
  String? hazard;
  String? modified;

  String? get haz {
    return hazard;
  }

  Hazards({this.id, this.sampleKey, this.hazard, this.modified});

  Hazards.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['id'];
    sampleKey = json['sample_key'] ?? json['sample_key'];
    hazard = json['hazard'] ?? json['hazard'];
    modified = json['modified'] ?? json['modified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['id'] = this.id;
    // data['sample_key'] = this.sampleKey;
    data['hazard'] = hazard;
    // data['modified'] = this.modified;
    return data;
  }
}

class Location {
  String? id;
  String? text;
  String? barcode;
  String? parent;
  String? archived;
  String? modified;
  String? added;
  Location? nodes;

  Location(
      {this.id,
      this.text,
      this.barcode,
      this.parent,
      this.archived,
      this.modified,
      this.added,
      this.nodes});

  Location.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    text = json['text'];
    barcode = json['barcode'];
    parent = json['parent'];
    archived = json['archived'];
    modified = json['modified'];
    added = json['added'];
    nodes = json['nodes'] != null ? Location.fromJson(json['nodes']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['text'] = text;
    data['barcode'] = barcode;
    data['parent'] = parent;
    data['archived'] = archived;
    data['modified'] = modified;
    data['added'] = added;
    if (nodes != null) {
      data['nodes'] = nodes!.toJson();
    }
    return data;
  }
}

class Nodes {
  String? id;
  String? text;
  String? barcode;
  String? parent;
  String? archived;
  String? modified;
  String? added;

  Nodes(
      {this.id,
      this.text,
      this.barcode,
      this.parent,
      this.archived,
      this.modified,
      this.added});

  Nodes.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['id'];
    text = json['text'] ?? json['text'];
    barcode = json['barcode'] ?? json['barcode'];
    parent = json['parent'] ?? "0";
    archived = json['archived'] ?? json['archived'];
    modified = json['modified'] ?? json['modified'];
    added = json['added'] ?? json['added'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['text'] = text;
    data['barcode'] = barcode;
    data['parent'] = parent;
    data['archived'] = archived;
    data['modified'] = modified;
    data['added'] = added;
    return data;
  }
}
