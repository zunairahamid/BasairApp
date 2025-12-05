import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../domain/entities/mahawer.dart';

class TreeSidebar extends StatelessWidget {
  final String surahName;
  final List<Mahawer> mahawerList;
  final Function(dynamic) onNodeSelected;

  const TreeSidebar({
    super.key,
    required this.surahName,
    required this.mahawerList,
    required this.onNodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
        },
      ),
      child: ListView(
        key: ValueKey(mahawerList.length), 
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            surahName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),

          if (mahawerList.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("No mahawer extracted yet."),
            ),

          ...mahawerList.map((m) {
            return ExpansionTile(
              title: Text(m.title),
              onExpansionChanged: (_) => onNodeSelected(m),
              children: [
                ...(m.sections ?? []).map((s) => ListTile(
                      title: Text(s.title ?? s.sequence ?? s.id),
                      onTap: () => onNodeSelected(s),
                    )),
              ],
            );
          }),
        ],
      ),
    );
  }
}


