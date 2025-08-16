import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../widgets/unified_app_bar.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _faqs = [];
  List<bool> _expandedItems = [];

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    try {
      final faqs = await _databaseService.getActiveFaqs();

      if (mounted) {
        setState(() {
          _faqs = faqs;
          _expandedItems = List.generate(faqs.length, (_) => false);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('SSS yükleme hatası: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            UnifiedAppBar(
              title: 'Sıkça Sorulan Sorular',
            ),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFBC8157),
                      ),
                    )
                  : _faqs.isEmpty
                      ? _buildEmptyState()
                      : _buildFaqList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline,
              size: 64,
              color: Color(0xFFBC8157),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz soru bulunmuyor',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Çok yakında burada sorular olacak',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _faqs.length,
      itemBuilder: (context, index) {
        final faq = _faqs[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expandedItems[index] = expanded;
                  });
                },
                initiallyExpanded: _expandedItems[index],
                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding: EdgeInsets.zero,
                title: Text(
                  faq['question'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                trailing: AnimatedRotation(
                  turns: _expandedItems[index] ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _expandedItems[index] 
                          ? const Color(0xFFBC8157).withOpacity(0.1)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      faq['answer'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.6,
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
  }
} 