class Quarters {
  final int index;
  final int sura;
  final int aya;

  Quarters({required this.index, required this.sura, required this.aya});

  factory Quarters.fromJson(Map<String, dynamic> json) {
    return Quarters(
      index: json['index'],
      sura: json['sura'],
      aya: json['aya'],
    );
  }

  @override
  String toString() {
    return "Quarter index: $index, sura: $sura, aya: $aya";
  }
}
