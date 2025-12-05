import 'package:flutter/material.dart';
import '../../domain/entities/mahawer.dart';
import '../../domain/entities/section.dart';
import '../../domain/entities/sub_section.dart';
import '../../domain/entities/topic.dart';

typedef NodeEditedCallback = void Function(dynamic updatedNode);

class EditPanel extends StatefulWidget {
  final dynamic selectedNode;
  final NodeEditedCallback onNodeEdited;

  const EditPanel({
    Key? key,
    required this.selectedNode,
    required this.onNodeEdited,
  }) : super(key: key);

  @override
  _EditPanelState createState() => _EditPanelState();
}

class _EditPanelState extends State<EditPanel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sequenceController;
  late TextEditingController _textController;
  late TextEditingController _ayatController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(covariant EditPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedNode != widget.selectedNode) {
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    if (widget.selectedNode == null) {
      _sequenceController = TextEditingController();
      _textController = TextEditingController();
      _ayatController = TextEditingController();
      return;
    }

    if (widget.selectedNode is Mahawer) {
      final node = widget.selectedNode as Mahawer;
      _sequenceController = TextEditingController(text: node.sequence);
      _textController = TextEditingController(text: node.text);
      _ayatController = TextEditingController(text: node.ayat?.join(', ') ?? '');
    } else if (widget.selectedNode is Section) {
      final node = widget.selectedNode as Section;
      _sequenceController = TextEditingController(text: node.sequence);
      _textController = TextEditingController(text: node.text);
      _ayatController = TextEditingController(text: node.ayat?.join(', ') ?? '');
    } else if (widget.selectedNode is SubSection) {
      final node = widget.selectedNode as SubSection;
      _sequenceController = TextEditingController(text: node.sequence);
      _textController = TextEditingController(text: node.text);
      _ayatController = TextEditingController(text: node.ayat?.join(', ') ?? '');
    } else if (widget.selectedNode is Topic) {
      final node = widget.selectedNode as Topic;
      _sequenceController = TextEditingController(text: node.sequence);
      _textController = TextEditingController(text: node.text);
      _ayatController = TextEditingController(text: node.ayat?.join(', ') ?? '');
    } else {
      _sequenceController = TextEditingController();
      _textController = TextEditingController();
      _ayatController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _sequenceController.dispose();
    _textController.dispose();
    _ayatController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    dynamic updatedNode;
    if (widget.selectedNode is Mahawer) {
      final node = widget.selectedNode as Mahawer;
      updatedNode = Mahawer(
        id: node.id,
        type: node.type,
        sequence: _sequenceController.text,
        title: node.title,
        text: _textController.text,
        ayat: _parseAyatList(_ayatController.text),
        isMuqadimah: node.isMuqadimah,
        sections: node.sections,
      );
    } else if (widget.selectedNode is Section) {
      final node = widget.selectedNode as Section;
      updatedNode = Section(
        id: node.id,
        type: node.type,
        sequence: _sequenceController.text,
        title: node.title,
        text: _textController.text,
        ayat: _parseAyatList(_ayatController.text),
        subSections: node.subSections,
      );
    } else if (widget.selectedNode is SubSection) {
      final node = widget.selectedNode as SubSection;
      updatedNode = SubSection(
        id: node.id,
        type: node.type,
        sequence: _sequenceController.text,
        text: _textController.text,
        ayat: _parseAyatList(_ayatController.text),
        conclusion: node.conclusion,
        topics: node.topics,
      );
    } else if (widget.selectedNode is Topic) {
      final node = widget.selectedNode as Topic;
      updatedNode = Topic(
        id: node.id,
        type: node.type,
        sequence: _sequenceController.text,
        text: _textController.text,
        ayat: _parseAyatList(_ayatController.text),
      );
    }

    widget.onNodeEdited(updatedNode);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes saved!')));
  }

  List<int>? _parseAyatList(String text) {
    if (text.trim().isEmpty) return null;
    try {
      return text.split(',').map((s) => int.parse(s.trim())).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid ayat format. Use comma-separated numbers.')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedNode == null) {
      return const Center(child: Text('Select a node from the tree to edit.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Editing: ${widget.selectedNode.runtimeType.toString()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sequenceController,
              decoration: const InputDecoration(labelText: 'Sequence'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Text'),
              maxLines: 3,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _ayatController,
              decoration: const InputDecoration(labelText: 'Ayat (comma-separated)'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => widget.onNodeEdited(null),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}