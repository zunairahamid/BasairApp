import 'package:basair_real_app/core/providers/juzs_provider.dart';
import 'package:basair_real_app/features/quran_viewer/view/screens/quran_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final revealJuzQuartersProvider = StateProvider<int?>((ref) => null);

class JuzDisplay extends ConsumerWidget {
  const JuzDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final juzProvider = ref.watch(juzNotifierProvider);
    final revealQuarters = ref.watch(revealJuzQuartersProvider);

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      body: juzProvider.when(
        data: (juzs) {
          return ListView.builder(
            itemCount: juzs.length,
            itemBuilder: (context, index) {
              final juz = juzs[index];
              final juzNotifier = ref.read(juzNotifierProvider.notifier);
              final juzQuarters = juzNotifier.getJuzQuarters(juz.index);

              return Card(
                color: Colors.indigo[200],
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo[100],
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        revealQuarters == juz.index
                            ? Icons.arrow_drop_up_outlined
                            : Icons.arrow_drop_down_outlined,
                        color: Colors.black,
                        size: 28,
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
                                  horizontal: 10, vertical: 10),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(4),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 2.5,
                                ),
                                itemCount: juzQuarters.length,
                                itemBuilder: (context, qIndex) {
                                  final part = juzQuarters[qIndex];
                                  final startPage = part['startPage']!;
                                  final endPage = part['endPage']!;
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              QuranViewerScreen(
                                                  pageNumber: startPage),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.indigo[100],
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                            color: Colors.black, width: 2.5),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$startPage - $endPage',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'CrimsonText',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
              "Error: $error",
              style: const TextStyle(color: Colors.black, fontSize: 30),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
