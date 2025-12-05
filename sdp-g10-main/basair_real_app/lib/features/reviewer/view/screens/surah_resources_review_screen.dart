import 'dart:convert';
import 'package:basair_real_app/core/models/resource_link.dart';
import 'package:basair_real_app/features/resource_viewer/view/image_viewer_screen.dart';
import 'package:basair_real_app/features/resource_viewer/view/pdf_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

enum ReviewFilter {
  alreadyReviewed,
  notReviewed,
}

class SurahResourcesReviewScreen extends StatefulWidget {
  final int surahId;
  final String surahName;

  const SurahResourcesReviewScreen({
    super.key,
    required this.surahId,
    required this.surahName,
  });

  @override
  State<SurahResourcesReviewScreen> createState() =>
      _SurahResourcesReviewScreenState();
}

class _SurahResourcesReviewScreenState
    extends State<SurahResourcesReviewScreen> {
  ReviewFilter _currentFilter = ReviewFilter.alreadyReviewed;
  bool _isLoading = true;
  final List<ResourceLink> _resources = [];

  @override
  void initState() {
    super.initState();
    _loadResourcesForSurah();
  }

  Future<void> _loadResourcesForSurah() async {
    final pad2 = widget.surahId.toString().padLeft(2, '0');
    final List<ResourceLink> loaded = [];

    // 1) YouTube links
    try {
      final youtubeData = await rootBundle.loadString(
        'assets/data/resources/youtubelinks/youtube_links$pad2.json',
      );
      final jsonYoutube = json.decode(youtubeData);
      final links = (jsonYoutube['links'] as List<dynamic>? ?? [])
          .map((e) => ResourceLink.fromJson(e as Map<String, dynamic>))
          .toList();
      loaded.addAll(links);
    } catch (e) {
      debugPrint('No YouTube resources for surah $pad2: $e');
    }

    // 2) PDF links
    try {
      final pdfData = await rootBundle.loadString(
        'assets/data/resources/pdfs/pdf_links$pad2.json',
      );
      final jsonPdf = json.decode(pdfData);
      final links = (jsonPdf['links'] as List<dynamic>? ?? [])
          .map((e) => ResourceLink.fromJson(e as Map<String, dynamic>))
          .toList();
      loaded.addAll(links);
    } catch (e) {
      debugPrint('No PDF resources for surah $pad2: $e');
    }

    // 3) Image links
    try {
      final imgData = await rootBundle.loadString(
        'assets/data/resources/images/image_links$pad2.json',
      );
      final jsonImg = json.decode(imgData);
      final links = (jsonImg['links'] as List<dynamic>? ?? [])
          .map((e) => ResourceLink.fromJson(e as Map<String, dynamic>))
          .toList();
      loaded.addAll(links);
    } catch (e) {
      debugPrint('No IMAGE resources for surah $pad2: $e');
    }

    if (!mounted) return;
    setState(() {
      _resources
        ..clear()
        ..addAll(loaded);
      _isLoading = false;
    });
  }

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  void _openResource(ResourceLink res) {
    switch (res.kind) {
      case 'pdf':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(
              assetPath: res.url,
              title: res.label ?? 'PDF',
              initialPage: res.page ?? 1,
            ),
          ),
        );
        break;
      case 'image':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewerScreen(
              assetPath: res.url,
              title: res.label,
            ),
          ),
        );
        break;
      case 'video':
      case 'website':
        _launchExternalUrl(res.url);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported resource type')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey('surah_resources_screen_4'),
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.indigo[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Assalam O Alaikum',
                      style: TextStyle(
                        letterSpacing: 1.5,
                        color: Colors.black,
                        fontFamily: 'Lato',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Reviewer – ${widget.surahName}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontFamily: 'CrimsonText',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<ReviewFilter>(
                onSelected: (value) {
                  setState(() {
                    _currentFilter = value;
                  });
                },
                color: Colors.indigo[100],
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                icon: const Icon(
                  Icons.filter_list_rounded,
                  color: Colors.black,
                ),
                offset: const Offset(0, 50),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: ReviewFilter.alreadyReviewed,
                    child: Text(
                      'Already reviewed',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: ReviewFilter.notReviewed,
                    child: Text(
                      'Not reviewed',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentFilter == ReviewFilter.notReviewed
                    ? const Center(
                        child: Text(
                          'NO RESOURCES WERE SUBMITTED YET',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'CrimsonText',
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _resources.isEmpty
                        ? const Center(
                            child: Text(
                              'No resources submitted yet for this surah.',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'CrimsonText',
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _resources.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final res = _resources[index];
                              return _resourceCard(res);
                            },
                          ),
          ),
        ),
      ),
    );
  }

  // One card per submitted resource
  Widget _resourceCard(ResourceLink res) {
    final iconData = _iconForKind(res.kind);
    final iconColor = _colorForKind(res.kind);

    return Card(
      color: const Color.fromARGB(255, 173, 181, 223),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openResource(res),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(iconData, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      res.label ?? res.url,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lato',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Type: ${res.kind}  •  Linked node: ${res.nodeId}'
                      '${res.page != null ? '  •  Page: ${res.page}' : ''}'
                      '${res.start != null ? '  •  Start: ${res.start}s' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'CrimsonText',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Remove resource?'),
                              content: Text(
                                'Are you sure you want to remove\n"${res.label ?? res.url}" from this review list?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'Remove',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && mounted) {
                            setState(() {
                              _resources.remove(res);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Resource removed from list'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Remove',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForKind(String kind) {
    switch (kind) {
      case 'video':
        return Icons.play_circle_fill;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
        return Icons.image;
      case 'website':
        return Icons.link;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _colorForKind(String kind) {
    switch (kind) {
      case 'video':
        return Colors.redAccent;
      case 'pdf':
        return Colors.red;
      case 'image':
        return Colors.green;
      case 'website':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}
