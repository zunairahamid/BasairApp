class Juz {
  final int index;
  final int sura;
  final int aya;
  final int page;

  Juz({
    required this.index,
    required this.sura,
    required this.aya,
    required this.page,
  });

  factory Juz.fromJson(Map<String, dynamic> json) {
    return Juz(
      index: json['index'],
      sura: json['sura'],
      aya: json['aya'],
      page: json['page'],
    );
  }

  @override
  String toString() {
    return "Juz index: $index, sura: $sura, aya: $aya, page: $page";
  }
}
