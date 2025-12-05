import 'package:basair_real_app/core/models/surah.dart';
import 'package:basair_real_app/core/providers/surahs_provider.dart';
import 'package:basair_real_app/features/ai_generate_quizzes/view/qna_view.dart';
import 'package:basair_real_app/features/ai_generate_tafsir/view/tafsir_view.dart';
import 'package:basair_real_app/features/quran_navigator/view/widgets/image_viewer.dart';
import 'package:basair_real_app/features/quran_viewer/view/screens/quran_viewer_screen.dart';
import 'package:basair_real_app/features/topic_map/view/surah_topics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SurahDisplay extends ConsumerWidget {
  const SurahDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahs = ref.watch(surahProvider);

    return ListView.builder(
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        Surah surah = surahs.elementAt(index);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: InkWell(
            // CARD TAP -> Navigate to QuranViewerScreen
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      QuranViewerScreen(pageNumber: surah.page),
                ),
              );
            },
            child: Card(
              color: Colors.indigo[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 40,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.indigo[100],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${surah.id}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      surah.englishName,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'CrimsonText',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo[100],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        '${surah.ayaCount} Ayahs',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'CrimsonText',
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  surah.name,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Hafs',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Colors.black54),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Topic Map button (with key for tests)
                                KeyedSubtree(
                                  key: const ValueKey('open_topic_map_button'),
                                  child: circleButton(
                                    size: 50,
                                    child: Image.asset(
                                      'assets/images/5054253-200.png',
                                      width: 28,
                                      height: 28,
                                    ),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          final screenWidth =
                                              MediaQuery.of(context)
                                                  .size
                                                  .width;
                                          final screenHeight =
                                              MediaQuery.of(context)
                                                  .size
                                                  .height;

                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            backgroundColor: Colors.white,
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: screenWidth * 0.9,
                                                maxHeight: screenHeight * 0.85,
                                              ),
                                              child: SingleChildScrollView(
                                                padding:
                                                    const EdgeInsets.all(24),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.close,
                                                          color: Colors.black,
                                                          size: 26,
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons.info_outline,
                                                      size: 55,
                                                      color: Colors.black,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                      'Topics Map Tutorial',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        letterSpacing: 1.5,
                                                        fontFamily: 'Lato',
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                      'Click the buttons below to see a visual representation of each map part.',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Wrap(
                                                      alignment:
                                                          WrapAlignment.center,
                                                      spacing: 10,
                                                      runSpacing: 10,
                                                      children: [
                                                        _buildDialogButton(
                                                          label: 'Subtopics',
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (_) =>
                                                                  const ImageViewer(
                                                                imagePath:
                                                                  'assets/images/Topic_And_Subtopics.jpg',
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        _buildDialogButton(
                                                          label: 'Subsections',
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (_) =>
                                                                  const ImageViewer(
                                                                imagePath:
                                                                  'assets/images/Subsections.jpg',
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        _buildDialogButton(
                                                          label: 'Cases',
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (_) =>
                                                                  const ImageViewer(
                                                                imagePath:
                                                                  'assets/images/Cases.jpg',
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    SizedBox(
                                                      width: 350,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.black,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                          ),
                                                          elevation: 3,
                                                        ),
                                                        onPressed: () {
                                                          // ✅ close tutorial dialog
                                                          Navigator.of(context)
                                                              .pop();

                                                          // ✅ navigate to Topic Map screen
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  SurahTopicsView(
                                                                surahId:
                                                                    surah.id,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: const Text(
                                                          'OK',
                                                          style: TextStyle(
                                                            fontFamily: 'Lato',
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                            letterSpacing: 1.2,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                // Quiz button
                                circleButton(
                                  size: 50,
                                  child: const Icon(
                                    Icons.quiz_outlined,
                                    size: 28,
                                    color: Colors.black,
                                  ),
                                  onTap: () {

                                       Navigator.push(
                                                          context,
                                                         MaterialPageRoute(
                                                             builder: (_) =>
                                                                QnAScreen(surahTitle: surah.name, surahId: surah.id)
                                                           ),
                                                         );

                                    // TODO: Quiz navigation

                                  },
                                ),
                                // Tafsir / Explanations button
                                circleButton(
                                  size: 50,
                                  child: const Icon(
                                    Icons.menu_book_rounded,
                                    size: 28,
                                    color: Colors.black,
                                  ),
                                  onTap: () {

                                     Navigator.push(
                                                          context,
                                                         MaterialPageRoute(
                                                             builder: (_) =>
                                                                TafsirScreen( surahId: surah.id)
                                                           ),
                                                         );

                                    // TODO: Tafsir navigation

                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper widgets (same as your newer version)
Widget _buildDialogButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: 110,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
        padding: const EdgeInsets.all(10),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black,
          letterSpacing: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

Widget circleButton({
  required Widget child,
  required VoidCallback onTap,
  double size = 35,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.indigo[100],
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    ),
  );
}
