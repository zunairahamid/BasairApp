// screens/tafsir_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/tafsir_viewmodel.dart';
import '../model/mahawer.dart';
import '../model/section.dart';

class TafsirScreen extends ConsumerStatefulWidget {
  final int surahId;
  
  const TafsirScreen({
    Key? key,
    required this.surahId,
  }) : super(key: key);

  @override
  ConsumerState<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends ConsumerState<TafsirScreen> {
  @override
  void initState() {
    super.initState();
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🎬 TAFSIR SCREEN INIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 Initialization Details:');
    print('   • Widget surahId: ${widget.surahId}');
    print('   • Widget key: ${widget.key}');
    print('   • HashCode: ${hashCode}');
    
    // Schedule the initialization after the current build frame
    Future.microtask(() {
      print('🔄 Scheduling tafsir initialization in microtask...');
      final notifier = ref.read(tafsirNotifierProvider.notifier);
      notifier.init(widget.surahId);
      print('✅ Initialization scheduled');
    });
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }

  @override
  void didUpdateWidget(TafsirScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔄 TAFSIR SCREEN DID UPDATE WIDGET');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 Update Details:');
    print('   • Old surahId: ${oldWidget.surahId}');
    print('   • New surahId: ${widget.surahId}');
    print('   • Changed: ${oldWidget.surahId != widget.surahId}');
    
    if (oldWidget.surahId != widget.surahId) {
      print('✅ Surah changed - reinitializing tafsir');
      
      // Schedule the re-initialization after the current build frame
      Future.microtask(() {
        print('🔄 Scheduling tafsir reinitialization in microtask...');
        final notifier = ref.read(tafsirNotifierProvider.notifier);
        notifier.init(widget.surahId);
        print('✅ Reinitialization scheduled');
      });
    } else {
      print('⚠️  No surah change - skipping reinitialization');
    }
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }

  @override
  Widget build(BuildContext context) {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🎨 TAFSIR SCREEN BUILD');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 Build Details:');
    print('   • Current surahId: ${widget.surahId}');
    print('   • Context mounted: ${context.mounted}');
    
    final state = ref.watch(tafsirNotifierProvider);
    final notifier = ref.read(tafsirNotifierProvider.notifier);
    
    print('📊 Current State:');
    print('   • Loading: ${state.isLoading}');
    print('   • Error: ${state.error ?? "null"}');
    print('   • Mahawer count: ${state.mahawer.length}');
    print('   • Current surah: ${state.currentSurahId}');
    print('   • Surah name: ${state.surahInfo['surahName']}');
    
