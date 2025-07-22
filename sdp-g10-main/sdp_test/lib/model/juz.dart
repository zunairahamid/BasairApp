class Juz {
  final int index;
  final int sura;
  final int aya;

  Juz({required this.index, required this.sura, required this.aya});

  factory Juz.fromJson(Map<String, dynamic> json) {
    return Juz(
      index: json['index'],
      sura: json['sura'],
      aya: json['aya'],
    );
  }

  @override
  String toString() {
    return "Juz index: $index, sura: $sura, aya: $aya";
  }
}
