class Pages {
  final int index;
  final int sura;
  final int aya;

  Pages({required this.index, required this.sura, required this.aya});

  factory Pages.fromJson(Map<String, dynamic> json) {
    return Pages(
      index: json['index'],
      sura: json['sura'],
      aya: json['aya'],
    );
  }

  @override
  String toString() {
    return "Page Index: $index, sura: $sura, aya: $aya";
  }
}