    print('🔄 Building scaffold...');
    
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(state),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          if (widget.surahId == 4) // Only show refresh for Surah 4
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                print('🔄 Refresh button pressed for Surah 4');
                notifier.refresh(widget.surahId);
              },
            ),
        ],
      ),
      body: _buildBody(state, notifier),
    );
  }

  Widget _buildAppBarTitle(TafsirState state) {
    print('📱 Building app bar title...');
    
    final surahName = state.surahInfo['surahName'] ?? 'سورة ${widget.surahId}';
    final author = state.author;
    
    print('   • Surah name: $surahName');
    print('   • Author: ${author ?? "null"}');
    print('   • Showing author: ${author != null && widget.surahId == 4}');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$surahName - التفسير',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (author != null && widget.surahId == 4)
          Text(
            'تفسير: $author',
            style: const TextStyle(fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildBody(TafsirState state, TafsirNotifier notifier) {
    print('📱 Building body content...');
    print('   • Current surahId: ${widget.surahId}');
    print('   • Is Surah 4: ${widget.surahId == 4}');
    
    // For Surah 4 - IMMEDIATELY show tafsir data
    if (widget.surahId == 4) {
      print('✅ Showing Surah 4 tafsir content');
      return _buildSurah4Tafsir(state, notifier);
    }
    
    // For other surahs - show unavailable message
    print('⚠️  Showing unavailable message for non-Surah 4');
    return _buildOtherSurahMessage();
  }

  Widget _buildSurah4Tafsir(TafsirState state, TafsirNotifier notifier) {
    print('📱 Building Surah 4 tafsir view...');
    print('   • Publication info available: ${state.publicationInfo.isNotEmpty}');
    print('   • Mahawer count: ${state.mahawer.length}');
    
  return Column(
    children: [
      if (state.publicationInfo.isNotEmpty)
        _buildPublicationInfo(state),
      Expanded(
        child: _buildTafsirContent(state, notifier),
      ),
    ],
  );
}

Widget _buildTafsirContent(TafsirState state, TafsirNotifier notifier) {
    print('📱 Building tafsir content...');
    
    // ALWAYS show the actual tafsir data for Surah 4
    // The service guarantees immediate data for Surah 4
    
    if (state.mahawer.isEmpty) {
      print('⚠️  No mahawer data available - showing loading message');
      // This should never happen for Surah 4, but just in case
      return const Center(
        child: Text(
          'جاري تحميل تفسير سورة النساء...',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    
    print('✅ Showing ${state.mahawer.length} mahawer sections in ListView');
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.mahawer.length,
      itemBuilder: (context, index) {
        final mahawer = state.mahawer[index];
        print('   • Building mahawer [$index]: ${mahawer.title}');
        return _buildMahawerSection(mahawer, notifier);
      },
    );
  }

  Widget _buildOtherSurahMessage() {
    print('📱 Building other surah message...');
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Tafsir for other surahs coming soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tafsir Data for other surahs coming soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublicationInfo(TafsirState state) {
    print('📱 Building publication info card...');
    
    final publication = state.publicationInfo;
    print('   • Publication fields: ${publication.keys.join(', ')}');
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات النشر',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 8),
            if (publication['publisher'] != null)
              Text('الناشر: ${publication['publisher']}'),
            if (publication['year'] != null)
              Text('السنة: ${publication['year']}'),
            if (publication['location'] != null)
              Text('المكان: ${publication['location']}'),
            if (publication['isbn'] != null)
              Text('الرقم الدولي: ${publication['isbn']}'),
            if (publication['deposit_number'] != null)
              Text('رقم الإيداع: ${publication['deposit_number']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMahawerSection(Mahawer mahawer, TafsirNotifier notifier) {
    print('📱 Building mahawer section: ${mahawer.title}');
    print('   • Type: ${mahawer.type}');
    print('   • Ayat: ${mahawer.startAya}-${mahawer.endAya}');
    print('   • Sections: ${mahawer.sections.length}');
    print('   • IsMuqadimah: ${mahawer.isMuqadimah}');
    print('   • IsKhatimah: ${mahawer.isKhatimah}');
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    mahawer.type,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  mahawer.sequence,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (mahawer.isMuqadimah == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'المقدمة',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                if (mahawer.isKhatimah == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'الخاتمة',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.purple[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              mahawer.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'الآيات ${mahawer.startAya} - ${mahawer.endAya}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              mahawer.text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.right,
            ),
            
            const SizedBox(height: 16),
            
            _buildExplanationButton(
              mahawer.id, 
              mahawer.text, 
              mahawer.title, 
              notifier,
              isMahawer: true,
            ),
            
            _buildExplanation(mahawer.id),
            
            if (mahawer.sections.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'التفاصيل:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...mahawer.sections.map((section) => 
                _buildSubsection(section, mahawer.title, notifier)
              ).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubsection(Section section, String parentTitle, TafsirNotifier notifier) {
    print('   📱 Building subsection: ${section.title.isNotEmpty ? section.title : section.sequence}');
    print('     • Type: ${section.type}');
    print('     • Ayat: ${section.ayat}');
    print('     • Has conclusion: ${section.conclusion != null}');
    print('     • Sub-sections: ${section.subSections?.length ?? 0}');
    print('     • Cases: ${section.cases?.length ?? 0}');
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  section.type,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                section.sequence,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 6),
          
          if (section.title.isNotEmpty)
            Text(
              section.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          
          Text(
            section.text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
            textAlign: TextAlign.right,
          ),
          
          if (section.ayat.isNotEmpty && section.ayat.length >= 2)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'الآيات ${section.ayat[0]} - ${section.ayat[1]}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          
          if (section.conclusion != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange[100]!),
              ),
              child: Text(
                'الخلاصة: ${section.conclusion!}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange[800],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 8),
          
          _buildExplanationButton(
            section.id, 
            section.text, 
            '$parentTitle - ${section.title.isNotEmpty ? section.title : section.sequence}', 
            notifier,
          ),
          
          _buildExplanation(section.id),
          
          if (section.subSections != null && section.subSections!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...section.subSections!.map((subSection) => 
              _buildSubSubsection(subSection, '$parentTitle - ${section.sequence}', notifier)
            ).toList(),
          ],
          
          if (section.cases != null && section.cases!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...section.cases!.map((caseItem) => 
              _buildCaseItem(caseItem, '$parentTitle - ${section.sequence}', notifier)
            ).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSubSubsection(Section subSection, String parentTitle, TafsirNotifier notifier) {
    print('     📱 Building sub-subsection: ${subSection.sequence}');
    
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  subSection.type,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.purple[800],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                subSection.sequence,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Text(
            subSection.text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.3,
            ),
            textAlign: TextAlign.right,
          ),
          
          if (subSection.ayat.isNotEmpty && subSection.ayat.length >= 2)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'الآيات ${subSection.ayat[0]} - ${subSection.ayat[1]}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ),
          
          if (subSection.conclusion != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange[100]!),
              ),
              child: Text(
                'الخلاصة: ${subSection.conclusion!}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[800],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 6),
          
          _buildExplanationButton(
            subSection.id, 
            subSection.text, 
            '$parentTitle - ${subSection.sequence}', 
            notifier,
            isSmall: true,
          ),
          
          _buildExplanation(subSection.id),
          
          if (subSection.cases != null && subSection.cases!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...subSection.cases!.map((caseItem) => 
              _buildCaseItem(caseItem, '$parentTitle - ${subSection.sequence}', notifier)
            ).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildCaseItem(dynamic caseItem, String parentTitle, TafsirNotifier notifier) {
    final caseMap = caseItem as Map<String, dynamic>;
    final caseId = caseMap['id']?.toString() ?? 'case_${parentTitle}_${caseMap['sequence']}';
    final caseType = caseMap['type']?.toString() ?? 'case';
    final caseSequence = caseMap['sequence']?.toString() ?? '';
    final caseText = caseMap['text']?.toString() ?? '';
    
    print('       📱 Building case item: $caseSequence');
    
    return Container(
      margin: const EdgeInsets.only(top: 6, left: 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.teal[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.teal[100],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  caseType,
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.teal[800],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                caseSequence,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Text(
            caseText,
            style: const TextStyle(
              fontSize: 13,
              height: 1.2,
            ),
            textAlign: TextAlign.right,
          ),
          
          const SizedBox(height: 4),
          
          _buildExplanationButton(
            caseId, 
            caseText, 
            '$parentTitle - $caseSequence', 
            notifier,
            isSmall: true,
          ),
          
          _buildExplanation(caseId),
        ],
      ),
    );
  }

  Widget _buildExplanationButton(
    String sectionId, 
    String text, 
    String context, 
    TafsirNotifier notifier, {
    bool isMahawer = false,
    bool isSmall = false,
  }) {
    print('       📱 Building explanation button for section: $sectionId');
    print('         • Text length: ${text.length}');
    print('         • Context: $context');
    print('         • Is mahawer: $isMahawer');
    print('         • Is small: $isSmall');
    
    return Consumer(
      builder: (buildContext, ref, child) {
        final isExplaining = ref.watch(sectionLoadingProvider(sectionId));
        final hasExplanation = ref.watch(sectionExplanationProvider(sectionId)) != null;
        
        print('         • Is explaining: $isExplaining');
        print('         • Has explanation: $hasExplanation');
        
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isExplaining ? null : () {
              if (hasExplanation) {
                print('         📱 Button pressed: Clear explanation for $sectionId');
                notifier.clearExplanation(sectionId);
              } else {
                print('         📱 Button pressed: Request AI explanation for $sectionId');
                notifier.explainSection(sectionId, text, context: context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: hasExplanation 
                  ? (isMahawer ? Colors.orange : Colors.blue)
                  : Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isSmall ? 8 : 12),
            ),
            child: isExplaining
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: isSmall ? 16 : 20,
                        height: isSmall ? 16 : 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: isSmall ? 8 : 12),
                      Text(isSmall ? 'جاري التفسير...' : 'جاري توليد التفسير...'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(hasExplanation ? Icons.visibility_off : Icons.auto_awesome, 
                          size: isSmall ? 16 : 20),
                      SizedBox(width: isSmall ? 4 : 8),
                      Text(hasExplanation 
                          ? (isSmall ? 'إخفاء' : 'إخفاء التفسير')
                          : (isSmall ? 'تفسير بالذكاء' : 'الحصول على تفسير بالذكاء الاصطناعي')),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildExplanation(String sectionId) {
    print('       📱 Building explanation widget for section: $sectionId');
    
    return Consumer(
      builder: (context, ref, child) {
        final isExplaining = ref.watch(sectionLoadingProvider(sectionId));
        final explanation = ref.watch(sectionExplanationProvider(sectionId));
        
        print('         • Is explaining: $isExplaining');
        print('         • Has explanation: ${explanation != null}');
        
        if (isExplaining) {
          print('         • Showing loading indicator');
          return const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Column(
              children: [
                LinearProgressIndicator(),
                SizedBox(height: 8),
                Text(
                  'جاري تحليل النص وتوليد التفسير...',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        if (explanation != null) {
          print('         • Showing AI explanation');
          print('         • Explanation length: ${explanation.length}');
          
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🤖 تفسير بالذكاء الاصطناعي:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Text(
                    explanation,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }
        
        print('         • No explanation to show');
        return const SizedBox();
      },
    );
  }
}

// Helper function
int min(int a, int b) => a < b ? a : b;