import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAddressScreen extends StatefulWidget {
  final Map<String, dynamic> address;
  
  const EditAddressScreen({Key? key, required this.address}) : super(key: key);

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
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
    _initializeFields();
  }

  void _initializeFields() {
    // Pre-populate fields with existing address data
    _addressTitleController.text = widget.address['title'] ?? '';
    _addressController.text = widget.address['address'] ?? '';
    _neighborhoodController.text = widget.address['neighborhood'] ?? '';
    _postalCodeController.text = widget.address['postalCode'] ?? '';
    _apartmentController.text = widget.address['apartmentNo'] ?? '';
    
    // Set current location from existing address
    if (widget.address['latitude'] != null && widget.address['longitude'] != null) {
      _currentLocation = LatLng(
        widget.address['latitude'].toDouble(),
        widget.address['longitude'].toDouble(),
      );
      // Add marker for the current location
      _updateMarker(_currentLocation);
    }
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      LatLng newLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentLocation = newLocation;
      });
      
      // Add marker for the new location
      _updateMarker(newLocation);
      
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
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('selectedLocation'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
          title: 'Seçilen Konum',
          snippet: '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
        ),
      ));
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
                zoom: 10.0,
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

  Future<void> _updateAddress() async {
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
            .doc(widget.address['id'])
            .update({
          'title': _addressTitleController.text,
          'address': _addressController.text,
          'neighborhood': _neighborhoodController.text,
          'postalCode': _postalCodeController.text,
          'apartmentNo': _apartmentController.text,
          'latitude': _currentLocation.latitude,
          'longitude': _currentLocation.longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        _showModernSnackBar(context, 'Adres başarıyla güncellendi!', isSuccess: true);
        
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      _showModernSnackBar(context, 'Adres güncellenirken bir hata oluştu: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Google Maps Section
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: MediaQuery.of(context).size.height * 0.6,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                print('Google Map controller hazır!');
                Future.delayed(const Duration(milliseconds: 1000), () {
                  if (mounted && _mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _currentLocation,
                          zoom: 14.0,
                        ),
                      ),
                    );
                  }
                });
              },
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 10.0,
              ),
              markers: _markers,
              onTap: (LatLng position) {
                _updateMarker(position);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: true,
              rotateGesturesEnabled: true,
            ),
          ),

          // Back Button
          Positioned(
            left: 24,
            top: 60,
            child: GestureDetector(
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
            bottom: MediaQuery.of(context).size.height * 0.6 + 20,
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

          // Form Section - Exact same layout as AddAddressScreen
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
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
                          'ADRES DÜZENLE',
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

                    // Update Button
                    GestureDetector(
                      onTap: _isLoading ? null : _updateAddress,
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
                                  'GÜNCELLE',
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