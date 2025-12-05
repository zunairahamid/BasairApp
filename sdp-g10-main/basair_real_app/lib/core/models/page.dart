class Page {
  int index;
  int sura;
  int aya;

  Page({required this.index, required this.sura, required this.aya});

  factory Page.fromJson(Map<String, dynamic> map) {
    return Page(
      index: map['index'] as int? ?? 0,
      sura: map['sura'] as int? ?? 0,
      aya: map['aya'] as int? ?? 0,
    );
  }
}
