Map<String, dynamic> normalizeTafsirJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);

  List mahawer = normalized['mahawer'] ?? [];
  for (var m in mahawer) {

    // Ensure sections list exists
    m['sections'] = m['sections'] ?? [];

    for (var s in m['sections']) {

      // Ensure subsections list exists
      s['subSections'] = s['subSections'] ?? [];

      for (var ss in s['subSections']) {

        // Ensure topics list exists
        ss['topics'] = ss['topics'] ?? [];

        // Ensure ayat is list<int>
        ss['ayat'] = (ss['ayat'] as List<dynamic>?)
                ?.map((e) => int.tryParse('$e') ?? e)
                .toList()
            ?? [];
      }

      // Ensure ayat is list<int>
      s['ayat'] = (s['ayat'] as List<dynamic>?)
              ?.map((e) => int.tryParse('$e') ?? e)
              .toList()
          ?? [];
    }

    // Ensure ayat is list<int>
    m['ayat'] = (m['ayat'] as List<dynamic>?)
            ?.map((e) => int.tryParse('$e') ?? e)
            .toList()
        ?? [];
  }

  normalized['mahawer'] = mahawer;
  return normalized;
}
