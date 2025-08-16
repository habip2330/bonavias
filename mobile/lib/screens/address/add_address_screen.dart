import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({Key? key}) : super(key: key);

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _addressTitleController = TextEditingController();
  
  LatLng _currentLocation = const LatLng(41.0082, 28.9784); // Istanbul default
  Set<Marker> _markers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // _getCurrentLocation(); // Map hazır olduğunda çağrılacak
  }

  @override
  void dispose() {
    _addressController.dispose();
    _neighborhoodController.dispose();
    _postalCodeController.dispose();
    _apartmentController.dispose();
    _addressTitleController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Konum servisinin açık olup olmadığını kontrol et
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konum servisleri kapalı. Lütfen GPS\'i açınız.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Konum iznini kontrol et
      final prefs = await SharedPreferences.getInstance();
      final hasAskedPermission = prefs.getBool('has_asked_location_permission') ?? false;
      final permissionDenied = prefs.getBool('location_permission_denied') ?? false;
      
      // Eğer kullanıcı daha önce kalıcı olarak reddetmişse, tekrar sorma
      if (permissionDenied && hasAskedPermission) {
        _showModernSnackBar(context, 'Konum izni daha önce reddedilmiş. Manuel olarak adres girebilirsiniz.', isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      // Eğer ilk kez soruyorsak veya denied durumundaysa
      if (permission == LocationPermission.denied && !hasAskedPermission) {
        permission = await Geolocator.requestPermission();
        
        // Kullanıcının kararını kaydet
        await prefs.setBool('has_asked_location_permission', true);
        
        if (permission == LocationPermission.denied) {
          await prefs.setBool('location_permission_denied', true);
          _showModernSnackBar(context, 'Konum izni reddedildi. Manuel olarak adres girebilirsiniz.', isError: true);
          setState(() {
            _isLoading = false;
          });
          return;
          } else {
          await prefs.setBool('location_permission_denied', false);
        }
      } else if (permission == LocationPermission.denied) {
        // Daha önce reddedilmişse tekrar sorma
        _showModernSnackBar(context, 'Konum izni reddedilmiş. Manuel olarak adres girebilirsiniz.', isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        await prefs.setBool('location_permission_denied', true);
        _showModernSnackBar(context, 'Konum izni kalıcı olarak reddedildi. Ayarlardan izin verebilir veya manuel olarak adres girebilirsiniz.', isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Debug: Mevcut konum
      print('Mevcut konum: ${_currentLocation.latitude}, ${_currentLocation.longitude}');

      // Konumu al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      LatLng newLocation = LatLng(position.latitude, position.longitude);
      
      print('Yeni konum: ${newLocation.latitude}, ${newLocation.longitude}');
      print('Map controller null mu: ${_mapController == null}');
      
      setState(() {
        _currentLocation = newLocation;
      });
      
      // Haritayı yeni konuma götür - Controller kontrolü
      if (_mapController != null) {
        print('Harita kamerası güncelleniyor...');
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newLocation,
              zoom: 14.0, 
            ),
          ),
        );
        print('Harita kamerası güncellendi');
        } else {
        print('Map controller henüz hazır değil!');
        // Controller hazır değilse kısa bir süre bekleyip tekrar dene
        await Future.delayed(const Duration(milliseconds: 500));
        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: newLocation,
                zoom: 14.0, 
              ),
            ),
          );
        }
      }

      // Location found notification removed - no notification needed

    } catch (e) {
      print('Konum alınamadı: $e');
      _showModernSnackBar(context, 'Konum alınamadı: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _currentLocation = position;
      // Marker'ları tamamen kaldır - sadece Google'ın mavi noktası kalsın
      _markers.clear();
    });
  }

  Future<void> _searchAddress() async {
    if (_addressController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      String fullAddress = '${_addressController.text}, ${_neighborhoodController.text}, Turkey';
      List<Location> locations = await locationFromAddress(fullAddress);
      
      if (locations.isNotEmpty) {
        LatLng newLocation = LatLng(locations.first.latitude, locations.first.longitude);
        
        setState(() {
          _currentLocation = newLocation;
          _updateMarker(newLocation);
        });
        
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: newLocation,
                zoom: 10.0, // Uygun zoom seviyesi
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Adres bulunamadı: $e');
      _showModernSnackBar(context, 'Adres bulunamadı. Lütfen geçerli bir adres giriniz.', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAddress() async {
    // Tüm alanların dolu olup olmadığını kontrol et
    if (_addressController.text.isEmpty ||
        _neighborhoodController.text.isEmpty ||
        _addressTitleController.text.isEmpty) {
      _showModernSnackBar(context, 'Lütfen tüm zorunlu alanları doldurunuz.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .add({
          'title': _addressTitleController.text,
          'address': _addressController.text,
          'neighborhood': _neighborhoodController.text,
          'postalCode': _postalCodeController.text,
          'apartmentNo': _apartmentController.text,
          'latitude': _currentLocation.latitude,
          'longitude': _currentLocation.longitude,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        _showModernSnackBar(context, 'Adres başarıyla kaydedildi!', isSuccess: true);
        
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      _showModernSnackBar(context, 'Adres kaydedilirken bir hata oluştu: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _debugLocationInfo() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      
      String message = '''
Debug Bilgileri:
- GPS Servisi: ${serviceEnabled ? 'Açık' : 'Kapalı'}
- İzin Durumu: ${_getPermissionText(permission)}
      ''';
      
      _showModernSnackBar(context, message);
    } catch (e) {
      _showModernSnackBar(context, 'Debug hatası: $e', isError: true);
    }
  }

  String _getPermissionText(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return 'Reddedildi';
      case LocationPermission.deniedForever:
        return 'Kalıcı Reddedildi';
      case LocationPermission.whileInUse:
        return 'Uygulama Kullanımda';
      case LocationPermission.always:
        return 'Her Zaman';
      default:
        return 'Bilinmiyor';
    }
  }

  void _showModernSnackBar(BuildContext context, String message, {bool isError = false, bool isSuccess = false}) {
    IconData icon;
    Color backgroundColor;
    
    if (isError) {
      icon = Icons.error_outline;
      backgroundColor = const Color(0xFFE74C3C);
    } else if (isSuccess) {
      icon = Icons.check_circle_outline;
      backgroundColor = const Color(0xFFBC8157);
        } else {
      icon = Icons.info_outline;
      backgroundColor = const Color(0xFF6C757D);
    }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 3),
        elevation: 4,
      ),
    );
  }

  void _showModernDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFE74C3C),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF32343E),
                    fontSize: 18,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                            Text(
                  content,
                  style: const TextStyle(
                    color: Color(0xFF6C757D),
                                fontSize: 14,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF8F9FA),
                          foregroundColor: const Color(0xFF6C757D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'İptal',
                          style: TextStyle(
                            fontFamily: 'Sen',
                                fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onConfirm();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFE74C3C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sil',
                          style: TextStyle(
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
          children: [
          // Google Maps Section - Sadece form üstündeki alan
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: MediaQuery.of(context).size.height * 0.6, // Form yüksekliği kadar boşluk bırak
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                print('Google Map controller hazır!');
                // Map yüklendikten sonra mevcut konumu al
                Future.delayed(const Duration(milliseconds: 1000), () {
                  if (mounted) {
                    _getCurrentLocation();
                  }
                });
              },
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 10.0, // Daha geniş başlangıç görünümü
              ),
              markers: _markers,
              onTap: (LatLng position) {
                setState(() {
                  _currentLocation = position;
                  // Sadece konumu güncelle, marker ekleme
                });
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false, // Özel butonumuzu kullanacağız
              zoomControlsEnabled: false, // Özel zoom butonlarını kullanacağız
              zoomGesturesEnabled: true, // Dokunarak zoom yapabilme
              scrollGesturesEnabled: true, // Kaydırma hareketleri
              tiltGesturesEnabled: true, // Eğme hareketleri
              rotateGesturesEnabled: true, // Döndürme hareketleri
            ),
          ),

          // Back Button
          Positioned(
            left: 24,
            top: 60,
              child: Row(
                children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: const ShapeDecoration(
                      color: Color(0xFF32343E),
                      shape: OvalBorder(),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Zoom Controls
          Positioned(
            right: 24,
            top: 120,
            child: Column(
              children: [
                // Zoom In Button
                GestureDetector(
                  onTap: () async {
                    if (_mapController != null) {
                      await _mapController!.animateCamera(
                        CameraUpdate.zoomIn(),
                      );
                    }
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Color(0xFF32343E),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Zoom Out Button
                GestureDetector(
                  onTap: () async {
                    if (_mapController != null) {
                      await _mapController!.animateCamera(
                        CameraUpdate.zoomOut(),
                      );
                    }
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: Color(0xFF32343E),
                      size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
          ),

          // My Location Button
          Positioned(
            right: 24,
            // ÖNEMLİ: Bu değer form yüksekliği ile aynı olmalı!
            bottom: MediaQuery.of(context).size.height * 0.6 + 20, // ← Form değeri ile aynı yapın
            child: GestureDetector(
              onTap: _isLoading ? null : _getCurrentLocation,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey[300] : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF32343E)),
                      ),
                    )
                  : const Icon(
                      Icons.my_location,
                      color: Color(0xFF32343E),
                      size: 24,
                    ),
              ),
            ),
          ),

          // Form Section - Bottom Sheet Style
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              // HARITA YÜKSEKLİĞİ AYARI:
              // 0.5 = %50 form, %50 harita (yarı yarıya)
              // 0.6 = %60 form, %40 harita (şu anki)
              // 0.7 = %70 form, %30 harita (daha az harita)
              // 0.4 = %40 form, %60 harita (daha fazla harita)
              height: MediaQuery.of(context).size.height * 0.6, // ← BU SAYIYI DEĞİŞTİRİN
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // ADRES Label at the top
                    Row(
                      children: [
                      Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFBC8157),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                          color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'ADRES',
                          style: TextStyle(
                            color: Color(0xFF32343E),
                                fontSize: 16,
                            fontFamily: 'Sen',
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                            ),
                            const SizedBox(height: 20),
                    // Adres Field
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: ShapeDecoration(
                        color: const Color(0x4CF1F1F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: TextField(
                        controller: _addressController,
                        onChanged: (value) {
                          // Adres değiştiğinde haritayı güncelle
                          if (value.length > 5) {
                            _searchAddress();
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'Adres Bilgilerini Giriniz',
                          hintStyle: TextStyle(
                            color: Color(0xFF6B6E82),
                            fontSize: 12,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Mahalle ve Posta Kodu
                    Row(
                      children: [
                        // Mahalle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'MAHALLE',
                                style: TextStyle(
                                  color: Color(0xFF32343E),
                                fontSize: 14,
                                  fontFamily: 'Sen',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.28,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 50,
                                decoration: ShapeDecoration(
                                  color: const Color(0x4CF1F1F1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: TextField(
                                  controller: _neighborhoodController,
                                  decoration: const InputDecoration(
                                    hintText: 'Örnek Mah.',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF6B6E82),
                                      fontSize: 12,
                                      fontFamily: 'Sen',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 15),

                        // Posta Kodu
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'POSTA KODU',
                                style: TextStyle(
                                  color: Color(0xFF32343E),
                                  fontSize: 14,
                                  fontFamily: 'Sen',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.28,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 50,
                                decoration: ShapeDecoration(
                                  color: const Color(0x4CF1F1F1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: TextField(
                                  controller: _postalCodeController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: '12345',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF6B6E82),
                                      fontSize: 12,
                                      fontFamily: 'Sen',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                            ),
                          ],
                        ),

                    const SizedBox(height: 24),

                    // Daire No
                    const Text(
                      'DAİRE NO:',
                      style: TextStyle(
                        color: Color(0xFF32343E),
                        fontSize: 14,
                        fontFamily: 'Sen',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.28,
                      ),
                    ),
                    const SizedBox(height: 8),
                      Container(
                      width: double.infinity,
                      height: 50,
                      decoration: ShapeDecoration(
                        color: const Color(0x4CF1F1F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: TextField(
                        controller: _apartmentController,
                        decoration: const InputDecoration(
                          hintText: '123',
                          hintStyle: TextStyle(
                            color: Color(0xFF6B6E82),
                            fontSize: 12,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                        ),
                                      ),
                                    ),

                    const SizedBox(height: 24),

                    // Adres Başlığı
                    const Text(
                      'ADRES BAŞLIĞI:',
                      style: TextStyle(
                        color: Color(0xFF32343E),
                        fontSize: 14,
                        fontFamily: 'Sen',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                                width: double.infinity,
                      height: 50,
                      decoration: ShapeDecoration(
                        color: const Color(0x4CF1F1F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: TextField(
                        controller: _addressTitleController,
                        decoration: const InputDecoration(
                          hintText: 'Ev, İş',
                          hintStyle: TextStyle(
                            color: Color(0xFF6B6E82),
                            fontSize: 12,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Kaydet Button
                    GestureDetector(
                      onTap: _isLoading ? null : _saveAddress,
                      child: Container(
                        width: double.infinity,
                        height: 62,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFBC8157),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'KAYDET',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                              color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Sen',
                                    fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ],
      ),
    );
  }
}