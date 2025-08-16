import 'package:flutter/material.dart';
import '../services/database_service.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchTerm;
  const SearchResultsPage({Key? key, required this.searchTerm}) : super(key: key);

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _campaigns = [];

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final results = await _databaseService.search(widget.searchTerm);
      
      setState(() {
        _products = results['products'] ?? [];
        _categories = results['categories'] ?? [];
        _campaigns = results['campaigns'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Arama hatası: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFB8835A),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F3F6),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFFB6B6C2)),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Aranan Öğe : ${widget.searchTerm}',
                              style: const TextStyle(fontSize: 18, color: Color(0xFF181828)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Products
                      if (_products.isNotEmpty) ...[
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 18,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.95,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 12),
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade300,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: product['image_url'] != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: Image.network(
                                              product['image_url'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Icon(Icons.image_not_supported, color: Colors.grey);
                                              },
                                            ),
                                          )
                                        : const Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    product['title'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF181828),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product['subtitle'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFB8835A),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Categories
                      if (_categories.isNotEmpty) ...[
                        const Text('Kategori', style: TextStyle(fontSize: 16, color: Color(0xFF181828), fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        ..._categories.map((cat) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cat['name'] ?? '',
                              style: const TextStyle(fontSize: 20, color: Color(0xFF181828), fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                      ],
                      // Campaigns
                      if (_campaigns.isNotEmpty) ...[
                        const Text('Kampanyalar', style: TextStyle(fontSize: 16, color: Color(0xFF181828), fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        ..._campaigns.map((camp) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              camp['name'] ?? '',
                              style: const TextStyle(fontSize: 20, color: Color(0xFFB8835A), fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                      ],
                      if (_products.isEmpty && _categories.isEmpty && _campaigns.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.search_off_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Sonuç bulunamadı',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
} 