import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/juz_provider.dart';
import '../providers/quarter_provider.dart';
import '../model/juz.dart';
import '../model/quarters.dart';

final revealJuzQuartersProvider = StateProvider<int?>((ref) => null);

class JuzDisplay extends ConsumerWidget {
  const JuzDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final juzs = ref.watch(juzNotifierProvider.notifier)as List;
    final quarters = ref.watch(quarterNotifierProvider.notifier).build();
    final revealQuarters = ref.watch(revealJuzQuartersProvider.notifier);

    return ListView.builder(
      itemCount: juzs.length,
      itemBuilder: (context, index) {
        Juz juz = juzs[index];
        List<Quarters> juzQuarters =
            quarters.where((q) => (q.index - 1) ~/ 8 + 1 == juz.index).toList();

        return Card(
          color: const Color.fromARGB(213, 3, 22, 11),
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 169, 197, 170),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${juz.index}',
                    style: TextStyle(
                      color: const Color.fromARGB(213, 3, 22, 11),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  'Juz ${juz.index}',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 169, 197, 170),
                    fontFamily: "CrimsonText",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  revealQuarters == juz.index
                      ? Icons.arrow_drop_up_outlined
                      : Icons.arrow_drop_down_outlined,
                  color: const Color.fromARGB(210, 232, 241, 233),
                ),
                onTap: () {
                  ref.read(revealJuzQuartersProvider.notifier).state =
                      revealQuarters == juz.index ? null : juz.index;
                },
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: revealQuarters == juz.index ? 130 : 0,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                            builder:
                                (context) => PlaceholderScreen(
                                  quarterIndex: juzQuarter.index,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(136, 119, 183, 140),
                          borderRadius: BorderRadius.circular(70),
                        ),
                        child: Center(
                          child: Text(
                            'Index ${juzQuarter.index}',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 169, 197, 170),
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
            ],
          ),
        );
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final int quarterIndex;

  const PlaceholderScreen({super.key, required this.quarterIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quran Viewer")),
      body: Center(
        child: Text(
          "This is the First Page of the Selected Quarter on Quran Viewer.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}