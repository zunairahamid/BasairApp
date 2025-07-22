import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sdp_quran_navigator/display/quran_viewer_screen.dart';
import '../providers/juz_provider.dart';
import '../providers/quarter_provider.dart';
import '../model/juz.dart';
import '../model/quarters.dart';

final revealJuzQuartersProvider = StateProvider<int?>((ref) => null);

class JuzDisplay extends ConsumerWidget {
  const JuzDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final juzProvider = ref.watch(juzNotifierProvider);
    final quarters = ref.watch(quarterNotifierProvider);
    final revealQuarters = ref.watch(revealJuzQuartersProvider);

    return Scaffold(
      appBar: null,
      body: juzProvider.when(
        data: (juzs) {
          return ListView.builder(
            itemCount: juzs.length,
            itemBuilder: (context, index) {
              Juz juz = juzs[index];
              List<Quarters> juzQuarters = quarters
                  .where((q) => (q.index - 1) ~/ 8 + 1 == juz.index)
                  .toList();

              return Card(
                color: Colors.indigo[100],
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                             Colors.indigo[300],
                        child: Text(
                          '${juz.index}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        'Juz ${juz.index}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: "CrimsonText",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        revealQuarters == juz.index
                            ? Icons.arrow_drop_up_outlined
                            : Icons.arrow_drop_down_outlined,
                        color: Colors.black,
                      ),
                      onTap: () {
                        ref.read(revealJuzQuartersProvider.notifier).state =
                            revealQuarters == juz.index ? null : juz.index;
                      },
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      alignment: Alignment.topCenter,
                      child: revealQuarters == juz.index
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: SizedBox(
                                height: 130, // Adjusted for proper expansion
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 2,
                                  ),
                                  itemCount: juzQuarters.length,
                                  itemBuilder: (context, qIndex) {
                                    Quarters juzQuarter = juzQuarters[qIndex];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                QuranViewerScreen(
                                                    pageNumber:
                                                        juzQuarter.index),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(8),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.indigo[300],
                                          borderRadius:
                                              BorderRadius.circular(70),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Index ${juzQuarter.index}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'CrimsonText',
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            },
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(
              "An error occurred: $error",
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
