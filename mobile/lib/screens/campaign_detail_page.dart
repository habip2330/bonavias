import 'package:flutter/material.dart';
import '../models/campaign_model.dart';
import '../services/database_service.dart';
import '../widgets/unified_app_bar.dart';

class CampaignDetailPage extends StatefulWidget {
  final Campaign campaign;

  const CampaignDetailPage({
    Key? key,
    required this.campaign,
  }) : super(key: key);

  @override
  State<CampaignDetailPage> createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  Campaign? _campaign;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadCampaignDetails();
  }

  Future<void> _loadCampaignDetails() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final campaign = await _databaseService.getCampaignById(widget.campaign.id);
      
      setState(() {
        _campaign = campaign;
        _isLoading = false;
      });
    } catch (e) {
      print('Kampanya detay yükleme hatası: $e');
      setState(() {
        _error = 'Kampanya detayları yüklenemedi';
        _isLoading = false;
      });
    }
  }

  // Image widget'ı oluşturmak için yardımcı metod
  Widget _buildCampaignImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
    
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final campaign = _campaign ?? widget.campaign;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top brown area
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFB8835A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F3F6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF181828)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Geri',
                          style: const TextStyle(
                            fontSize: 16, 
                            color: Color(0xFF181828),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      campaign.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              _error,
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              // Campaign image
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _buildCampaignImage(campaign.imageUrl),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Campaign description
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  campaign.description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Campaign dates
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB8835A).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFFB8835A),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Kampanya Tarihleri',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFB8835A),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${campaign.startDate.day}/${campaign.startDate.month}/${campaign.startDate.year} - ${campaign.endDate.day}/${campaign.endDate.month}/${campaign.endDate.year}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
} 