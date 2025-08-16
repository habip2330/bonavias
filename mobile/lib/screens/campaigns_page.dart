import 'package:flutter/material.dart';
import 'campaign_detail_page.dart';
import '../services/database_service.dart';
import '../services/campaign_service.dart';
import '../models/campaign_model.dart';
import '../../config/theme.dart';

class CampaignsPage extends StatefulWidget {
  const CampaignsPage({super.key});

  @override
  State<CampaignsPage> createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  List<Campaign> _campaigns = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      
      // CampaignService kullan - URL dönüştürme dahili olarak yapılıyor
      final campaigns = await CampaignService.getActiveCampaigns();
      print('🎯 Active campaigns from CampaignService: ${campaigns.length}');
      
      setState(() {
        _campaigns = campaigns;
        _isLoading = false;
      });
      
      print('✅ Final campaign models: ${_campaigns.length}');
      _campaigns.forEach((campaign) {
        print('📱 Campaign model: ${campaign.title} - Image: ${campaign.imageUrl}');
      });
    } catch (e) {
      print('Kampanya yükleme hatası: $e');
      setState(() {
        _error = 'Kampanyalar yüklenemedi';
        _isLoading = false;
      });
    }
  }

  // Image widget'ı oluşturmak için yardımcı metod
  Widget _buildCampaignImage(String? imageUrl) {
    print('🖼️ Campaign image check: "$imageUrl"');
    
    if (imageUrl == null || imageUrl.isEmpty) {
      print('❌ Campaign image URL is null or empty');
      return Container(
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
            SizedBox(height: 8),
            Text('Resim Yok', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }
    
    print('🖼️ Campaign image loading: $imageUrl');
    
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('❌ Campaign image load error for URL: $imageUrl');
        print('❌ Error details: $error');
        print('❌ Stack trace: $stackTrace');
        return Container(
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.broken_image, color: Colors.red, size: 40),
              SizedBox(height: 8),
              Text('Resim Yüklenemedi', style: TextStyle(color: Colors.red, fontSize: 10)),
            ],
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top brown area
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
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
                          color: AppTheme.cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Geri',
                        style: TextStyle(fontSize: 16, color: AppTheme.textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Kampanyalar',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Campaign list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error,
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _loadCampaigns,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Tekrar Dene'),
                              ),
                            ],
                          ),
                        )
                      : _campaigns.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.local_offer_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aktif kampanya bulunamadı',
                                    style: TextStyle(color: Colors.grey[600]),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadCampaigns,
                              color: AppTheme.primaryColor,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: _campaigns.length,
                                itemBuilder: (context, index) {
                                  final campaign = _campaigns[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 18),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CampaignDetailPage(campaign: campaign),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(16),
                                              ),
                                              child: AspectRatio(
                                                aspectRatio: 16 / 9,
                                                child: _buildCampaignImage(campaign.imageUrl),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    campaign.title,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF181828),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    campaign.description,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: AppTheme.primaryColor.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Text(
                                                          '${campaign.startDate.day}/${campaign.startDate.month}/${campaign.startDate.year} - ${campaign.endDate.day}/${campaign.endDate.month}/${campaign.endDate.year}',
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppTheme.primaryColor,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
} 