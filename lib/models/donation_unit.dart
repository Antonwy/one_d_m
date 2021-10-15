class DonationUnit {
  final String? smiley;
  final String name, effect, singular;
  final int value;

  const DonationUnit(
      {this.name = "DVs",
      this.smiley,
      this.effect = "gespendet",
      this.singular = "DV",
      this.value = 1});

  String get smileyOrName => smiley ?? name;

  static const DonationUnit defaultUnit =
      DonationUnit(name: "DVs", effect: "gespendet", singular: "DV", value: 1);

  factory DonationUnit.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('unit')) return defaultUnit;

    return DonationUnit(
      name: map['unit'],
      smiley: map['unit_smiley'],
      effect: map['unit_effect'],
      singular: map['unit_singular'],
      value: map['unit_value'],
    );
  }
}
