import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_app/domain/entities/mahawer.dart';
import 'package:my_app/domain/entities/section.dart';
import 'package:my_app/domain/entities/sub_section.dart';
import 'package:my_app/domain/entities/surah.dart';
import 'package:my_app/domain/entities/tafsir.dart';
import 'package:my_app/domain/entities/topic.dart';
import 'package:provider/provider.dart' as provider_package;
import '../../domain/usecases/extract_text_usecase.dart';
import '../../domain/usecases/convert_to_json_usecase.dart';
import '../providers/json_provider.dart';
import '../widgets/tree_sidebar.dart';
import '../widgets/edit_panel.dart';
import '../../data/repositories/pdf_repository_impl.dart';
import '../../data/repositories/ai_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Tafsir? tafsir;
  bool isLoading = false;
  dynamic selectedNode;
  List<Map<String, dynamic>> availableTafsirs = [];
  String? selectedTafsirId;

  @override
  void initState() {
    super.initState();
    _loadAvailableTafsirs();
  }

  Future<void> _loadAvailableTafsirs() async {
    try {
      final response = await Supabase.instance.client
          .from('tafsirs')
          .select('tafsir_id, title, surah_id');
      setState(() {
        availableTafsirs = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error loading tafsirs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load tafsirs from Supabase')),
      );
    }
  }

  Future<void> _loadTafsirFromSupabase(String tafsirId) async {
    setState(() => isLoading = true);

    try {
      final tafsirMeta = await Supabase.instance.client
          .from('tafsirs')
          .select('*')
          .eq('tafsir_id', tafsirId)
          .single();

      final surahRow = await Supabase.instance.client
          .from('surahs')
          .select('*')
          .eq('surah_id', tafsirMeta['surah_id'])
          .single();

      final surah = Surah(
        surahId: surahRow['surah_id'],
        surahName: surahRow['surah_name'],
      );

      final mahawerRows = await Supabase.instance.client
          .from('mahawer')
          .select('*')
          .eq('tafsir_id', tafsirId);

      List<Mahawer> mahawerList = [];

      for (final m in mahawerRows) {
        final sectionRows = await Supabase.instance.client
            .from('sections')
            .select('*')
            .eq('mahawer_id', m['mahawer_id']);

        List<Section> sectionsList = [];

        for (final s in sectionRows) {
          final subSectionRows = await Supabase.instance.client
              .from('sub_sections')
              .select('*')
              .eq('section_id', s['section_id']);

          List<SubSection> subSectionsList = [];

          for (final ss in subSectionRows) {
            final topicsRows = await Supabase.instance.client
                .from('topics')
                .select('*')
                .eq('sub_section_id', ss['sub_section_id']);

            final topics = topicsRows.map<Topic>((t) {
              return Topic(
                id: t['topic_id'],
                type: t['type'],
                sequence: t['sequence'],
                text: t['text'],
                ayat:
                    (t['ayat'] as List<dynamic>?)
                        ?.map((e) => e as int)
                        .toList() ??
                    [],
              );
            }).toList();

            subSectionsList.add(
              SubSection(
                id: ss['sub_section_id'],
                type: ss['type'],
                sequence: ss['sequence'],
                text: ss['text'],
                ayat: (ss['ayat'] as List<dynamic>?)
                    ?.map((e) => e as int)
                    .toList(),
                conclusion: ss['conclusion'],
                topics: topics,
              ),
            );
          }

          sectionsList.add(
            Section(
              id: s['section_id'],
              type: s['type'],
              sequence: s['sequence'],
              title: s['title'],
              text: s['text'],
              ayat: (s['ayat'] as List<dynamic>?)
                  ?.map((e) => e as int)
                  .toList(),
              subSections: subSectionsList,
            ),
          );
        }

        mahawerList.add(
          Mahawer(
            id: m['mahawer_id'],
            type: m['type'],
            sequence: m['sequence'],
            title: m['title'],
            text: m['text'],
            ayat: (m['ayat'] as List<dynamic>?)?.map((e) => e as int).toList(),
            isMuqadimah: m['is_muqadimah'],
            isKhatimah: m['is_khatimah'],
            sections: sectionsList,
          ),
        );
      }

      setState(() {
        tafsir = Tafsir(
          tafsirId: tafsirMeta['tafsir_id'],
          title: tafsirMeta['title'],
          author: tafsirMeta['author'],
          publisher: tafsirMeta['publisher'],
          year: tafsirMeta['year'],
          location: tafsirMeta['location'],
          isbn: tafsirMeta['isbn'],
          surahId: tafsirMeta['surah_id'],
          state: tafsirMeta['state'],
          surah: surah,
          mahawer: mahawerList,
        );
        selectedNode = null;
      });
    } catch (e) {
      print("Error loading tafsir: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load tafsir: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onTafsirSelected(String? tafsirId) {
    if (tafsirId != null) {
      setState(() {
        selectedTafsirId = tafsirId;
      });
      _loadTafsirFromSupabase(tafsirId);
    }
  }

  void _onNodeSelected(dynamic node) {
    setState(() {
      selectedNode = node;
    });
  }

  void _onNodeEdited(dynamic updatedNode) {
    setState(() {
      selectedNode = updatedNode;
      if (updatedNode is Mahawer) {
        final index = tafsir!.mahawer.indexWhere((m) => m.id == updatedNode.id);
        if (index != -1) tafsir!.mahawer[index] = updatedNode;
      } else if (updatedNode is Section) {
        for (var mahawer in tafsir!.mahawer) {
          final index = mahawer.sections.indexWhere(
            (s) => s.id == updatedNode.id,
          );
          if (index != -1) mahawer.sections[index] = updatedNode;
        }
      } else if (updatedNode is SubSection) {
        for (var mahawer in tafsir!.mahawer) {
          for (var section in mahawer.sections) {
            final index =
                section.subSections?.indexWhere(
                  (ss) => ss.id == updatedNode.id,
                ) ??
                -1;
            if (index != -1) section.subSections![index] = updatedNode;
          }
        }
      } else if (updatedNode is Topic) {
        for (var mahawer in tafsir!.mahawer) {
          for (var section in mahawer.sections) {
            for (var subSection in section.subSections ?? []) {
              final index =
                  subSection.topics?.indexWhere(
                    (t) => t.id == updatedNode.id,
                  ) ??
                  -1;
              if (index != -1) subSection.topics![index] = updatedNode;
            }
          }
        }
      }
    });
  }

  Future<void> _saveTafsirToSupabase() async {
    if (tafsir == null || selectedTafsirId == null) return;
    setState(() {
      isLoading = true;
    });
    try {
      await _deleteTafsirData(selectedTafsirId!);
      await _insertTafsirData(selectedTafsirId!, tafsir!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved Successfully')));
    } catch (e) {
      print('Error saving tafsir: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save tafsir: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteTafsirData(String tafsirId) async {
    await Supabase.instance.client
        .from('topics')
        .delete()
        .eq('sub_section_id', ''); 
    await Supabase.instance.client
        .from('sub_sections')
        .delete()
        .eq('section_id', '');
    await Supabase.instance.client
        .from('sections')
        .delete()
        .eq('mahawer_id', '');
    await Supabase.instance.client
        .from('mahawer')
        .delete()
        .eq('tafsir_id', tafsirId);
  }

Future<void> _uploadPDF() async {
  final prompt = '''
You are an AI that extracts and structures text into a specific JSON schema.
Output ONLY a valid JSON object with EXACTLY this structure (no markdown, no extra text).

IMPORTANT RULES:
1) You MUST generate a NON-EMPTY tafsirId.
   Format: tafsir_<surahId>_<authorLastName>_<year>
   Example: tafsir_004_mujayidi_2019
2) surahId must be a string like "004" or "4".
3) Do not add or remove fields.
4) Always include "mahawer" as an array (even if empty).

SCHEMA:
{
  "tafsirId": "string",
  "title": "string",
  "author": "string",
  "publisher": "string",
  "year": number,
  "location": "string",
  "isbn": "string",
  "surahId": "string",
  "state": "string",
  "surah": {
    "surahId": "string",
    "surahName": "string"
  },
  "mahawer": [
    {
      "id": "string",
      "type": "string",
      "sequence": "string",
      "title": "string",
      "text": "string",
      "ayat": [number],
      "isMuqadimah": boolean,
      "isKhatimah": boolean,
      "sections": [
        {
          "id": "string",
          "type": "string",
          "sequence": "string",
          "title": "string",
          "text": "string",
          "ayat": [number],
          "conclusion": "string",
          "subSections": [
            {
              "id": "string",
              "type": "string",
              "sequence": "string",
              "text": "string",
              "ayat": [number],
              "conclusion": "string",
              "topics": [
                {
                  "id": "string",
                  "type": "string",
                  "sequence": "string",
                  "text": "string",
                  "ayat": [number]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}

Output ONLY JSON.
''';

  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
    withData: true,
  );

  if (result == null) return;

  setState(() => isLoading = true);

  try {
    final file = result.files.single;

    if (file.bytes == null) {
      throw Exception("No file bytes received. Try picking again.");
    }

    final bytes = file.bytes!;
    print("PDF size: ${bytes.length}");

    
    final extractedText =
        await ExtractTextUseCase(PdfRepositoryImpl()).call(bytes);

    print("Extracted TEXT length: ${extractedText.length}");

    if (extractedText.trim().isEmpty) {
      throw Exception("Extracted text is empty.");
    }

    
    final tafsirUseCase = ConvertToJsonUseCase(
      AiRepositoryImpl('YOUR AI API KEY'),
    );

    final newTafsir = await tafsirUseCase.call(extractedText, prompt);

    print("AI returned tafsirId: ${newTafsir.tafsirId}");
    print("Mahawer count: ${newTafsir.mahawer.length}");

    provider_package.Provider.of<JsonProvider>(context, listen: false)
        .setTafsir(newTafsir);

    setState(() {
      tafsir = newTafsir;             
      selectedTafsirId = newTafsir.tafsirId;
      selectedNode = null;
    });

    final newId = newTafsir.tafsirId;

    await Supabase.instance.client.from('surahs').upsert({
      'surah_id': newTafsir.surahId,
      'surah_name': newTafsir.surah.surahName,
    });

    await Supabase.instance.client.from('tafsirs').upsert({
      'tafsir_id': newId,
      'title': '${newTafsir.surah.surahName} - $newId',
      'author': newTafsir.author,
      'publisher': newTafsir.publisher,
      'year': newTafsir.year,
      'location': newTafsir.location,
      'isbn': newTafsir.isbn,
      'surah_id': newTafsir.surahId,
      'state': newTafsir.state,
    });

    await _insertTafsirData(newId, newTafsir);

    await _loadAvailableTafsirs();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF processed successfully')),
    );
  } catch (e, st) {
    print("Error processing PDF: $e");
    print(st);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error processing PDF: $e')),
    );
  } finally {
    setState(() => isLoading = false);
  }
}

  Future<void> _insertTafsirData(String tafsirId, Tafsir tafsir) async {
    for (var mahawer in tafsir.mahawer) {
      final mahawerId = mahawer.id;
      await Supabase.instance.client.from('mahawer').insert({
        'mahawer_id': mahawerId,
        'tafsir_id': tafsirId,
        'type': mahawer.type,
        'sequence': mahawer.sequence,
        'title': mahawer.title,
        'text': mahawer.text,
        'ayat': mahawer.ayat,
        'is_muqadimah': mahawer.isMuqadimah,
        'is_khatimah': mahawer.isKhatimah,
      });

      for (var section in mahawer.sections) {
        final sectionId = section.id;
        await Supabase.instance.client.from('sections').insert({
          'section_id': sectionId,
          'mahawer_id': mahawerId,
          'type': section.type,
          'sequence': section.sequence,
          'title': section.title,
          'text': section.text,
          'ayat': section.ayat,
        });

        for (var subSection in section.subSections ?? []) {
          final subSectionId = subSection.id;
          await Supabase.instance.client.from('sub_sections').insert({
            'sub_section_id': subSectionId,
            'section_id': sectionId,
            'type': subSection.type,
            'sequence': subSection.sequence,
            'text': subSection.text,
            'ayat': subSection.ayat,
            'conclusion': subSection.conclusion,
          });

          for (var topic in subSection.topics ?? []) {
            final topicId = topic.id;
            await Supabase.instance.client.from('topics').insert({
              'topic_id': topicId,
              'sub_section_id': subSectionId,
              'type': topic.type,
              'sequence': topic.sequence,
              'text': topic.text,
              'ayat': topic.ayat,
            });
          }
        }
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    bool canSave = !(tafsir == null || selectedTafsirId == null || isLoading);
    print(
      'Can save: $canSave, tafsir: ${tafsir != null}, selectedTafsirId: $selectedTafsirId, isLoading: $isLoading',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Tafsir Editor')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    key: const Key('tafsir_dropdown'),
                    value: selectedTafsirId,
                    hint: const Text('Select a Tafsir to Load'),
                    items: availableTafsirs.map((tafsir) {
                      return DropdownMenuItem<String>(
                        value: tafsir['tafsir_id'],
                        child: Text(
                          '${tafsir['title']} (${tafsir['surah_id']})',
                        ),
                      );
                    }).toList(),
                    onChanged: _onTafsirSelected,
                    decoration: const InputDecoration(
                      labelText: 'Available Tafsirs',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: tafsir == null
                      ? const Center(
                          child: Text(
                            'Select a tafsir or upload a PDF to start!',
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TreeSidebar(
                                surahName: tafsir!.surah.surahName,
                                mahawerList: tafsir!.mahawer,
                                onNodeSelected: _onNodeSelected,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: EditPanel(
                                selectedNode: selectedNode,
                                onNodeEdited: _onNodeEdited,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            key: const Key('upload_fab'),
            onPressed: isLoading ? null : _uploadPDF,
            child: const Icon(Icons.upload_file),
            tooltip: 'Upload PDF (Create New Tafsir)',
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              key: const Key('save_button'),
              onPressed: canSave
                  ? _saveTafsirToSupabase
                  : null, // Use canSave for debugging
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
