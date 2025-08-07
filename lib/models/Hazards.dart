class Hazards {
  String? id;
  String? name;
  String? category;
  String? icon;
  String? tooltip;
  String? archived;
  String? modified;
  List<IconData>? iconData;

  Hazards(
      {this.id,
      this.name,
      this.category,
      this.icon,
      this.tooltip,
      this.archived,
      this.modified,
      this.iconData});

  Hazards.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    category = json['category'];
    icon = json['icon'];
    tooltip = json['tooltip'];
    archived = json['archived'];
    modified = json['modified'];
    if (json['iconData'] != null) {
      iconData = List<IconData>.empty(growable: true);
      json['iconData'].forEach((v) {
        iconData!.add(IconData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['category'] = category;
    data['icon'] = icon;
    data['tooltip'] = tooltip;
    data['archived'] = archived;
    data['modified'] = modified;
    if (iconData != null) {
      data['iconData'] = iconData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class IconData {
  String? id;
  String? number;
  String? tooltip;
  String? modified;
  String? small;
  String? medium;
  String? large;

  IconData(
      {this.id,
      this.number,
      this.tooltip,
      this.modified,
      this.small,
      this.medium,
      this.large});

  IconData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    tooltip = json['tooltip'];
    modified = json['modified'];
    small = json['small'];
    medium = json['medium'];
    large = json['large'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['number'] = number;
    data['tooltip'] = tooltip;
    data['modified'] = modified;
    data['small'] = small;
    data['medium'] = medium;
    data['large'] = large;
    return data;
  }
}
