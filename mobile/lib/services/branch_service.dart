import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class BranchService {
  static final BranchService _instance = BranchService._internal();
  factory BranchService() => _instance;
  BranchService._internal();

  List<Map<String, dynamic>>? _branches;
  Position? _userPosition;
  Set<Marker>? _markers;
  bool _isInitialized = false;
  bool _isLoading = false;

  List<Map<String, dynamic>>? get branches => _branches;
  Position? get userPosition => _userPosition;
  Set<Marker>? get markers => _markers;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  Future<List<Map<String, dynamic>>> getBranches() async {
    if (!_isInitialized) {
      await initializeBranches();
    }
    return _branches ?? [];
  }

  Future<void> initializeBranches() async {
    if (_isInitialized || _isLoading) return;
    
    _isLoading = true;
    
    try {
      // Kullanıcı konumunu al
      await _getUserLocation();
      
      // Şube verilerini yükle
      await _loadBranchesFromAPI();
      
      // Marker'ları oluştur
      _createMarkers();
      
      _isInitialized = true;
    } catch (e) {
      print('Branch initialization error: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _getUserLocation() async {
    try {
      // Kullanıcının daha önce konum izni kararını kontrol et
      final prefs = await SharedPreferences.getInstance();
      final hasAskedPermission = prefs.getBool('has_asked_location_permission') ?? false;
      final permissionDenied = prefs.getBool('location_permission_denied') ?? false;
      
      // Eğer kullanıcı daha önce kalıcı olarak reddetmişse, tekrar sorma
      if (permissionDenied && hasAskedPermission) {
        print('📍 Konum izni daha önce reddedilmiş, tekrar sorulmuyor');
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('📍 Konum servisi devre dışı');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      // Eğer ilk kez soruyorsak veya denied durumundaysa
      if (permission == LocationPermission.denied && !hasAskedPermission) {
        print('📍 Konum izni isteniyor...');
        permission = await Geolocator.requestPermission();
        
        // Kullanıcının kararını kaydet
        await prefs.setBool('has_asked_location_permission', true);
        
        if (permission == LocationPermission.denied || 
            permission == LocationPermission.deniedForever) {
          await prefs.setBool('location_permission_denied', true);
          print('📍 Konum izni reddedildi ve kaydedildi');
        } else {
          await prefs.setBool('location_permission_denied', false);
          print('📍 Konum izni verildi ve kaydedildi');
        }
      }

      // Kalıcı red durumunda
      if (permission == LocationPermission.deniedForever) {
        await prefs.setBool('location_permission_denied', true);
        print('📍 Konum izni kalıcı olarak reddedildi');
        return;
      }

      // İzin verilmişse konumu al
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        _userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        print('📍 Kullanıcı konumu alındı: ${_userPosition?.latitude}, ${_userPosition?.longitude}');
      }
    } catch (e) {
      print('❌ Konum hatası: $e');
    }
  }

  Future<void> _loadBranchesFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/branches')
      );
      
      if (response.statusCode != 200) {
        throw Exception('Şubeler yüklenemedi');
      }
      
      final List<dynamic> data = json.decode(response.body);
      
      List<Map<String, dynamic>> branches = data.map((item) => {
        'id': item['id'],
        'name': item['name'],
        'address': item['address'],
        'lat': item['latitude'],
        'lng': item['longitude'],
        'phone': item['phone'],
        'isActive': item['is_active'] ?? true,
        'working_hours': item['working_hours'], // Çalışma saatleri eklendi
      }).toList();

      // Mesafe hesapla (eğer kullanıcı konumu varsa)
      if (_userPosition != null) {
        print('📍 Calculating distances for ${branches.length} branches...');
        print('📍 User position: ${_userPosition!.latitude}, ${_userPosition!.longitude}');
        
        for (var branch in branches) {
          final lat = branch['lat'];
          final lng = branch['lng'];
          if (lat != null && lng != null) {
            final distance = Geolocator.distanceBetween(
              _userPosition!.latitude,
              _userPosition!.longitude,
              lat,
              lng,
            );
            branch['distance'] = distance;
            print('🏢 ${branch['name']}: ${formatDistance(distance)}');
          } else {
            branch['distance'] = double.infinity;
            print('🏢 ${branch['name']}: No coordinates');
          }
        }
        
        // Mesafeye göre sırala
        branches.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
        print('✅ Branches sorted by distance');
      } else {
        print('❌ No user position available for distance calculation');
      }

      _branches = branches;
    } catch (e) {
      print('API loading error: $e');
      _branches = [];
    }
  }

  void _createMarkers() {
    if (_branches == null) return;
    
    Set<Marker> markers = {};
    
    // Şube marker'ları
    for (int i = 0; i < _branches!.length; i++) {
      final branch = _branches![i];
      final lat = branch['lat'];
      final lng = branch['lng'];
      
      if (lat != null && lng != null) {
        markers.add(
          Marker(
            markerId: MarkerId('branch_${branch['id']}'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: branch['name'],
              snippet: branch['address'],
            ),
          ),
        );
      }
    }
    
    _markers = markers;
  }

  void refreshData() {
    _isInitialized = false;
    _branches = null;
    _userPosition = null;
    _markers = null;
  }

  String formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.round()} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  // Konum izni tercihlerini sıfırla (kullanıcı fikrini değiştirmek isterse)
  static Future<void> resetLocationPermissionPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('has_asked_location_permission');
      await prefs.remove('location_permission_denied');
      print('📍 Konum izni tercihleri sıfırlandı');
    } catch (e) {
      print('❌ Konum izni tercihleri sıfırlanırken hata: $e');
    }
  }

  // Public metod - "Konumumu Bul" butonu için
  Future<void> getCurrentLocation() async {
    await _getUserLocation();
    // Konum güncellendiğinde şube mesafelerini yeniden hesapla
    if (_branches != null && _userPosition != null) {
      for (var branch in _branches!) {
        final lat = branch['lat'];
        final lng = branch['lng'];
        if (lat != null && lng != null) {
          branch['distance'] = Geolocator.distanceBetween(
            _userPosition!.latitude,
            _userPosition!.longitude,
            lat,
            lng,
          );
        }
      }
      // Mesafeye göre yeniden sırala
      _branches!.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    }
  }
} 