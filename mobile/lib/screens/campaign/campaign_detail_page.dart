import 'package:flutter/material.dart';
import '../../models/campaign_model.dart';
import '../../services/campaign_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool _isLoading = false;
  Campaign? _campaign;
  String _error = '';

  // Resim URL'ini tam adresle birleştirmek için yardımcı metod
  String _buildFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    
    if (imageUrl.startsWith('http')) {
      // URL zaten tam adres
      return imageUrl;
    } else if (imageUrl.startsWith('/public/')) {
      // Sunucu adresiyle birleştir
      return 'http://192.168.1.105:3001$imageUrl';
    } else {
      // Varsayılan olarak sunucu adresiyle birleştir
      return 'http://192.168.1.105:3001$imageUrl';
    }
  }

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
      final campaign = await CampaignService.getCampaignById(widget.campaign.id);
      
      if (mounted) {
        setState(() {
          _campaign = campaign;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Kampanya detay yükleme hatası: $e');
      if (mounted) {
        setState(() {
          _error = 'Kampanya detayları yüklenemedi';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaign = _campaign ?? widget.campaign;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: theme.colorScheme.secondary.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        _error,
                        style: TextStyle(color: theme.colorScheme.secondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadCampaignDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      height: 210,
                      decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7B4B2A), Color(0xFFD7A86E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: theme.cardColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.07),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    'Geri',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontFamily: 'Sen',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: Text(
                                  campaign.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontFamily: 'Sen',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content Section
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 26),
                            // Campaign Image
                            Container(
                              width: 340,
                              height: 180,
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      _buildFullImageUrl(campaign.imageUrl!),
                                      width: 340,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: theme.cardColor,
                                          child: Icon(Icons.image_not_supported, size: 50, color: theme.colorScheme.secondary),
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: theme.colorScheme.primary,
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: theme.cardColor,
                                      child: Icon(Icons.image_not_supported, size: 50, color: theme.colorScheme.secondary),
                                    ),
                            ),
                            const SizedBox(height: 26),
                            // Campaign Description
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                campaign.description ?? 'Açıklama bulunmamaktadır.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.onBackground,
                                  fontSize: 17,
                                  fontFamily: 'Sen',
                                  fontWeight: FontWeight.w400,
                                  height: 1.29,
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                            // Campaign Details (if available)
                            if (campaign.startDate != null || campaign.endDate != null)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.dividerColor,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kampanya Detayları',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 18,
                                        fontFamily: 'Sen',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    if (campaign.startDate != null)
                                      Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withOpacity(0.10),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.calendar_today,
                                              size: 18,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Başlangıç Tarihi',
                                                style: TextStyle(
                                                  color: theme.colorScheme.secondary,
                                                  fontSize: 14,
                                                  fontFamily: 'Sen',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Text(
                                                campaign.startDate.toString().substring(0, 10),
                                                style: TextStyle(
                                                  color: theme.colorScheme.onBackground,
                                                  fontSize: 16,
                                                  fontFamily: 'Sen',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    if (campaign.startDate != null && campaign.endDate != null)
                                      const SizedBox(height: 16),
                                    if (campaign.endDate != null)
                                      Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withOpacity(0.10),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.event,
                                              size: 18,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Bitiş Tarihi',
                                                style: TextStyle(
                                                  color: theme.colorScheme.secondary,
                                                  fontSize: 14,
                                                  fontFamily: 'Sen',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Text(
                                                campaign.endDate.toString().substring(0, 10),
                                                style: TextStyle(
                                                  color: theme.colorScheme.onBackground,
                                                  fontSize: 16,
                                                  fontFamily: 'Sen',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
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
                  ],
                ),
    );
  }
} 