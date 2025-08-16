import 'package:flutter/material.dart';
import '../../models/campaign_model.dart';
import '../../services/campaign_service.dart';
import '../../services/user_campaign_service.dart';
import 'campaign_detail_page.dart';

class CampaignsPage extends StatefulWidget {
  const CampaignsPage({Key? key}) : super(key: key);

  @override
  State<CampaignsPage> createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  List<Campaign> _campaigns = [];
  bool _isLoading = true;
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
      
      final campaigns = await CampaignService.getActiveCampaigns();
      
      if (mounted) {
        setState(() {
          _campaigns = campaigns;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading campaigns: $e');
      if (mounted) {
        setState(() {
          _error = 'Kampanyalar yüklenirken bir hata oluştu';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToMyCampaigns() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyCampaignsPage(),
      ),
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampaignDetailPage(campaign: campaign),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Background image or placeholder
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[300],
                  child: campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty
                      ? Image.network(
                          campaign.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 32,
                          ),
                        ),
                ),
                
                // Gradient overlay for text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                
                // Campaign title and description
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (campaign.description != null && campaign.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            campaign.description!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            height: 222,
            decoration: const BoxDecoration(
              color: Color(0xFFBC8157),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Header Row
                    Row(
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                              color: Color(0xFFECF0F4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Color(0xFF181C2E),
                              size: 20,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 20),
                        
                        // Geri Text
                        const Text(
                          'Geri',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Kampanya Takibim Button
                        GestureDetector(
                          onTap: _navigateToMyCampaigns,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.track_changes,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Takibim',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Page Title - Centered
                    Center(
                      child: Text(
                        'Kampanyalar',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFB8835A),
                    ),
                  )
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
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
                                backgroundColor: const Color(0xFFB8835A),
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
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.campaign_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Aktif kampanya bulunmuyor',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadCampaigns,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _campaigns.length,
                              itemBuilder: (context, index) {
                                return _buildCampaignCard(_campaigns[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class MyCampaignsPage extends StatefulWidget {
  const MyCampaignsPage({Key? key}) : super(key: key);

  @override
  State<MyCampaignsPage> createState() => _MyCampaignsPageState();
}

class _MyCampaignsPageState extends State<MyCampaignsPage> {
  List<Map<String, dynamic>> _campaignProgress = [];
  bool _isLoading = true;
  String _error = '';
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
          const SnackBar(content: Text('🎉 Ödülünüz başarıyla alındı!')),
        );
        _loadCampaignProgress();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Hata: $e')),
        );
      }
    }
  }

  Widget _buildCampaignCard(Map<String, dynamic> progress) {
    final campaignTitle = progress['campaign_title'] ?? 'Bilinmeyen Kampanya';
    final currentCount = progress['current_count'] ?? 0;
    final requiredCount = progress['required_count'] ?? 1;
    final isCompleted = progress['is_completed'] ?? false;
    final completedAt = progress['completed_at'];
    final campaignId = progress['campaign_id'];
    
    final progressPercentage = (currentCount / requiredCount).clamp(0.0, 1.0);
    final canClaimReward = isCompleted && completedAt == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            Text(
              campaignTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181C2E),
              ),
            ),
            
            const SizedBox(height: 16),
            
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
            
            const SizedBox(height: 16),
            
            Row(
              children: [
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
                        color: isCompleted ? Colors.green : const Color(0xFFB8835A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCompleted ? 'Tamamlandı' : 'Devam Ediyor',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? Colors.green : const Color(0xFFB8835A),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                if (canClaimReward)
                  ElevatedButton(
                    onPressed: () => _claimReward(campaignId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8835A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Ödülü Al'),
                  ),
                
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFB8835A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: Color(0xFFECF0F4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xFF181C2E),
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
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Kampanya Takibim',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(child: Text(_error))
                      : _campaignProgress.isEmpty
                          ? const Center(child: Text('Henüz kampanya takibiniz yok'))
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

