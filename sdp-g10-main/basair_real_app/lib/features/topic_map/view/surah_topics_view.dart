import 'dart:convert';
import 'dart:math';
import 'package:basair_real_app/core/models/page.dart';
import 'package:basair_real_app/core/models/resource_link.dart';
import 'package:basair_real_app/core/models/verse.dart';
import 'package:basair_real_app/core/providers/verses_provider.dart';
import 'package:basair_real_app/features/quran_viewer/view/screens/quran_viewer_screen.dart';
import 'package:basair_real_app/features/resource_viewer/view/image_viewer_screen.dart';
import 'package:basair_real_app/features/resource_viewer/view/pdf_viewer_screen.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class SurahTopicsView extends ConsumerStatefulWidget {
  final int surahId;

  const SurahTopicsView({required this.surahId, super.key});

  @override
  ConsumerState<SurahTopicsView> createState() => _SurahTopicsViewState();
}

class _SurahTopicsViewState extends ConsumerState<SurahTopicsView> {
  List<dynamic> mahawer = [];
  bool isLoading = true;

  // Colors
  final Map<String, Color> topicColors = {};
  final Map<String, Color> subTopicColors = {};
  final Set<Color> usedTopicColors = {};
  final Set<Color> usedSubTopicColors = {};

  final Map<String, bool> showSubsections = {};
  final Map<String, bool> showCases = {};

  final Map<String, List<ResourceLink>> _resourcesByNodeId = {};

  @override
  void initState() {
    super.initState();
    _loadMahawer();
  }

