import 'package:flutter/material.dart';
import '../../services/user_campaign_service.dart';
import '../../widgets/unified_app_bar.dart';
import '../../../config/theme.dart';

class MyCampaignsPage extends StatefulWidget {
  const MyCampaignsPage({Key? key}) : super(key: key);

  @override
  State<MyCampaignsPage> createState() => _MyCampaignsPageState();
}

class _MyCampaignsPageState extends State<MyCampaignsPage> {
  List<Map<String, dynamic>> _campaignProgress = [];
  bool _isLoading = true;
  String _error = '';
  
  // Test için sabit kullanıcı ID'si (gerçek uygulamada auth sisteminden alınacak)
  final String _userId = 'test_user';

  @override
  void initState() {
    super.initState();
    _loadCampaignProgress();
  }

  Future<void> _loadCampaignProgress() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final progress = await UserCampaignService.getUserCampaignProgress(_userId);
      
      if (mounted) {
        setState(() {
          _campaignProgress = progress;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading campaign progress: $e');
      if (mounted) {
        setState(() {
          _error = 'Kampanya ilerlemesi yüklenirken hata oluştu';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _claimReward(String campaignId) async {
    try {
      await UserCampaignService.claimCampaignReward(_userId, campaignId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Ödülünüz başarıyla alındı!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCampaignProgress(); // Listeyi yenile
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCampaignCard(Map<String, dynamic> progress) {
    final campaignTitle = progress['campaign_title'] ?? 'Bilinmeyen Kampanya';
    final campaignDescription = progress['campaign_description'] ?? '';
    final currentCount = progress['current_count'] ?? 0;
    final requiredCount = progress['required_count'] ?? 1;
    final rewardCount = progress['reward_count'] ?? 1;
    final isCompleted = progress['is_completed'] ?? false;
    final completedAt = progress['completed_at'];
    final campaignId = progress['campaign_id'];
    final campaignType = progress['campaign_type'] ?? 'general';
    
    final progressPercentage = (currentCount / requiredCount).clamp(0.0, 1.0);
    final canClaimReward = isCompleted && completedAt == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kampanya başlığı
            Text(
              campaignTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181C2E),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Kampanya açıklaması
            if (campaignDescription.isNotEmpty)
              Text(
                campaignDescription,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // İlerleme çubuğu
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'İlerleme: $currentCount/$requiredCount',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB8835A),
                      ),
                    ),
                    Text(
                      '${(progressPercentage * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB8835A),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Progress bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8835A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Kampanya türüne göre özel bilgi
            if (campaignType == 'buy_x_get_y')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8835A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      color: Color(0xFFB8835A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$requiredCount adet al, $rewardCount adet hediye!',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB8835A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Durum ve aksiyon butonları
            Row(
              children: [
                // Durum göstergesi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? Colors.green.withOpacity(0.1)
                        : const Color(0xFFB8835A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.pending,
                        size: 16,
                        color: isCompleted ? Colors.green : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCompleted ? 'Tamamlandı' : 'Devam Ediyor',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? Colors.green : AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Ödül alma butonu
                if (canClaimReward)
                  ElevatedButton(
                    onPressed: () => _claimReward(campaignId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Ödülü Al',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                
                // Tamamlanma tarihi
                if (completedAt != null)
                  Text(
                    'Ödül alındı',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                children: [
                  // Back button ve başlık
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: AppTheme.cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppTheme.textColor,
                            size: 20,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      const Text(
                        'Geri',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Page Title
                  const Center(
                    child: Text(
                      'Kampanya Takibim',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontFamily: 'Sen',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    )
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
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadCampaignProgress,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Tekrar Dene'),
                              ),
                            ],
                          ),
                        )
                      : _campaignProgress.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.campaign_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Henüz aktif kampanya takibiniz bulunmuyor',
                                    style: TextStyle(color: Colors.grey[600]),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Kampanyaları Görüntüle'),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadCampaignProgress,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: _campaignProgress.length,
                                itemBuilder: (context, index) {
                                  return _buildCampaignCard(_campaignProgress[index]);
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