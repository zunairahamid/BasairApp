// services/tafsir_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../model/mahawer.dart';
import '../model/section.dart';

class TafsirService {
  dynamic _surahData;
  bool _isLoaded = false;

  Future<List<Mahawer>> loadMahawer(int surahId) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📚 TAFSIR SERVICE: LOADING MAHAWER');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 Request Parameters:');
    print('   • Surah ID: $surahId');
    print('   • Is loaded: $_isLoaded');
    print('   • Data available: ${_surahData != null}');
    
    // ONLY ALLOW SURAH 4 - return empty list for others
    if (surahId != 4) {
      print('⚠️  Surah $surahId not supported - returning empty list');
      print('   • Available surahs: [4] only');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return [];
    }
    
    print('✅ Surah 4 requested - proceeding with load');
    
    try {
      if (!_isLoaded) {
        print('🔄 Data not loaded yet - loading JSON...');
        await _loadMahawerJson();
      } else {
        print('✅ Data already loaded - reusing cached data');
      }
      
      if (_surahData != null) {
        print('📊 Processing surah data...');
        Map<String, dynamic> surahMap = Map<String, dynamic>.from(_surahData as Map);
        final result = _parseMahawerData(surahMap);
        
        print('✅ Mahawer parsing complete');
        print('   • Parsed mahawer count: ${result.length}');
        if (result.isNotEmpty) {
          print('   • Sample mahawer titles:');
          for (int i = 0; i < min(3, result.length); i++) {
            print('     [${i + 1}] ${result[i].title}');
          }
        }
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        return result;
      } else {
        print('❌ No surah data available after load attempt');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        return []; // Return empty instead of throwing
      }
    } catch (e) {
      print('❌ ERROR LOADING MAHAWER FROM JSON:');
      print('   • Error type: ${e.runtimeType}');
      print('   • Error message: $e');
      print('   • Stack trace: ${e.toString()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return []; // Return empty instead of throwing
    }
  }

  Future<void> _loadMahawerJson() async {
    print('🔄 LOADING JSON DATA');
    print('─────────────────────────────────────────────────────────────────────────');
    try {
      print('📁 Loading asset: assets/data/mahawer04.json...');
      
      final jsonString = await rootBundle.loadString('assets/data/mahawer04.json');
      print('✅ JSON string loaded');
      print('   • String length: ${jsonString.length} characters');
      
      _surahData = json.decode(jsonString);
      _isLoaded = true;
      
      print('✅ JSON decoding successful');
      print('   • Data type: ${_surahData.runtimeType}');
      
      if (_surahData is Map) {
        final surahMap = Map<String, dynamic>.from(_surahData as Map);
        print('   • Keys in data: ${surahMap.keys.join(', ')}');
        if (surahMap['mahawer'] is List) {
          print('   • Mahawer sections: ${(surahMap['mahawer'] as List).length}');
        }
        if (surahMap['surahName'] != null) {
          print('   • Surah name: ${surahMap['surahName']}');
        }
        if (surahMap['author'] != null) {
          print('   • Author: ${surahMap['author']}');
        }
      }
      
      print('✅ SUCCESS: Loaded JSON data for Surah 4');
      
    } catch (e) {
      print('❌ FAILED TO LOAD JSON:');
      print('   • Error type: ${e.runtimeType}');
      print('   • Error message: $e');
      _surahData = null;
      _isLoaded = false;
    }
    print('─────────────────────────────────────────────────────────────────────────\n');
  }

  List<Mahawer> _parseMahawerData(Map<String, dynamic> surahData) {
    print('📊 PARSING MAHAWER DATA');
    print('─────────────────────────────────────────────────────────────────────────');
    final mahawerList = <Mahawer>[];

    if (surahData['mahawer'] != null && surahData['mahawer'] is List) {
      final mahawerSections = surahData['mahawer'] as List;
      
      print('✅ Found ${mahawerSections.length} mahawer sections in JSON');
      
      for (int i = 0; i < mahawerSections.length; i++) {
        final dynamic mahawerData = mahawerSections[i];
        
        try {
          if (mahawerData is Map) {
            final Map<String, dynamic> mahawerMap = Map<String, dynamic>.from(mahawerData);
            final startAya = _getIntValue(mahawerMap['startAya']) ?? 1;
            final endAya = _getIntValue(mahawerMap['endAya']) ?? 1;
            
            final mahawer = Mahawer(
              id: mahawerMap['id']?.toString() ?? 'mahawer_${i + 1}',
              type: mahawerMap['type']?.toString() ?? 'محور',
              sequence: mahawerMap['sequence']?.toString() ?? '',
              title: mahawerMap['title']?.toString() ?? '',
              text: mahawerMap['text']?.toString() ?? '',
              ayat: [startAya, endAya],
              sections: _parseSections(mahawerMap['sections']),
              isMuqadimah: mahawerMap['isMuqadimah'] ?? false,
              isKhatimah: mahawerMap['isKhatimah'] ?? false,
              startAya: startAya,
              endAya: endAya,
            );
            
            mahawerList.add(mahawer);
            
            if (i < 3) { // Log first 3 mahawer for debugging
              print('   [${i + 1}] Parsed mahawer: ${mahawer.title}');
              print('       • Type: ${mahawer.type}');
              print('       • Ayat: ${mahawer.startAya}-${mahawer.endAya}');
              print('       • Sections: ${mahawer.sections.length}');
            }
          } else {
            print('   ⚠️  Mahawer at index $i is not a Map: ${mahawerData.runtimeType}');
          }
        } catch (e) {
          print('❌ Error parsing mahawer at index $i: $e');
        }
      }
      
      print('✅ Successfully parsed ${mahawerList.length} mahawer sections');
    } else {
      print('⚠️  No mahawer array found in data');
    }

    print('─────────────────────────────────────────────────────────────────────────');
    return mahawerList;
  }

  List<Section> _parseSections(dynamic sectionsData) {
    if (sectionsData == null || sectionsData is! List) {
      print('   ⚠️  No sections data or invalid format');
      return [];
    }
    
    print('   📊 Parsing ${sectionsData.length} sections...');
    final sections = <Section>[];
    
    for (int i = 0; i < sectionsData.length; i++) {
      final dynamic sectionData = sectionsData[i];
      
      try {
        if (sectionData is Map) {
          final Map<String, dynamic> sectionMap = Map<String, dynamic>.from(sectionData);
          final ayat = _parseAyatFromSection(sectionMap);
          
          final section = Section(
            id: sectionMap['id']?.toString() ?? 'section_${i + 1}',
            type: sectionMap['type']?.toString() ?? '',
            sequence: sectionMap['sequence']?.toString() ?? '',
            title: sectionMap['title']?.toString() ?? '',
            text: sectionMap['text']?.toString() ?? '',
            ayat: ayat,
            conclusion: sectionMap['conclusion']?.toString(),
            subSections: _parseSubSections(sectionMap['subSections']),
            cases: sectionMap['cases'] as List<dynamic>?,
          );
          
          sections.add(section);
        }
      } catch (e) {
        print('   ❌ Error parsing section at index $i: $e');
      }
    }
    
    print('   ✅ Parsed ${sections.length} sections');
    return sections;
  }

  List<Section>? _parseSubSections(dynamic subSectionsData) {
    if (subSectionsData == null || subSectionsData is! List) {
      return null;
    }
    
    print('     📊 Parsing ${subSectionsData.length} sub-sections...');
    final subSections = <Section>[];
    
    for (int i = 0; i < subSectionsData.length; i++) {
      final dynamic subSectionData = subSectionsData[i];
      
      try {
        if (subSectionData is Map) {
          final Map<String, dynamic> subSectionMap = Map<String, dynamic>.from(subSectionData);
          final ayat = _parseAyatFromSection(subSectionMap);
          
          final subSection = Section(
            id: subSectionMap['id']?.toString() ?? 'subsection_${i + 1}',
            type: subSectionMap['type']?.toString() ?? '',
            sequence: subSectionMap['sequence']?.toString() ?? '',
            title: subSectionMap['title']?.toString() ?? '',
            text: subSectionMap['text']?.toString() ?? '',
            ayat: ayat,
            conclusion: subSectionMap['conclusion']?.toString(),
            subSections: _parseSubSections(subSectionMap['subSections']),
            cases: subSectionMap['cases'] as List<dynamic>?,
          );
          
          subSections.add(subSection);
        }
      } catch (e) {
        print('     ❌ Error parsing sub-section at index $i: $e');
      }
    }
    
    print('     ✅ Parsed ${subSections.length} sub-sections');
    return subSections.isNotEmpty ? subSections : null;
  }

  List<int> _parseAyatFromSection(Map<String, dynamic> sectionData) {
    if (sectionData['ayat'] != null && sectionData['ayat'] is List) {
      final ayatList = (sectionData['ayat'] as List).map((e) => _getIntValue(e) ?? 1).toList();
      if (ayatList.isNotEmpty) {
        return ayatList;
      }
    }
    
    final startAya = _getIntValue(sectionData['startAya']);
    final endAya = _getIntValue(sectionData['endAya']);
    if (startAya != null && endAya != null) {
      return [startAya, endAya];
    }
    
    return [1, 1];
  }

  int? _getIntValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value.trim());
      } catch (e) {
        return null;
      }
    }
    if (value is double) return value.toInt();
    
    try {
      return int.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getSurahData(int surahId) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📄 TAFSIR SERVICE: GET SURAH DATA');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 Request: Surah ID $surahId');
    
    // ALWAYS return data for Surah 4
    if (surahId != 4) {
      print('⚠️  Surah $surahId not available - returning unavailable message');
      final result = {
        'surahID': surahId,
        'surahName': 'سورة $surahId',
        'author': 'التفسير غير متوفر',
        'mahawer': []
      };
      print('✅ Returning: ${result['surahName']} - ${result['author']}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return result;
    }
    
    if (!_isLoaded) {
      print('🔄 Data not loaded - loading JSON first');
      await _loadMahawerJson();
    } else {
      print('✅ Data already loaded');
    }
    
    if (_surahData is Map) {
      final result = Map<String, dynamic>.from(_surahData as Map);
      print('✅ Returning surah data from loaded JSON');
      print('   • Surah name: ${result['surahName']}');
      print('   • Author: ${result['author']}');
      print('   • Mahawer count: ${result['mahawer'] is List ? (result['mahawer'] as List).length : "N/A"}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return result;
    }
    
    print('⚠️  No data available - returning default structure');
    final result = {
      'surahID': surahId,
      'surahName': 'سورة النساء',
      'author': 'التفسير الموضوعي',
      'mahawer': []
    };
    print('✅ Returning default: ${result['surahName']} - ${result['author']}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    return result;
  }

  Future<Map<String, dynamic>> getSurahInfo(int surahId) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📄 TAFSIR SERVICE: GET SURAH INFO');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 Request: Surah ID $surahId');
    
    // ALWAYS return info for Surah 4
    if (surahId != 4) {
      print('⚠️  Surah $surahId not available - returning unavailable info');
      final result = {
        'surahID': surahId,
        'surahName': 'سورة $surahId',
        'author': 'التفسير غير متوفر',
      };
      print('✅ Returning: ${result['surahName']} - ${result['author']}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return result;
    }
    
    if (!_isLoaded) {
      print('🔄 Data not loaded - loading JSON first');
      await _loadMahawerJson();
    } else {
      print('✅ Data already loaded');
    }
    
    if (_surahData is Map) {
      final surahMap = Map<String, dynamic>.from(_surahData as Map);
      final result = {
        'surahID': surahMap['surahID'],
        'surahName': surahMap['surahName'],
        'author': surahMap['author'],
      };
      print('✅ Returning surah info from loaded JSON');
      print('   • Surah name: ${result['surahName']}');
      print('   • Author: ${result['author']}');
      print('   • Surah ID: ${result['surahID']}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return result;
    }
    
    print('⚠️  No data available - returning default info');
    final result = {
      'surahID': surahId,
      'surahName': 'سورة النساء',
      'author': 'التفسير الموضوعي',
    };
    print('✅ Returning default: ${result['surahName']} - ${result['author']}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    return result;
  }

  Future<bool> hasTafsirData(int surahId) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📄 TAFSIR SERVICE: CHECK TAFSIR DATA AVAILABILITY');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 Request: Does Surah $surahId have tafsir data?');
    
    final hasData = surahId == 4; // ONLY Surah 4 has data
    print('✅ Response: $hasData (only Surah 4 has data)');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    return hasData;
  }

  String getSurahName(int surahId) {
    print('📄 TAFSIR SERVICE: GET SURAH NAME');
    print('   • Request: Surah ID $surahId');
    
    if (surahId == 4 && _surahData is Map) {
      final surahMap = Map<String, dynamic>.from(_surahData as Map);
      final name = surahMap['surahName'] ?? 'سورة النساء';
      print('   • Response from JSON: $name');
      return name;
    }
    final name = 'سورة $surahId';
    print('   • Response default: $name');
    return name;
  }

  List<int> getAvailableSurahIds() {
    print('📄 TAFSIR SERVICE: GET AVAILABLE SURAH IDS');
    final ids = [4]; // ONLY surah 4 has data
    print('   • Available surahs: $ids');
    return ids;
  }

  Map? getPublicationInfo() {
    print('📄 TAFSIR SERVICE: GET PUBLICATION INFO');
    
    if (_surahData is Map) {
      final surahMap = Map<String, dynamic>.from(_surahData as Map);
      final pubInfo = surahMap['publication'];
      
      if (pubInfo is Map) {
        print('   • Publication info found');
        print('   • Keys: ${pubInfo.keys.join(', ')}');
        return pubInfo;
      } else {
        print('   • No publication info in JSON');
        return null;
      }
    }
    
    print('   • No surah data loaded');
    return null;
  }

  String? getAuthor() {
    print('📄 TAFSIR SERVICE: GET AUTHOR');
    
    if (_surahData is Map) {
      final surahMap = Map<String, dynamic>.from(_surahData as Map);
      final author = surahMap['author'];
      print('   • Author from JSON: $author');
      return author;
    }
    
    print('   • No surah data loaded');
    return null;
  }

  Future<void> ensureDataLoaded() async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📄 TAFSIR SERVICE: ENSURE DATA LOADED');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 Current status:');
    print('   • Is loaded: $_isLoaded');
    print('   • Data available: ${_surahData != null}');
    
    if (!_isLoaded) {
      print('🔄 Data not loaded - loading JSON...');
      await _loadMahawerJson();
    } else {
      print('✅ Data already loaded - nothing to do');
    }
    
    print('📋 Final status:');
    print('   • Is loaded: $_isLoaded');
    print('   • Data available: ${_surahData != null}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }
}

// Helper function
int min(int a, int b) => a < b ? a : b;