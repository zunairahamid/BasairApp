import 'dart:async';
import '../models/verses.dart';
import '../providers/surahWithMahawer_provider.dart';
import '../providers/tafsir_provider.dart';
import '../providers/verses_provider.dart';
import '../routes/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:to_arabic_number/to_arabic_number.dart';

class QuranViewerScreen extends ConsumerStatefulWidget {
  final int pageNumber;
  const QuranViewerScreen({super.key, required this.pageNumber});

  @override
  ConsumerState<QuranViewerScreen> createState() => _QuranViewerScreenState();
}

class _QuranViewerScreenState extends ConsumerState<QuranViewerScreen> {
  late int pageNumber;
  int? selectedVerse;
  OverlayEntry? _overlayEntry;
  Offset _tapPosition = Offset.zero;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    pageNumber = widget.pageNumber;
    _initializeData();
  }

  Future<void> _initializeData() async {
    await ref.read(versesNotifierProvider.notifier).loadData();
    await ref.read(mahawerNotifierProvider.notifier).loadData();
    await ref.read(tafsirNotifierProvider.notifier).loadData();
    _loadVersesForPage();
  }

  void _loadVersesForPage() {
    ref.read(versesNotifierProvider.notifier).loadVersesByPage(pageNumber);
  }

  void _removeMenu() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      setState(() {
        selectedVerse = null;
      });
    }
  }

  Future<void> playAudio(int surahIndex, int verse) async {
    final surahNumber = surahIndex.toString().padLeft(3, '0');
    final ayahNumber = verse.toString().padLeft(3, '0');
    await player.play(UrlSource(
        'https://everyayah.com/data/Alafasy_128kbps/$surahNumber$ayahNumber.mp3'));
  }

  String getVerseEndSymbol(int verseId) {
    return '\u06DD'; // Arabic end of ayah symbol
  }

  @override
  Widget build(BuildContext context) {
    final versesState = ref.watch(versesNotifierProvider);
    final mahawerState = ref.watch(mahawerNotifierProvider);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (versesState.pages.isEmpty || mahawerState.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))),
        toolbarHeight: 80,
        backgroundColor: Colors.indigo[300],
        title: Padding(
          padding:
              const EdgeInsets.only(right: 12, left: 12, top: 12, bottom: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRouter.navigation.path),
                    icon: const Icon(Icons.home_rounded),
                    color: Colors.black,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    versesState.getSurahTypeByPage(pageNumber) ?? '',
                    style: const TextStyle(
                      fontFamily: 'Hafs',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'سورة ${versesState.getSurahNameByPage(pageNumber) ?? ''}',
                    style: const TextStyle(
                        fontFamily: 'Hafs',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: versesState.currentPageVerses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : isLandscape
              ? _buildLandscapeView(versesState.currentPageVerses)
              : _buildPortraitView(versesState.currentPageVerses),
      bottomNavigationBar: _buildPageNavigation(),
    );
  }

  Widget _buildLandscapeView(Map<int, List<Verse>> surahsOnPage) {
    final mahawerNotifier = ref.read(mahawerNotifierProvider.notifier);
    // ignore: unused_local_variable
    final tafsirNotifier = ref.read(tafsirNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(right: 50, left: 50, top: 30, bottom: 30),
      child: ListView(
        children: surahsOnPage.entries.map((entry) {
          final surahIndex = entry.key;
          final verses = entry.value;

          final List<List<Verse>> groupedVerses = [];
          List<Verse>? currentGroup;
          String? lastSectionId;

          for (var verse in verses) {
            final sectionData =
                mahawerNotifier.findSections(verse.id, surahIndex);
            final sectionId = sectionData['id']?.toString();

            if (sectionId == null || sectionId != lastSectionId) {
              if (currentGroup != null) groupedVerses.add(currentGroup);
              currentGroup = [verse];
            } else {
              currentGroup!.add(verse);
            }
            lastSectionId = sectionId;
          }

          if (currentGroup != null) groupedVerses.add(currentGroup);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                if (verses.isNotEmpty && verses[0].id == 1)
                  Text(
                    ref
                            .read(versesNotifierProvider.notifier)
                            .getSurahNameById(surahIndex) ??
                        '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Hafs',
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 2.5,
                    ),
                  ),
                if (verses.isNotEmpty &&
                    surahIndex != 9 &&
                    surahIndex != 1 &&
                    verses[0].id == 1)
                  const Text(
                    'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Hafs',
                      fontSize: 30,
                      fontWeight: FontWeight.normal,
                      color: Colors.indigo,
                      height: 3.5,
                    ),
                  ),
                Table(
                  border: TableBorder.all(
                    color: const Color.fromARGB(213, 3, 22, 11),
                    width: 2,
                  ),
                  children: groupedVerses.map((groupEntry) {
                    final sectionData = mahawerNotifier.findSections(
                        groupEntry[0].id, surahIndex);
                    final sectionId = sectionData['id']?.toString();
                    final sectionText = sectionData['text']?.toString() ?? '';
                    final sectionRange = sectionData['range']?.toString() ?? '';
                    return TableRow(
                      decoration: BoxDecoration(
                        color: sectionId != null
                            ? mahawerNotifier.getSectionColorLandscape(
                                double.parse(sectionId))
                            : Colors.transparent,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            sectionId != null
                                ? "المحور رقم $sectionId \n $sectionText \n الآيات $sectionRange"
                                : 'المحور غير متوفر حالياً',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontFamily: 'Hafs',
                                fontWeight: FontWeight.bold,
                                fontSize: 25),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            children: groupEntry.map((verse) {
                              return GestureDetector(
                                onTap: () => playAudio(surahIndex, verse.id),
                                onLongPress: () =>
                                    _showTafsirDialog(surahIndex, verse.id),
                                child: Text(
                                  '${verse.text} ${getVerseEndSymbol(verse.id)} ',
                                  style: TextStyle(
                                    fontFamily: 'Hafs',
                                    height: 2.5,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        (pageNumber == 1 || pageNumber == 2)
                                            ? 25
                                            : 20,
                                    color: verse.id == selectedVerse
                                        ? Color.fromARGB(255, 159, 131, 66)
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPortraitView(Map<int, List<Verse>> surahsOnPage) {
    final mahawerNotifier = ref.read(mahawerNotifierProvider.notifier);
    final tafsirNotifier = ref.read(tafsirNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(right: 30, left: 30, top: 10, bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: Colors.indigo[100],
          borderRadius: BorderRadius.circular(70),
        ),
        child: ListView(
          shrinkWrap: true,
          children: surahsOnPage.entries.map((entry) {
            final surahIndex = entry.key;
            final verses = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: RichText(
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      children: [
                        if (verses.isNotEmpty && verses[0].id == 1)
                          TextSpan(
                            text:
                                '\n ${ref.read(versesNotifierProvider.notifier).getSurahNameById(surahIndex)} \n',
                            style: const TextStyle(
                                fontFamily: 'Hafs',
                                fontSize: 40,
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                          ),
                        if (verses.isNotEmpty &&
                            surahIndex != 9 &&
                            surahIndex != 1 &&
                            verses[0].id == 1)
                          const TextSpan(
                            text: 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ\n',
                            style: TextStyle(
                              fontFamily: 'Hafs',
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ...verses.map((verse) {
                          final sectionData = mahawerNotifier.findSections(
                              verse.id, surahIndex);
                          final sectionId = sectionData['id']?.toString();

                          return TextSpan(
                            text:
                                '${verse.text} ${getVerseEndSymbol(verse.id)} ',
                            style: TextStyle(
                              fontFamily: 'Hafs',
                              height: 3.0,
                              fontWeight: FontWeight.bold,
                              fontSize: (pageNumber == 1 || pageNumber == 2)
                                  ? 30
                                  : 24,
                              color: verse.id == selectedVerse
                                  ? Colors.indigo
                                  : (surahIndex != 4
                                      ? Colors.black
                                      : mahawerNotifier.getSectionColorPortrait(
                                              double.tryParse(
                                                      sectionId ?? '0') ??
                                                  0.0) ??
                                          Colors.black),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTapDown = (TapDownDetails details) {
                                setState(() {
                                  _removeMenu();
                                  _tapPosition = details.globalPosition;
                                  selectedVerse = verse.id;
                                });
                                _showVerseOptionsOverlay(verse, surahIndex,
                                    mahawerNotifier, tafsirNotifier);
                              },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showVerseOptionsOverlay(Verse verse, int surahIndex,
      SurahWithMahawerProvider mahawerNotifier, TafsirProvider tafsirNotifier) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: _tapPosition.dy - 50,
        left: _tapPosition.dx,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              _removeMenu();
            },
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildOptionButton(
                    icon: Icons.play_arrow_rounded,
                    color: const Color.fromARGB(255, 30, 107, 32),
                    label: 'تشغيل',
                    onPressed: () {
                      _removeMenu();
                      playAudio(surahIndex, verse.id);
                    },
                  ),
                  _buildOptionButton(
                    icon: Icons.assignment,
                    color: const Color.fromARGB(255, 81, 76, 175),
                    label: 'تفسير',
                    onPressed: () {
                      _removeMenu();
                      _showTafsirDialog(surahIndex, verse.id);
                    },
                  ),
                  _buildOptionButton(
                    icon: Icons.auto_stories_outlined,
                    color: const Color.fromARGB(255, 165, 52, 54),
                    label: 'شرح المحور',
                    onPressed: () {
                      _removeMenu();
                      _showMahwarDialog(verse, surahIndex, mahawerNotifier);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildOptionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 20),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Future<void> _showTafsirDialog(int surahIndex, int verseId) async {
    final tafsirNotifier = ref.read(tafsirNotifierProvider.notifier);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'تفسير الآية $verseId',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: FutureBuilder<String>(
            future: tafsirNotifier.getTafsir(surahIndex, verseId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("يتم التحميل .. يرجى الانتظار");
              } else if (snapshot.hasError) {
                return const Text("حدث خطأ أثناء تحميل التفسير");
              } else {
                return Text(snapshot.data ?? "No Tafsir available");
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "اغلاق",
                style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 81, 76, 175),
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showMahwarDialog(
      Verse verse, int surahIndex, SurahWithMahawerProvider mahawerNotifier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            ' شرح المحور الآية ${verse.id}',
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          content: Text(
            surahIndex != 4
                ? "محور هذه السورة غير متوفر"
                : "المحور رقم ${mahawerNotifier.findSections(verse.id, surahIndex)['id']} \n ${mahawerNotifier.findSections(verse.id, surahIndex)['text']} \n الآيات${mahawerNotifier.findSections(verse.id, surahIndex)['range']}",
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "اغلاق",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            if (pageNumber < 604) {
              setState(() {
                pageNumber++;
                _removeMenu();
                _loadVersesForPage();
              });
            }
          },
          icon: const Icon(
            Icons.arrow_circle_left_rounded,
            color: Colors.black,
            size: 50,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4.0),
          margin: const EdgeInsets.only(bottom: 4.0, top: 4.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          height: 35,
          width: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                Arabic.number(pageNumber.toString()),
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            if (pageNumber > 1) {
              setState(() {
                pageNumber--;
                _removeMenu();
                _loadVersesForPage();
              });
            }
          },
          icon: const Icon(
            Icons.arrow_circle_right_rounded,
            color: Colors.black,
            size: 50,
          ),
        ),
      ],
    );
  }
}
