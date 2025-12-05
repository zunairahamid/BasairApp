import 'dart:async';
import 'package:basair_real_app/core/models/verse.dart';
import 'package:basair_real_app/core/providers/tafsir_provider.dart';
import 'package:basair_real_app/core/providers/verses_provider.dart';
import '../utils/quran_audio_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

const Map<int, int> kAyahCount = {
  1: 7,
  2: 286,
  3: 200,
  4: 176,
  5: 120,
  6: 165,
  7: 206,
  8: 75,
  9: 129,
  10: 109,
  11: 123,
  12: 111,
  13: 43,
  14: 52,
  15: 99,
  16: 128,
  17: 111,
  18: 110,
  19: 98,
  20: 135,
  21: 112,
  22: 78,
  23: 118,
  24: 64,
  25: 77,
  26: 227,
  27: 93,
  28: 88,
  29: 69,
  30: 60,
  31: 34,
  32: 30,
  33: 73,
  34: 54,
  35: 45,
  36: 83,
  37: 182,
  38: 88,
  39: 75,
  40: 85,
  41: 54,
  42: 53,
  43: 89,
  44: 59,
  45: 37,
  46: 35,
  47: 38,
  48: 29,
  49: 18,
  50: 45,
  51: 60,
  52: 49,
  53: 62,
  54: 55,
  55: 78,
  56: 96,
  57: 29,
  58: 22,
  59: 24,
  60: 13,
  61: 14,
  62: 11,
  63: 11,
  64: 18,
  65: 12,
  66: 12,
  67: 30,
  68: 52,
  69: 52,
  70: 44,
  71: 28,
  72: 28,
  73: 20,
  74: 56,
  75: 40,
  76: 31,
  77: 50,
  78: 40,
  79: 46,
  80: 42,
  81: 29,
  82: 19,
  83: 36,
  84: 25,
  85: 22,
  86: 17,
  87: 19,
  88: 26,
  89: 30,
  90: 20,
  91: 15,
  92: 21,
  93: 11,
  94: 8,
  95: 8,
  96: 19,
  97: 5,
  98: 8,
  99: 8,
  100: 11,
  101: 11,
  102: 8,
  103: 3,
  104: 9,
  105: 5,
  106: 4,
  107: 7,
  108: 3,
  109: 6,
  110: 3,
  111: 5,
  112: 4,
  113: 5,
  114: 6,
};

String kAudioUrl(int surah, int ayah) {
  final ss = surah.toString().padLeft(3, '0');
  final aa = ayah.toString().padLeft(3, '0');
  return 'https://everyayah.com/data/Alafasy_128kbps/$ss$aa.mp3';
}

class GlobalPlayerDialog extends StatefulWidget {
  final AudioPlayer player;
  final int startSurah;
  final int startAyah;
  final String Function(int surahId) surahNameOf;
  final VoidCallback onClose;

  const GlobalPlayerDialog({
    super.key,
    required this.player,
    required this.startSurah,
    required this.startAyah,
    required this.surahNameOf,
    required this.onClose,
  });

  @override
  State<GlobalPlayerDialog> createState() => _GlobalPlayerDialogState();
}

class _GlobalPlayerDialogState extends State<GlobalPlayerDialog> {
  late int _s;
  late int _a;
  bool _playing = false;
  Duration _dur = Duration.zero;
  Duration _pos = Duration.zero;

  late final StreamSubscription _subDur;
  late final StreamSubscription _subPos;
  late final StreamSubscription _subState;
  late final StreamSubscription _subComplete;

  @override
  void initState() {
    super.initState();
    _s = widget.startSurah;
    _a = widget.startAyah;

    _subDur = widget.player.onDurationChanged.listen((d) {
      setState(() => _dur = d);
    });
    _subPos = widget.player.onPositionChanged.listen((p) {
      setState(() => _pos = p);
    });
    _subState = widget.player.onPlayerStateChanged.listen((st) {
      setState(() => _playing = (st == PlayerState.playing));
    });
    _subComplete = widget.player.onPlayerComplete.listen((_) {
      _nextGlobal();
    });

    _playCurrent();
  }

  Future<void> _playCurrent() async {
    try {
      await widget.player.stop();
    } catch (_) {}
    await widget.player.play(UrlSource(kAudioUrl(_s, _a)));
  }

  void _nextGlobal() {
    final total = kAyahCount[_s]!;
    if (_a < total) {
      _a += 1;
    } else {
      _s = (_s < 114) ? _s + 1 : 1;
      _a = 1;
    }
    _playCurrent();
  }

