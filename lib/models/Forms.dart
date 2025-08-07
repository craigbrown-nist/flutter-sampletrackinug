class FormsOfSample {
  String? id;
  String? name;
  String? archived;

  FormsOfSample({required this.id, required this.name, required this.archived});

  FormsOfSample.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    archived = json['archived'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['archived'] = archived;
    return data;
  }
}