  Future<void> _loadMahawer() async {
    final fileName =
        'assets/data/mahawer${widget.surahId.toString().padLeft(2, '0')}.json';

    try {
      final data = await rootBundle.loadString(fileName);
      final jsonResult = json.decode(data);
      mahawer = jsonResult['mahawer'] ?? [];

      Color generateUniqueColor(Set<Color> usedColors) {
        final random = Random();
        Color color;
        int tries = 0;
        do {
          color = Color.fromARGB(
            255,
            random.nextInt(151),
            random.nextInt(151),
            random.nextInt(151),
          );
          if (color == Colors.purple[700] || color == Colors.orange[700]) {
            continue;
          }
          tries++;
        } while (usedColors.contains(color) && tries < 100);
        usedColors.add(color);
        return color;
      }

      for (var topic in mahawer) {
        topicColors['${topic['id']}'] = generateUniqueColor(usedTopicColors);
        for (var section in (topic['sections'] ?? [])) {
          subTopicColors['${section['id']}'] =
              generateUniqueColor(usedSubTopicColors);
        }
      }

      try {
        final pad2 = widget.surahId.toString().padLeft(2, '0');
        final linksFile =
            'assets/data/resources/youtubelinks/youtube_links$pad2.json';

        final linksData = await rootBundle.loadString(linksFile);
        final jsonLinks = json.decode(linksData);
        final linksList = (jsonLinks['links'] as List<dynamic>? ?? [])
            .map((l) => ResourceLink.fromJson(l as Map<String, dynamic>))
            .toList();

        _resourcesByNodeId.clear();
        for (final link in linksList) {
          _resourcesByNodeId.putIfAbsent(link.nodeId, () => []).add(link);
        }
      } catch (e) {
        _resourcesByNodeId.clear();
        debugPrint("No YouTube resources for this surah yet: $e");
      }
    } catch (e) {
      debugPrint('Error loading Mahawer for Surah ${widget.surahId}: $e');
      mahawer = [];
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
    try {
      final pad2 = widget.surahId.toString().padLeft(2, '0'); // 2 digits
      final pdfLinksFile = 'assets/data/resources/pdfs/pdf_links$pad2.json';

      final pdfData = await rootBundle.loadString(pdfLinksFile);
      final jsonPdf = json.decode(pdfData);
      final pdfList = (jsonPdf['links'] as List<dynamic>? ?? [])
          .map((l) => ResourceLink.fromJson(l as Map<String, dynamic>))
          .toList();

      for (final link in pdfList) {
        _resourcesByNodeId.putIfAbsent(link.nodeId, () => []).add(link);
      }
    } catch (e) {
      debugPrint("No PDF resources for this surah yet: $e");
    }
    try {
      final pad2 = widget.surahId.toString().padLeft(2, '0');
      final imgLinksFile = 'assets/data/resources/images/image_links$pad2.json';

      final imgData = await rootBundle.loadString(imgLinksFile);
      final jsonImg = json.decode(imgData);
      final imgList = (jsonImg['links'] as List<dynamic>? ?? [])
          .map((l) => ResourceLink.fromJson(l as Map<String, dynamic>))
          .toList();

      for (final link in imgList) {
        _resourcesByNodeId.putIfAbsent(link.nodeId, () => []).add(link);
      }
    } catch (e) {
      debugPrint("No IMAGE resources for this surah yet: $e");
    }
  }

  String? _extractYouTubeId(String url) {
    final uri = Uri.parse(url);
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.queryParameters['v'] != null) return uri.queryParameters['v'];
    final segs = uri.pathSegments;
    if (segs.length >= 2 && (segs[0] == 'embed' || segs[0] == 'shorts')) {
      return segs[1];
    }
    return null;
  }
  void _openPdfAsset(String assetPath, {String title = 'PDF', int? page}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          assetPath: assetPath,
          title: title,
          initialPage: page ?? 1,
        ),
      ),
    );
  }

  void _openImageAsset(String assetPath, {String? title}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageViewerScreen(assetPath: assetPath, title: title),
      ),
    );
  }

  String getVerseEndSymbol(int verseId) => '۝';

  List<int> _getSubtopicAyahs(dynamic node) {
    final List<int> ayahs = [];
    if (node == null) return ayahs;

    if (node['ayat'] != null && node['ayat'] is List) {
      ayahs.addAll(List<int>.from(node['ayat']));
    }
    if (node['subSections'] != null && node['subSections'] is List) {
      for (var sub in node['subSections']) {
        ayahs.addAll(_getSubtopicAyahs(sub));
      }
    }
    if (node['cases'] != null && node['cases'] is List) {
      for (var c in node['cases']) {
        ayahs.addAll(_getSubtopicAyahs(c));
      }
    }
    return ayahs.toSet().toList();
  }

  List<ResourceLink> _getLinksForNode(Map<String, dynamic> node) {
    final id = node['id']?.toString() ?? '';
    return _resourcesByNodeId[id] ?? const [];
  }

  List<ResourceLink> _getVideoLinks(Map<String, dynamic> node) {
    return _getLinksForNode(node).where((l) => l.kind == 'video').toList();
  }

  List<ResourceLink> _getPdfLinks(Map<String, dynamic> node) {
    return _getLinksForNode(node).where((l) => l.kind == 'pdf').toList();
  }

  List<ResourceLink> _getImageLinks(Map<String, dynamic> node) {
    return _getLinksForNode(node).where((l) => l.kind == 'image').toList();
  }

  List<ResourceLink> _getWebsiteLinks(Map<String, dynamic> node) {
    return _getLinksForNode(node)
        .where((l) => l.kind == 'website' && (l.url.trim().isNotEmpty))
        .toList();
  }

  Future<void> _launchUrl(String url, {int? start}) async {
    Uri uri = Uri.parse(url);
    if (start != null && start > 0 && uri.host.contains('youtu')) {
      final qp = Map<String, String>.from(uri.queryParameters);
      qp.putIfAbsent('t', () => '${start}s');
      uri = uri.replace(queryParameters: qp);
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  void _openSubtopicInQuranViewer(List<int> ayahNumbers) {
    if (ayahNumbers.isEmpty) return;

    final versesState = ref.read(versesNotifierProvider);
    final List<Page> pages = versesState.pages;
    final int targetSurah = widget.surahId;
    final int firstAyah = ayahNumbers.reduce(min);

    int? targetPage;
    for (final p in pages) {
      final bool startsBeforeOrAtTarget = (p.sura < targetSurah) ||
          (p.sura == targetSurah && p.aya <= firstAyah);

      if (startsBeforeOrAtTarget) {
        targetPage = p.index;
      } else if (targetPage != null) {
        break;
      }
    }
    if (targetPage == null) {
      for (final p in pages) {
        if (p.sura == targetSurah) {
          targetPage = p.index;
          break;
        }
      }
    }
    targetPage ??= 1;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranViewerScreen(pageNumber: targetPage!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final versesNotifier = ref.read(versesNotifierProvider.notifier);
    final List<Verse> allVerses =
        versesNotifier.getAllSurahVerses(widget.surahId);
    final surahName = versesNotifier.getSurahNameById(widget.surahId);

    if (allVerses.isEmpty) {
      versesNotifier.loadVersesForSurah(widget.surahId).then((_) {
        if (mounted) setState(() {});
      });
      return Scaffold(
        backgroundColor: Colors.indigo[50],
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
            decoration: BoxDecoration(
              color: Colors.indigo[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Text(
                '... جارٍ تحميل الآيات',
                style: TextStyle(
                  fontFamily: 'Hafs',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (mahawer.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.indigo[50],
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
            decoration: BoxDecoration(
              color: Colors.indigo[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                surahName ?? 'Surah ${widget.surahId}',
                style: const TextStyle(
                  fontFamily: 'Hafs',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'No Topics Map Available For This Surah',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final orientation = MediaQuery.of(context).orientation;
    final bool showAyahs = orientation == Orientation.landscape;

    // Landscape: show topics map
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
          decoration: BoxDecoration(
            color: Colors.indigo[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              surahName ?? 'Surah ${widget.surahId}',
              style: const TextStyle(
                fontFamily: 'Hafs',
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: mahawer.length,
        itemBuilder: (context, index) {
          final topic = mahawer[index];
          final topicColor = topicColors['${topic['id']}'] ?? Colors.black;
          final subtopics =
              (topic['sections'] ?? []).cast<Map<String, dynamic>>();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'محوَر (${topic['id'] ?? '—'}) / ${topic['title'] ?? '-'}',
                  style: TextStyle(
                    fontFamily: 'Hafs',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: topicColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 5),
              ...subtopics.map((subtopic) {
                final subTopicColor =
                    subTopicColors['${subtopic['id']}'] ?? Colors.black;

                final ayahNumbers = _getSubtopicAyahs(subtopic);
                final subtopicAyahs = ayahNumbers
                    .map((ayahNum) => allVerses.firstWhere(
                          (v) => v.id == ayahNum,
                          orElse: () => Verse(id: 0, text: ''),
                        ))
                    .where((v) => v.id != 0)
                    .toList();

                final videoLinks = _getVideoLinks(subtopic);
                final pdfLinks = _getPdfLinks(subtopic);
                final imageLinks = _getImageLinks(subtopic);
                final websiteLinks = _getWebsiteLinks(subtopic);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: () {
                    final leftCell = Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          InkWell(
                            key: ValueKey('subtopicHeader_${subtopic['id']}'),
                            onTap: () {
                              _openSubtopicInQuranViewer(ayahNumbers);
                            },
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Hafs',
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: subTopicColor,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: '${subtopic['type'] ?? '-'} '),
                                    TextSpan(
                                      text: '(${subtopic['id'] ?? '-'})',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: subTopicColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),
                          Text(
                            subtopic['text'] ??
                                'لا يوجد شرح لهذا المحوَر الفرعي',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'Hafs',
                              fontSize: 25,
                              color: subTopicColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 10),

                          // Resource buttons row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (pdfLinks.isNotEmpty)
                                IconButton(
                                  icon:
                                      const Icon(Icons.picture_as_pdf_outlined),
                                  color: Colors.red,
                                  iconSize: 30,
                                  onPressed: () {
                                    if (pdfLinks.length == 1) {
                                      final p = pdfLinks.first;
                                      _openPdfAsset(
                                        p.url,
                                        title: p.label ??
                                            (subtopic['text'] ?? 'PDF'),
                                        page: p.page,
                                      );
                                    } else {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (_) => ListView(
                                          children: pdfLinks
                                              .map((p) => ListTile(
                                                    title: Text(
                                                      p.label ?? p.url,
                                                      textDirection:
                                                          TextDirection.rtl,
                                                    ),
                                                    onTap: () => _openPdfAsset(
                                                      p.url,
                                                      title: p.label ?? 'PDF',
                                                      page: p.page,
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              if (websiteLinks.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.wordpress_outlined),
                                  color: Colors.blue,
                                  iconSize: 30,
                                  onPressed: () {
                                    final link = websiteLinks.first;
                                    if (link.url.isNotEmpty)
                                      _launchUrl(link.url);
                                  },
                                ),
                              if (videoLinks.isNotEmpty)
                                IconButton(
                                  icon: const Icon(
                                      Icons.play_circle_fill_outlined),
                                  color: Colors.pink,
                                  iconSize: 30,
                                  onPressed: () {
                                    if (videoLinks.length == 1) {
                                      final v = videoLinks.first;
                                      _launchUrl(v.url, start: v.start);
                                    } else {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (_) => ListView(
                                          children: videoLinks
                                              .map((v) => ListTile(
                                                    leading: const Icon(
                                                      Icons
                                                          .play_circle_filled_rounded,
                                                      color: Colors.redAccent,
                                                    ),
                                                    title: Text(
                                                      v.label ?? v.url,
                                                      textDirection:
                                                          TextDirection.rtl,
                                                    ),
                                                    onTap: () => _launchUrl(
                                                        v.url,
                                                        start: v.start),
                                                  ))
                                              .toList(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              if (imageLinks.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.image_outlined),
                                  color: Colors.green,
                                  iconSize: 30,
                                  onPressed: () {
                                    if (imageLinks.length == 1) {
                                      final img = imageLinks.first;
                                      _openImageAsset(
                                        img.url,
                                        title: img.label ??
                                            (subtopic['text'] ?? ''),
                                      );
                                    } else {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (_) => ListView(
                                          children: imageLinks
                                              .map((img) => ListTile(
                                                    leading: const Icon(
                                                        Icons.image_outlined),
                                                    title: Text(
                                                      img.label ?? img.url,
                                                      textDirection:
                                                          TextDirection.rtl,
                                                    ),
                                                    onTap: () =>
                                                        _openImageAsset(
                                                      img.url,
                                                      title: img.label,
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          if ((subtopic['subSections'] ?? []).isNotEmpty)
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    final key =
                                        subtopic['id']?.toString() ?? '';
                                    showSubsections[key] =
                                        !(showSubsections[key] ?? false);
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: showSubsections[
                                              subtopic['id']?.toString() ??
                                                  ''] ==
                                          true
                                      ? Colors.indigo[200]
                                      : Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Text(
                                  showSubsections[subtopic['id']?.toString() ??
                                              ''] ==
                                          true
                                      ? 'Hide Subsections'
                                      : 'Show Subsections',
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 15,
                                    letterSpacing: 1.5,
                                    color: showSubsections[
                                                subtopic['id']?.toString() ??
                                                    ''] ==
                                            true
                                        ? Colors.black
                                        : Colors.indigo[200],
                                  ),
                                ),
                              ),
                            ),
                          if (showSubsections[
                                  subtopic['id']?.toString() ?? ''] ==
                              true)
                            ..._buildSubsectionsTable(subtopic, allVerses),
                        ],
                      ),
                    );

                    // RIGHT side – ayahs column
                    final rightCell = Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: subtopicAyahs.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children:
                                  List.generate(subtopicAyahs.length, (i) {
                                final v = subtopicAyahs[i];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${v.text} ${getVerseEndSymbol(v.id)}',
                                      style: TextStyle(
                                        fontFamily: 'Hafs',
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: topicColor,
                                        height: 2.5,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    if (i < subtopicAyahs.length - 1)
                                      const Divider(height: 10),
                                  ],
                                );
                              }),
                            )
                          : const Text(
                              'No Ayahs for this Subtopic',
                              style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                color: Colors.black,
                              ),
                            ),
                    );

                    // Decide layout by showAyahs
                    if (showAyahs) {
                      // LANDSCAPE – two-column table (topics + ayahs)
                      return Table(
                        key: ValueKey('landscape_two_column'),
                        border: TableBorder.all(
                          color: Colors.black,
                          width: 2.5,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        children: [
                          TableRow(
                            children: [
                              leftCell,
                              rightCell,
                            ],
                          ),
                        ],
                      );
                    } else {
                      // PORTRAIT – only topics map, no ayahs
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: leftCell,
                      );
                    }
                  }(),
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildSubsectionsTable(
      Map<String, dynamic> node, List<Verse> allVerses) {
    final subSections =
        (node['subSections'] ?? []).cast<Map<String, dynamic>>();
    if (subSections.isEmpty) return [];

    return subSections
        .map((oneSubSection) {
          final ayahNumbers = _getSubtopicAyahs(oneSubSection);
          final subAyahs = ayahNumbers
              .map((ayahNum) => allVerses.firstWhere(
                    (v) => v.id == ayahNum,
                    orElse: () => Verse(id: 0, text: ''),
                  ))
              .where((v) => v.id != 0)
              .toList();

          final videoLinks = _getVideoLinks(oneSubSection);

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Table(
              border: TableBorder.all(
                color: const Color.fromRGBO(123, 31, 162, 1),
                width: 2.5,
                borderRadius: BorderRadius.circular(10),
              ),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${oneSubSection['type'] ?? '-'} (${oneSubSection['id'] ?? '-'})',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: 'Hafs',
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(123, 31, 162, 1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            oneSubSection['text'] ?? '—',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: 'Hafs',
                              fontSize: 20,
                              color: Color.fromRGBO(123, 31, 162, 1),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Cases toggle
                          if ((oneSubSection['cases'] ?? []).isNotEmpty)
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    final key =
                                        oneSubSection['id']?.toString() ?? '';
                                    showCases[key] = !(showCases[key] ?? false);
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: showCases[
                                              oneSubSection['id']?.toString() ??
                                                  ''] ==
                                          true
                                      ? Colors.indigo[200]
                                      : Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                child: Text(
                                  (showCases[oneSubSection['id']?.toString() ??
                                              ''] ==
                                          true)
                                      ? 'Hide Cases'
                                      : 'Show Cases',
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 15,
                                    letterSpacing: 1.5,
                                    color: (showCases[oneSubSection['id']
                                                    ?.toString() ??
                                                ''] ==
                                            true)
                                        ? Colors.black
                                        : Colors.indigo[200],
                                  ),
                                ),
                              ),
                            ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.play_circle_fill_outlined),
                                color: const Color.fromRGBO(123, 31, 162, 1),
                                onPressed: videoLinks.isEmpty
                                    ? null
                                    : () {
                                        if (videoLinks.length == 1) {
                                          final v = videoLinks.first;
                                          _launchUrl(v.url, start: v.start);
                                        } else {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (_) => ListView(
                                              children: videoLinks
                                                  .map((v) => ListTile(
                                                        title: Text(
                                                          v.label ?? v.url,
                                                          textDirection:
                                                              TextDirection.rtl,
                                                        ),
                                                        onTap: () =>
                                                            _launchUrl(
                                                                v.url,
                                                                start: v.start),
                                                      ))
                                                  .toList(),
                                            ),
                                          );
                                        }
                                      },
                              ),
                            ],
                          ),

                          if (showCases[
                                  oneSubSection['id']?.toString() ?? ''] ==
                              true)
                            ..._buildCasesTable(oneSubSection['cases']),

                          if ((oneSubSection['subSections'] ?? []).isNotEmpty)
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    final key =
                                        oneSubSection['id']?.toString() ?? '';
                                    showSubsections[key] =
                                        !(showSubsections[key] ?? false);
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: showSubsections[
                                              oneSubSection['id']?.toString() ??
                                                  ''] ==
                                          true
                                      ? Colors.indigo[200]
                                      : Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                child: Text(
                                  (showSubsections[
                                              oneSubSection['id']?.toString() ??
                                                  ''] ==
                                          true)
                                      ? 'Hide Subsections'
                                      : 'Show Subsections',
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 15,
                                    color: (showSubsections[oneSubSection['id']
                                                    ?.toString() ??
                                                ''] ==
                                            true)
                                        ? Colors.black
                                        : Colors.indigo[200],
                                  ),
                                ),
                              ),
                            ),
                          if (showSubsections[
                                  oneSubSection['id']?.toString() ?? ''] ==
                              true)
                            ..._buildSubsectionsTable(oneSubSection, allVerses),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: subAyahs.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: List.generate(subAyahs.length, (i) {
                                final v = subAyahs[i];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${v.text} ${getVerseEndSymbol(v.id)}',
                                      style: const TextStyle(
                                        fontFamily: 'Hafs',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        height: 2,
                                        color: Color.fromRGBO(123, 31, 162, 1),
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    if (i < subAyahs.length - 1)
                                      const Divider(height: 10),
                                  ],
                                );
                              }),
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
              ],
            ),
          );
        })
        .toList()
        .cast<Widget>();
  }

  List<Widget> _buildCasesTable(List<dynamic> cases) {
    if (cases.isEmpty) return [];

    return cases
        .map((oneCase) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Table(
              border: TableBorder.all(
                color: const Color.fromRGBO(255, 152, 0, 1),
                width: 2.5,
                borderRadius: BorderRadius.circular(10),
              ),
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${oneCase['type'] ?? '-'} (${oneCase['id'] ?? '-'})',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: 'Hafs',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(245, 124, 0, 1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            oneCase['text'] ?? '—',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: 'Hafs',
                              fontSize: 18,
                              color: Color.fromRGBO(245, 124, 0, 1),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        })
        .toList()
        .cast<Widget>();
  }
}
