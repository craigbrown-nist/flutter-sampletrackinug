class User {
  String? id;
  String? barcode;
  String? email;
  String? address;
  String? phone;
  String? name;
  String? manager;
  String? archived;
  String? modified;
  String? added;
  bool? selected = false;

  String? get fullname {
    return name;
  }

  String? get managertype {
    return manager;
  }

  User({
    this.id,
    this.barcode,
    this.email,
    this.address,
    this.phone,
    this.name,
    this.manager,
    this.archived,
    this.modified,
    this.added,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    barcode = json['barcode'];
    email = json['email'];
    address = json['address'];
    phone = json['phone'];
    name = json['name'];
    manager = json['manager'];
    archived = json['archived'];
    modified = json['modified'];
    added = json['added'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['barcode'] = barcode;
    data['email'] = email;
    data['address'] = address;
    data['phone'] = phone;
    data['name'] = name;
    data['manager'] = manager;
    data['archived'] = archived;
    data['modified'] = modified;
    data['added'] = added;
    return data;
  }
}
