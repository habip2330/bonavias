import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';
import 'rate_branch_page.dart';
import '../home/home_page.dart';
import '../menu/menu_page.dart';
import '../profile/profile_page.dart';
import '../campaign/campaigns_page.dart';
import '../../services/branch_service.dart';
import '../../widgets/modern_ui_components.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  GoogleMapController? _mapController;
  final BranchService _branchService = BranchService();
  String _nearestBranchInfo = '';
  int _selectedNav = 2; // Branches is index 2

  @override
  void initState() {
    super.initState();
    _initializeBranchData();
    _startLocationTracking();
    
    // Sistem UI ayarları
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _initializeBranchData() async {
    // Eğer veriler zaten yüklendiyse, yeniden yükleme
    if (!_branchService.isInitialized && !_branchService.isLoading) {
      await _branchService.initializeBranches();
    }
    
    // State'i güncelle
    if (mounted) {
      setState(() {
        _updateNearestBranchInfo();
      });
    }
  }

  void _updateNearestBranchInfo() {
    final branches = _branchService.branches;
    final userPosition = _branchService.userPosition;
    
    print('🔍 Updating nearest branch info...');
    print('📍 User position: $userPosition');
    print('🏢 Branches count: ${branches?.length ?? 0}');
    
    if (branches != null && branches.isNotEmpty && userPosition != null) {
      // En yakın şubeyi bul (distance değeri olan)
      Map<String, dynamic>? nearestBranch;
      double? nearestDistance;
      
      for (var branch in branches) {
        final distance = branch['distance'] as double?;
        print('🏢 Branch: ${branch['name']}, Distance: $distance');
        if (distance != null && distance != double.infinity) {
          if (nearestBranch == null || distance < nearestDistance!) {
            nearestBranch = branch;
            nearestDistance = distance;
          }
        }
      }
      
      if (nearestBranch != null && nearestDistance != null) {
        _nearestBranchInfo = 'Size En yakın şube: ${nearestBranch['name']} (${_branchService.formatDistance(nearestDistance)})';
        print('✅ Nearest branch found: ${nearestBranch['name']} at ${_branchService.formatDistance(nearestDistance)}');
      } else {
        _nearestBranchInfo = 'Size En yakın şube: Konum bilgisi alınamadı';
        print('❌ No valid distance found for any branch');
      }
    } else {
      _nearestBranchInfo = '';
      print('❌ Missing data: branches=${branches?.length}, userPosition=$userPosition');
    }
  }

  void _startLocationTracking() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
      return;
    }
      _updateNearestBranchInfo();
    });
  }

  // Çalışma saatleri helper fonksiyonları
  String _getTodayWorkingHours(Map<String, dynamic> branch) {
    try {
      final workingHours = branch['working_hours'];
      
      if (workingHours == null) {
        return 'Bilinmiyor';
      }
      
      // Working hours JSON'ını parse et
      Map<String, dynamic> hours;
      if (workingHours is String) {
        hours = json.decode(workingHours);
      } else {
        hours = workingHours;
      }
      
      // Bugünün günü için çalışma saatini al
      final today = DateTime.now();
      final dayKey = _getDayKey(today.weekday);
      final todaySchedule = hours[dayKey];
      
      if (todaySchedule == null) {
        return 'Bilinmiyor';
      }
      
      final isOpen = todaySchedule['isOpen'] ?? false;
      if (!isOpen) {
        return 'Bugün Kapalı';
      }
      
      final openTime = todaySchedule['openTime'] ?? '';
      final closeTime = todaySchedule['closeTime'] ?? '';
      
      if (openTime.isEmpty || closeTime.isEmpty) {
        return 'Bilinmiyor';
      }
      
      // Eğer kapanış saati açılış saatinden küçükse (gece yarısından sonra kapanıyorsa)
      final openTimeParts = openTime.split(':');
      final closeTimeParts = closeTime.split(':');
      
      if (openTimeParts.length == 2 && closeTimeParts.length == 2) {
        final openHour = int.parse(openTimeParts[0]);
        final closeHour = int.parse(closeTimeParts[0]);
        
        if (closeHour < openHour) {
          // Gece yarısından sonra kapanıyorsa, kapanış saatini olduğu gibi göster (ör: 02:00)
          return '$openTime - $closeTime';
        }
      }
      
      return '$openTime - $closeTime';
    } catch (e) {
      print('❌ Working hours parse error: $e');
      return 'Bilinmiyor';
    }
  }
  
  String _getDayKey(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return 'monday';
    }
  }
  
  // Şubenin durumunu kontrol et (açık/kapalı)
  bool _isCurrentlyOpen(Map<String, dynamic> branch) {
    try {
      final workingHours = branch['working_hours'];
      if (workingHours == null) return false;
      
      Map<String, dynamic> hours;
      if (workingHours is String) {
        hours = json.decode(workingHours);
      } else {
        hours = workingHours;
      }
      
      final now = DateTime.now();
      final dayKey = _getDayKey(now.weekday);
      final todaySchedule = hours[dayKey];
      
      if (todaySchedule == null) return false;
      
      final isOpen = todaySchedule['isOpen'] ?? false;
      if (!isOpen) return false;
      
      final openTime = todaySchedule['openTime'] ?? '';
      final closeTime = todaySchedule['closeTime'] ?? '';
      
      if (openTime.isEmpty || closeTime.isEmpty) return false;
      
      // Şu anki saat ile çalışma saatlerini karşılaştır
      final currentTime = TimeOfDay.now();
      final openTimeParts = openTime.split(':');
      final closeTimeParts = closeTime.split(':');
      
      if (openTimeParts.length != 2 || closeTimeParts.length != 2) return false;
      
      final openTimeOfDay = TimeOfDay(
        hour: int.parse(openTimeParts[0]),
        minute: int.parse(openTimeParts[1]),
      );
      
      final closeTimeOfDay = TimeOfDay(
        hour: int.parse(closeTimeParts[0]),
        minute: int.parse(closeTimeParts[1]),
      );
      
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final openMinutes = openTimeOfDay.hour * 60 + openTimeOfDay.minute;
      final closeMinutes = closeTimeOfDay.hour * 60 + closeTimeOfDay.minute;
      
      // Eğer kapanış saati açılış saatinden küçükse (gece yarısından sonra kapanıyorsa)
      if (closeMinutes < openMinutes) {
        // Şu an açılış saatinden sonra VE kapanış saatinden önceyse açık
        return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
      } else {
        // Normal durum: açılış ve kapanış arasında
        return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
      }
    } catch (e) {
      print('❌ Is open check error: $e');
      return false;
    }
  }
  
  // Şube durumu rengini döndür
  Color _getBranchStatusColor(Map<String, dynamic> branch) {
    if (_isCurrentlyOpen(branch)) {
      return Colors.green; // Şube açıkken saat ve yazı rengi yeşil
    } else {
      return Theme.of(context).colorScheme.error ?? const Color(0xFFFF5722); // Kapalıysa mevcut renk
    }
  }
  
  // Şube durumu metnini döndür
  String _getBranchStatusText(Map<String, dynamic> branch) {
    final isOpen = _isCurrentlyOpen(branch);
    
    if (isOpen) {
      // Açıksa çalışma saatlerini göster
      return _getTodayWorkingHours(branch);
    } else {
      // Kapalıysa "Kapalı" yaz
      final workingHours = branch['working_hours'];
      if (workingHours == null) return 'Bilinmiyor';
      
      try {
        Map<String, dynamic> hours;
        if (workingHours is String) {
          hours = json.decode(workingHours);
        } else {
          hours = workingHours;
        }
        
        final now = DateTime.now();
        final dayKey = _getDayKey(now.weekday);
        final todaySchedule = hours[dayKey];
        
        if (todaySchedule == null) return 'Bilinmiyor';
        
        final isTodayOpen = todaySchedule['isOpen'] ?? false;
        if (!isTodayOpen) {
          return 'Bugün Kapalı';
        } else {
          // Bugün açık ama şu an kapalı - ne zaman açılacağını göster
          final openTime = todaySchedule['openTime'] ?? '';
          final closeTime = todaySchedule['closeTime'] ?? '';
          
          if (openTime.isNotEmpty && closeTime.isNotEmpty) {
            final currentTime = TimeOfDay.now();
            final openTimeParts = openTime.split(':');
            final closeTimeParts = closeTime.split(':');
            
            if (openTimeParts.length == 2 && closeTimeParts.length == 2) {
              final openHour = int.parse(openTimeParts[0]);
              final closeHour = int.parse(closeTimeParts[0]);
              final currentMinutes = currentTime.hour * 60 + currentTime.minute;
              final openMinutes = openHour * 60 + int.parse(openTimeParts[1]);
              final closeMinutes = closeHour * 60 + int.parse(closeTimeParts[1]);
              
              // Eğer gece yarısından sonra kapanıyorsa
              if (closeMinutes < openMinutes) {
                if (currentMinutes < openMinutes) {
                  return 'Açılış: $openTime';
                } else {
                  return 'Yarın açılacak';
                }
              } else {
                if (currentMinutes < openMinutes) {
                  return 'Açılış: $openTime';
                } else {
                  return 'Yarın açılacak';
                }
              }
            }
          }
          
          return 'Kapalı';
        }
      } catch (e) {
        return 'Bilinmiyor';
      }
    }
  }

  Future<void> _refreshData() async {
    _branchService.refreshData();
    await _initializeBranchData();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Eğer kullanıcı konumu varsa haritayı oraya odakla
    final userPosition = _branchService.userPosition;
    if (userPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(userPosition.latitude, userPosition.longitude),
            zoom: 12,
          ),
        ),
      );
    }
  }

  // Konumumu Bul butonuna basıldığında çalışacak fonksiyon
  Future<void> _centerOnUserLocation() async {
    final userPosition = _branchService.userPosition;
    
    if (userPosition != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(userPosition.latitude, userPosition.longitude),
            zoom: 15,
          ),
        ),
      );
    } else {
      // Konum servisini yeniden başlat
      await _branchService.getCurrentLocation();
      final newPosition = _branchService.userPosition;
      
      if (newPosition != null && _mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(newPosition.latitude, newPosition.longitude),
              zoom: 15,
            ),
          ),
        );
      } else {
        // Kullanıcıya konum servisi açması için uyarı göster
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Konum servisi açık değil. Lütfen konum servisini etkinleştirin.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _navigateToMenu() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MenuPage()),
    );
  }

  void _navigateToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  void _navigateToCampaigns() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CampaignsPage()),
    );
  }

  Widget _buildMapWidget() {
    final markers = _branchService.markers;
    final userPosition = _branchService.userPosition;
    
    return GoogleMap(
      mapType: MapType.normal,
                            initialCameraPosition: CameraPosition(
        target: userPosition != null 
            ? LatLng(userPosition.latitude, userPosition.longitude)
            : const LatLng(41.0082, 28.9784), // Istanbul default
                              zoom: 12,
                            ),
      onMapCreated: _onMapCreated,
      markers: markers ?? {},
                            myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
    );
  }

  Widget _buildBranchCard(Map<String, dynamic> branch) {
    final distance = branch['distance'] as double?;
    final distanceText = distance != null ? _branchService.formatDistance(distance) : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol: Büyük yuvarlak ikon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.location_on,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          // Sağ: Bilgiler ve butonlar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        (branch['name'] ?? 'BONAVİAS ŞUBE').toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Sen',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (distanceText.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          distanceText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  branch['address'] ?? '*** Sok. *** Cad. ***No',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Sen',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: _getBranchStatusColor(branch),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getBranchStatusText(branch),
                      style: TextStyle(
                        color: _getBranchStatusColor(branch),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Sen',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Sen'),
                      ),
                      onPressed: () async {
                        final branchName = branch['name'] ?? '';
                        final branchAddress = branch['address'] ?? '';
                        String searchQuery = '';
                        if (branchName.isNotEmpty && branchAddress.isNotEmpty) {
                          searchQuery = '$branchName $branchAddress';
                        } else if (branchName.isNotEmpty) {
                          searchQuery = branchName;
                        } else if (branchAddress.isNotEmpty) {
                          searchQuery = branchAddress;
                        }
                        if (searchQuery.isNotEmpty) {
                          final encodedQuery = Uri.encodeComponent(searchQuery);
                          final url = 'https://www.google.com/maps/search/?api=1&query=$encodedQuery';
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        } else {
                          final lat = branch['lat'];
                          final lng = branch['lng'];
                          if (lat != null && lng != null) {
                            final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
                            if (await canLaunch(url)) {
                              await launch(url);
                            }
                          }
                        }
                      },
                      child: const Text('Yol Tarifi'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Sen'),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => RateBranchWidget(
                            branchId: branch['id']?.toString() ?? '',
                            branchName: branch['name'] ?? 'Şube',
                          ),
                        );
                      },
                      child: const Text('Puan Ver'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _branchService.isLoading;
    final branches = _branchService.branches ?? [];
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Header with Map
          Container(
            width: 395,
            height: 295,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Stack(
              children: [
                // Map Background
                if (!isLoading) 
                  Positioned.fill(
                    child: _buildMapWidget(),
                  ),
                if (isLoading)
                  const Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(),
                ),
              ),



                // Konumumu Bul Butonu
                Positioned(
                  left: 24,
                  bottom: 24,
                  child: GestureDetector(
                    onTap: _centerOnUserLocation,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // Location markers with labels (from design)
                if (_branchService.branches != null && _branchService.branches!.isNotEmpty) ...[
                  // Current location marker
                ],
              ],
            ),
          ),
          
          // Branch List Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                if (_nearestBranchInfo.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                              child: Text(
                      _nearestBranchInfo,
                      style: TextStyle(
                                  fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onBackground,
                                  fontFamily: 'Sen',
                            ),
                          ),
                        ),
                        
                Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 15),
                  child: Text(
                    'Tüm Şubeler',
                                style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onBackground,
                                  fontFamily: 'Sen',
                                ),
                              ),
                            ),
                
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : branches.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Şube bulunamadı',
                                style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                  fontFamily: 'Sen',
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              itemCount: branches.length,
                              itemBuilder: (context, index) {
                                return _buildBranchCard(branches[index]);
                              },
                          ),
                        ),
                      ],
                ),
              ),
          ],
        ),
    );
  }
} 