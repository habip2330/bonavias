import 'package:flutter/material.dart';

class RateBranchWidget extends StatefulWidget {
  final String branchName;
  final String branchId;

  const RateBranchWidget({
    super.key,
    required this.branchName,
    required this.branchId,
  });

  @override
  State<RateBranchWidget> createState() => _RateBranchWidgetState();
}

class _RateBranchWidgetState extends State<RateBranchWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  int _selectedStars = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedStars = index + 1;
            });
          },
          child: Icon(
            Icons.star,
            size: 32,
            color: index < _selectedStars ? const Color(0xFFFFD700) : Colors.grey[300],
          ),
        );
      }),
    );
  }

  void _submitRating() {
    // Form validation
    if (_selectedStars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir puan seçin')),
      );
      return;
    }

    if (_nameController.text.isEmpty || _surnameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad ve soyad alanları zorunludur')),
      );
      return;
    }

    // TODO: Send rating to backend
    print('Rating submitted for branch ${widget.branchId}:');
    print('Stars: $_selectedStars');
    print('Name: ${_nameController.text}');
    print('Surname: ${_surnameController.text}');
    print('Email: ${_emailController.text}');
    print('Phone: ${_phoneController.text}');
    print('Note: ${_noteController.text}');

    Navigator.of(context).pop();
    
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
        content: Text('Puanınız başarıyla gönderildi!'),
        backgroundColor: Color(0xFFBC8157),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
        child: Column(
          children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with branch name and close button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFBC8157),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      '${widget.branchName} Şubesini\nPuanla',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Sen',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

            const SizedBox(height: 24),

                  // Star Rating
                  _buildStarRating(),

                  const SizedBox(height: 32),

                  // Name and Surname Row
                  Row(
                    children: [
                      // Name Field
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ADINIZ',
                              style: TextStyle(
                                color: Color(0xFF32343E),
                                fontSize: 12,
                                fontFamily: 'Sen',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Adınız',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontSize: 14,
                                    fontFamily: 'Sen',
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF32343E),
                                  fontSize: 14,
                                  fontFamily: 'Sen',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Surname Field
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SOYADINIZ',
                              style: TextStyle(
                                color: Color(0xFF32343E),
                                fontSize: 12,
                                fontFamily: 'Sen',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: _surnameController,
                                decoration: const InputDecoration(
                                  hintText: 'Soyadınız',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontSize: 14,
                                    fontFamily: 'Sen',
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF32343E),
                                  fontSize: 14,
                                  fontFamily: 'Sen',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Email Field
                  const Text(
                    'E-POSTA',
                    style: TextStyle(
                      color: Color(0xFF32343E),
                      fontSize: 12,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'örnek@gmail.com',
                        hintStyle: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 14,
                          fontFamily: 'Sen',
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF32343E),
                        fontSize: 14,
                        fontFamily: 'Sen',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Phone Field
                  const Text(
                    'TELEFON',
                    style: TextStyle(
                      color: Color(0xFF32343E),
                      fontSize: 12,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '0 555 555 55 55',
                        hintStyle: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 14,
                          fontFamily: 'Sen',
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF32343E),
                        fontSize: 14,
                        fontFamily: 'Sen',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Note Field
                  const Text(
                    'NOTUNUZ:',
                    style: TextStyle(
                      color: Color(0xFF32343E),
                      fontSize: 12,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Notunuz',
                        hintStyle: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 14,
                          fontFamily: 'Sen',
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF32343E),
                        fontSize: 14,
                        fontFamily: 'Sen',
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Cancel Button
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: const Center(
                        child: Text(
                          'İptal',
                          style: TextStyle(
                            color: Color(0xFF32343E),
                            fontSize: 16,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Submit Button
                Expanded(
                  child: GestureDetector(
                    onTap: _submitRating,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBC8157),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Text(
                        'Gönder',
                          style: TextStyle(
                            color: Colors.white,
                          fontSize: 16,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        ),
                      ),
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

// Helper function to show the rating bottom sheet
void showRatingBottomSheet(BuildContext context, String branchName, String branchId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => RateBranchWidget(
      branchName: branchName,
      branchId: branchId,
    ),
  );
}