  void _prevGlobal() {
    if (_a > 1) {
      _a -= 1;
    } else {
      _s = (_s > 1) ? _s - 1 : 114;
      _a = kAyahCount[_s]!;
    }
    _playCurrent();
  }

  @override
  void dispose() {
    _subDur.cancel();
    _subPos.cancel();
    _subState.cancel();
    _subComplete.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = 'سورة ${widget.surahNameOf(_s)} — آية $_a';

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.black,
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // top bar
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Hafs',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      tooltip: 'إغلاق',
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () async {
                        await widget.player.stop();
                        widget.onClose();
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // artwork placeholder
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.volume_up_outlined,
                      size: 88, color: Colors.black),
                ),

                const SizedBox(height: 16),

                // progress
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    min: 0,
                    max: _dur.inMilliseconds == 0
                        ? 1
                        : _dur.inMilliseconds.toDouble(),
                    value: _pos.inMilliseconds
                        .clamp(0,
                            _dur.inMilliseconds == 0 ? 1 : _dur.inMilliseconds)
                        .toDouble(),
                    onChanged: (v) {
                      setState(() => _pos = Duration(milliseconds: v.round()));
                    },
                    onChangeEnd: (v) async {
                      await widget.player
                          .seek(Duration(milliseconds: v.round()));
                    },
                  ),
                ),

                const SizedBox(height: 6),

                // controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 28,
                      color: Colors.white,
                      icon: const Icon(Icons.skip_previous_rounded),
                      onPressed: _prevGlobal,
                    ),
                    const SizedBox(width: 12),
                    Ink(
                      decoration: const ShapeDecoration(
                        color: Colors.white12,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        iconSize: 36,
                        color: Colors.white,
                        icon: Icon(_playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                        onPressed: () async {
                          if (_playing) {
                            await widget.player.pause();
                          } else {
                            await widget.player.resume();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      iconSize: 28,
                      color: Colors.white,
                      icon: const Icon(Icons.skip_next_rounded),
                      onPressed: _nextGlobal,
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Text('القارئ: مشاري العفاسي',
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Hafs', fontSize: 18)),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuranViewerScreen extends ConsumerStatefulWidget {
  final int pageNumber;
  const QuranViewerScreen({super.key, required this.pageNumber});

  @override
  ConsumerState<QuranViewerScreen> createState() => _QuranViewerScreenState();
}

class _QuranViewerScreenState extends ConsumerState<QuranViewerScreen> {
  late int pageNumber;
  int? selectedVerse;
  Offset _tapPosition = Offset.zero;

  final player = AudioPlayer();
  int? _currentSurah;
  int? _currentAyah;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;

  final bool _inGlobalPlayer = false;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<void>? _completeSub;
  @override
  @override
  void initState() {
    super.initState();
    pageNumber = widget.pageNumber;
    _initializeData();

    player.setReleaseMode(ReleaseMode.stop);

    _stateSub = player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = (state == PlayerState.playing);
        _isLoading = false;
      });
    });

    _durSub = player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _duration = d);
    });

    _posSub = player.onPositionChanged.listen((p) {
      if (!mounted) return;
      if (_isLoading && p > Duration.zero) {
        _isLoading = false;
      }
      setState(() => _position = p);
    });

    _completeSub = player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      if (_inGlobalPlayer) return;
      _nextAyahOnThisPage();
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _durSub?.cancel();
    _posSub?.cancel();
    _completeSub?.cancel();
    player.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await ref.read(versesNotifierProvider.notifier).loadData();
    await ref.read(tafsirNotifierProvider.notifier).loadData();
    _loadVersesForPage();
  }

  void _loadVersesForPage() {
    ref.read(versesNotifierProvider.notifier).loadVersesByPage(pageNumber);
  }

  Future<void> playAudio(int surahIndex, int verse) async {
    setState(() {
      _isLoading = true;
      _position = Duration.zero;
      _duration = Duration.zero;
    });

    try {
      await player.stop();
    } catch (_) {}

    try {
      final file = await getLocalFile(surahIndex, verse);
      if (file.existsSync()) {
        // Play offline file
        await player.play(DeviceFileSource(file.path));
      } else {
        // Download and play
        await downloadAyah(surahIndex, verse);
        await player.play(DeviceFileSource(file.path));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تعذر تشغيل المقطع الصوتي. تحقق من الاتصال.')),
        );
      }
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_isLoading && !_isPlaying && _position == Duration.zero) {
        setState(() => _isLoading = false);
      }
    });
  }

  String getVerseEndSymbol(int verseId) => '\u06DD';

  @override
  Widget build(BuildContext context) {
    final versesState = ref.watch(versesNotifierProvider);

    if (versesState.pages.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: ValueKey('quranViewer_page_$pageNumber'),
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        automaticallyImplyLeading: true,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'سورة ${versesState.getSurahNameByPage(pageNumber) ?? ''}',
                  style: const TextStyle(
                    fontFamily: 'Hafs',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  versesState.getSurahTypeByPage(pageNumber) ?? '',
                  style: const TextStyle(
                    fontFamily: 'Hafs',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: versesState.currentPageVerses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildPortraitView(versesState.currentPageVerses),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Material(
          color: Colors.white,
          elevation: 6,
          child: SizedBox(
            height: 45,
            child: Center(
              child: _buildPageNavigation(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final double max =
        _duration.inMilliseconds.toDouble().clamp(0, double.infinity);
    final double value =
        _position.inMilliseconds.toDouble().clamp(0, max == 0 ? 1 : max);

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        thumbColor: Colors.black,
        activeTrackColor: Colors.black87,
        inactiveTrackColor: Colors.black26,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Slider(
          min: 0,
          max: max == 0 ? 1 : max,
          value: value,
          onChanged: (v) {
            setState(() => _position = Duration(milliseconds: v.round()));
          },
          onChangeEnd: (v) async {
            await player.seek(Duration(milliseconds: v.round()));
          },
        ),
      ),
    );
  }

  Widget _buildPortraitView(Map<int, List<Verse>> surahsOnPage) {
    final tafsirNotifier = ref.read(tafsirNotifierProvider.notifier);

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.indigo[200],
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.black,
              width: 2.5,
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            children: surahsOnPage.entries.map((entry) {
              final surahIndex = entry.key;
              final verses = entry.value;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Only show for surahs with verses
                  if (verses.isNotEmpty && verses[0].id == 1)
                    Container(
                      width: 250,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.black,
                          width: 5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.download_for_offline_outlined,
                              size: 35,
                              color: Colors.black,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    backgroundColor: Colors.white,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 5),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                              Icons
                                                  .download_for_offline_outlined,
                                              size: 70,
                                              color: Colors.black),
                                          const SizedBox(height: 15),
                                          const Text(
                                            'Confirm Download',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              letterSpacing: 1.5,
                                              fontFamily: 'Lato',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Are you sure you want to download the recitation of this Surah?',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                width: 100,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.black,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12),
                                                  ),
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.black,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12),
                                                  ),
                                                  child: const Text(
                                                    'Download',
                                                    style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                              if (confirm == true) {
                                downloadSurah(context, surahIndex);
                              }
                            },
                          ),
                          const SizedBox(width: 2),
                          Text(
                            ref
                                    .read(versesNotifierProvider.notifier)
                                    .getSurahNameById(surahIndex) ??
                                '',
                            style: const TextStyle(
                              fontFamily: 'Hafs',
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Showing Bismillah for Surah 1
                  if (verses.isNotEmpty && verses[0].id == 1 && surahIndex == 1)
                    const Text(
                      'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Hafs',
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 2,
                      ),
                    ),

                  // Show Bismillah for all other surahs (except Surah 9)
                  if (verses.isNotEmpty &&
                      verses[0].id == 1 &&
                      surahIndex != 1 &&
                      surahIndex != 9)
                    const Text(
                      'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Hafs',
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                  // Display each ayah with a divider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: (surahIndex == 1 ? verses.skip(1) : verses)
                        .map((verse) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTapDown: (d) {
                              _tapPosition = d.globalPosition;
                            },
                            onTap: () {
                              setState(() {
                                _currentSurah = surahIndex;
                                _currentAyah = verse.id;
                              });
                              _removeMenu();
                              _showVerseOptionsOverlay(
                                verse,
                                surahIndex,
                                tafsirNotifier,
                              );
                            },
                            onLongPressStart: (d) {
                              setState(() {
                                _tapPosition = d.globalPosition;
                                _currentSurah = surahIndex;
                                _currentAyah = verse.id;
                                selectedVerse = verse.id;
                              });
                              _removeMenu();
                              _showVerseOptionsOverlay(
                                verse,
                                surahIndex,
                                tafsirNotifier,
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                '${verse.text} ${getVerseEndSymbol(verse.id)}',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Hafs',
                                  height: 2,
                                  fontWeight: FontWeight.bold,
                                  fontSize: (pageNumber == 1 || pageNumber == 2)
                                      ? 30
                                      : 28,
                                  color: verse.id == selectedVerse
                                      ? Colors.yellow[300]
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.black,
                            thickness: 2,
                            height: 1,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> downloadSurah(BuildContext context, int surahId) async {
    final ayahCount = kAyahCount[surahId];
    if (ayahCount == null) {
      _showMessageDialog(context, 'Error', 'Invalid Surah ID');
      return;
    }

    // Determine starting ayah
    // Adjust total to download
    // Surah 1 -> Starts from 1 & Surah 9 -> No Bismillah (So Starts from 1)
    // So totalToDownload will stay the same
    // All other Surahs -> Starts from 1 -> Bismillah (So add 1 to totalToDownload to not miss the last Ayah)

    int startNumber = (surahId == 1) ? 1 : 0;
    int totalToDownload;
    if (surahId == 1 || surahId == 9) {
      totalToDownload = ayahCount;
    } else {
      totalToDownload = ayahCount + 1;
    }

    final displayTotal = totalToDownload;

    int completed = 0;
    bool hasError = false;

    late void Function(void Function()) dialogSetState;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            dialogSetState = setState;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 5),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.download_outlined,
                        size: 70, color: Colors.black),
                    const SizedBox(height: 15),
                    Text(
                      'Downloading Surah $surahId',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        letterSpacing: 1.5,
                        fontFamily: 'Lato',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      borderRadius: BorderRadius.circular(30),
                      backgroundColor: Colors.black,
                      color: Colors.indigo[100],
                      value: completed / totalToDownload,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '$completed / $displayTotal Ayahs downloaded',
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    for (int i = 0; i < totalToDownload; i++) {
      int ayahNumber = startNumber + i;

      try {
        await downloadAyah(surahId, ayahNumber);
      } catch (e) {
        print('Error downloading Surah $surahId (Ayah $ayahNumber): $e');
        hasError = true;
      }

      completed++;
      await Future.delayed(const Duration(milliseconds: 100));
      dialogSetState(() {});
    }

    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (hasError) {
      _showMessageDialog(
          context, 'Download Failed', 'Some ayahs failed to download.');
    } else {
      _showMessageDialog(context, 'Download Complete',
          'Surah $surahId downloaded successfully.');
    }
  }

  void _showMessageDialog(BuildContext context, String title, String message,
      {IconData? icon}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 5),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon ?? Icons.info_outline,
                  size: 70,
                  color: Colors.black,
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    letterSpacing: 1.5,
                    fontFamily: 'Lato',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Ok',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  OverlayEntry? _overlayEntry;
  LocalHistoryEntry? _overlayHistoryEntry;

  void _showVerseOptionsOverlay(
    Verse verse,
    int surahIndex,
    TafsirProvider tafsirNotifier,
  ) {
    if (selectedVerse != verse.id) {
      _removeMenu();
      setState(() {
        selectedVerse = verse.id;
        _currentSurah = surahIndex;
        _currentAyah = verse.id;
      });
    } else {
      if (_overlayEntry != null) return;
    }

    final size = MediaQuery.of(context).size;
    const popupWidth = 240.0;
    const popupHeight = 90.0;

    double left = _tapPosition.dx;
    double top = _tapPosition.dy - 50;

    if (left + popupWidth > size.width - 8) left = size.width - popupWidth - 8;
    if (left < 8) left = 8;
    if (top + popupHeight > size.height - 8) {
      top = size.height - popupHeight - 8;
    }
    if (top < 8) top = 8;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeMenu,
            ),
          ),
          Positioned(
            top: top,
            left: left,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: popupWidth,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildOptionButton(
                          icon: Icons.play_arrow_rounded,
                          color: const Color.fromARGB(255, 30, 107, 32),
                          label: 'تشغيل',
                          onPressed: () {
                            _removeMenu();
                            setState(() {
                              _currentSurah = surahIndex;
                              _currentAyah = verse.id;
                              selectedVerse = verse.id;
                            });
                            _playCurrent();
                          },
                          onLongPress: () {
                            _removeMenu();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => GlobalPlayerDialog(
                                player: player,
                                startSurah: surahIndex,
                                startAyah: verse.id,
                                surahNameOf: (id) =>
                                    ref
                                        .read(versesNotifierProvider.notifier)
                                        .getSurahNameById(id) ??
                                    id.toString(),
                                onClose: () {},
                              ),
                            );
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
                      ],
                    ),
                  ),
                  // Small close button
                  Positioned(
                    top: 3,
                    right: 3,
                    child: InkWell(
                      onTap: _removeMenu,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.indigo[200],
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close,
                            color: Colors.black, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    _overlayHistoryEntry = LocalHistoryEntry(onRemove: _removeMenu);
    ModalRoute.of(context)?.addLocalHistoryEntry(_overlayHistoryEntry!);

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeMenu() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    if (_overlayHistoryEntry != null) {
      _overlayHistoryEntry!.remove();
      _overlayHistoryEntry = null;
    }

    if (_overlayEntry == null) {
      setState(() => selectedVerse = null);
    }
  }

  Widget _buildOptionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
    VoidCallback? onLongPress,
  }) {
    return SizedBox(
      width: 70, // fixed width for the entire button (icon + label)
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon, color: color, size: 20),
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Hafs',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTafsirDialog(int surahIndex, int verseId) async {
    final tafsirNotifier = ref.read(tafsirNotifierProvider.notifier);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 5),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_outlined,
                    size: 70, color: Colors.black),
                const SizedBox(height: 15),
                Text(
                  'تفسير الآية ($verseId)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    letterSpacing: 1.0,
                    fontFamily: 'Hafs',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                FutureBuilder<String>(
                  future: tafsirNotifier.getTafsir(surahIndex, verseId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        "يتم التحميل .. يرجى الانتظار",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Hafs',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Text(
                        "حدث خطأ أثناء تحميل التفسير",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Hafs',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      );
                    } else {
                      return SingleChildScrollView(
                        child: Text(
                          snapshot.data ?? "التفسير غير متوفر",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Hafs',
                            fontSize: 17,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'اغلاق',
                      style: TextStyle(
                        fontFamily: 'Hafs',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageNavigation() {
    const double iconSize = 36;
    const double spacing = 50;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (pageNumber < 604) {
              setState(() {
                pageNumber++;
                _removeMenu();
                _loadVersesForPage();
              });
            }
          },
          child: Icon(
            Icons.arrow_circle_left_outlined,
            size: iconSize,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: spacing),
        Text(
          pageNumber.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'CrimsonText',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(width: spacing),
        GestureDetector(
          onTap: () {
            if (pageNumber > 1) {
              setState(() {
                pageNumber--;
                _removeMenu();
                _loadVersesForPage();
              });
            }
          },
          child: Icon(
            Icons.arrow_circle_right_outlined,
            size: iconSize,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Future<void> _playCurrent() async {
    if (_currentSurah == null || _currentAyah == null) return;
    setState(() => selectedVerse = _currentAyah);
    await playAudio(_currentSurah!, _currentAyah!);
    setState(() => _isPlaying = true);
  }

  Future<void> _pause() async {
    await player.pause();
    setState(() => _isPlaying = false);
  }

  bool _hasNextOnThisPage(Map<int, List<Verse>> surahsOnPage) {
    if (_currentSurah == null || _currentAyah == null) return false;
    final list = surahsOnPage[_currentSurah!];
    if (list == null || list.isEmpty) return false;
    final idx = list.indexWhere((v) => v.id == _currentAyah);
    return idx != -1 && idx < list.length - 1;
  }

  bool _hasPrevOnThisPage(Map<int, List<Verse>> surahsOnPage) {
    if (_currentSurah == null || _currentAyah == null) return false;
    final list = surahsOnPage[_currentSurah!];
    if (list == null || list.isEmpty) return false;
    final idx = list.indexWhere((v) => v.id == _currentAyah);
    return idx > 0;
  }

  Future<void> _nextAyahOnThisPage() async {
    final versesMap = ref.read(versesNotifierProvider).currentPageVerses;
    if (!_hasNextOnThisPage(versesMap)) return;
    final list = versesMap[_currentSurah!]!;
    final idx = list.indexWhere((v) => v.id == _currentAyah);
    if (idx != -1 && idx < list.length - 1) {
      setState(() {
        _currentAyah = list[idx + 1].id;
        selectedVerse = _currentAyah;
      });
      await _playCurrent();
    }
  }

  Future<void> _prevAyahOnThisPage() async {
    final versesMap = ref.read(versesNotifierProvider).currentPageVerses;
    if (!_hasPrevOnThisPage(versesMap)) return;
    final list = versesMap[_currentSurah!]!;
    final idx = list.indexWhere((v) => v.id == _currentAyah);
    if (idx > 0) {
      setState(() {
        _currentAyah = list[idx + 1].id;
        selectedVerse = _currentAyah;
      });
      await _playCurrent();
    }
  }
}
