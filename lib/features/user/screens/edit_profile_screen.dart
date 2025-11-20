import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/homepage_header.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobilePhoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Dropdown values
  String? _selectedRegion;
  String? _selectedArea;
  String? _selectedGender;
  String? _selectedMonth;
  String? _selectedYear;
  String? _selectedCountryCode;
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isChangingPassword = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  
  Map<String, dynamic>? _userProfile;

  // Options for dropdowns
  final List<String> _regions = [
    'Penang',
    'Kuala Lumpur',
    'Selangor',
    'Johor',
    'Melaka',
    'Perak',
    'Kedah',
    'Perlis',
    'Negeri Sembilan',
    'Pahang',
    'Terengganu',
    'Kelantan',
    'Sabah',
    'Sarawak',
  ];
  final Map<String, List<String>> _regionAreas = {
    'Penang': [
      'George Town',
      'Tanjung Tokong',
      'Tanjung Bungah',
      'Bayan Lepas',
      'Gelugor',
      'Butterworth',
      'Bukit Mertajam',
    ],
    'Kuala Lumpur': [
      'Bukit Bintang',
      'Cheras',
      'Sentul',
      'Setapak',
      'Bandar Tun Razak',
      'Wangsa Maju',
      'Segambut',
      'Lembah Pantai',
      'Titiwangsa',
      'Brickfields',
      'Sri Hartamas',
      'Damansara',
      'Petaling Jaya',
      'Mont Kiara',
    ],
    'Selangor': [
      'Shah Alam',
      'Petaling Jaya',
      'Subang Jaya',
      'Klang',
      'Kajang',
      'Puchong',
      'Cyberjaya',
      'Seri Kembangan',
      'Rawang',
      'Bangi',
      'Sepang',
    ],
    'Johor': [
      'Johor Bahru',
      'Iskandar Puteri',
      'Pasir Gudang',
      'Skudai',
      'Batu Pahat',
      'Kluang',
      'Muar',
      'Pontian',
      'Segamat',
      'Kulai',
    ],
    'Melaka': [
      'Melaka City',
      'Ayer Keroh',
      'Alor Gajah',
      'Jasin',
      'Bukit Beruang',
      'Masjid Tanah',
    ],
    'Perak': [
      'Ipoh',
      'Taiping',
      'Sitiawan',
      'Teluk Intan',
      'Batu Gajah',
      'Kampar',
      'Lumut',
    ],
    'Kedah': [
      'Alor Setar',
      'Sungai Petani',
      'Kulim',
      'Langkawi',
      'Jitra',
      'Kubang Pasu',
    ],
    'Perlis': [
      'Kangar',
      'Arau',
      'Padang Besar',
    ],
    'Negeri Sembilan': [
      'Seremban',
      'Nilai',
      'Port Dickson',
      'Bahau',
      'Tampin',
      'Gemas',
    ],
    'Pahang': [
      'Kuantan',
      'Temerloh',
      'Bentong',
      'Bera',
      'Cameron Highlands',
      'Jerantut',
    ],
    'Terengganu': [
      'Kuala Terengganu',
      'Kemaman',
      'Dungun',
      'Besut',
      'Marang',
      'Setiu',
    ],
    'Kelantan': [
      'Kota Bharu',
      'Pasir Mas',
      'Tanah Merah',
      'Machang',
      'Tumpat',
      'Kuala Krai',
    ],
    'Sabah': [
      'Kota Kinabalu',
      'Sandakan',
      'Tawau',
      'Lahad Datu',
      'Keningau',
      'Penampang',
      'Putatan',
    ],
    'Sarawak': [
      'Kuching',
      'Miri',
      'Sibu',
      'Bintulu',
      'Sarikei',
      'Sri Aman',
      'Kota Samarahan',
    ],
  };
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  late final List<String> _years;
  final List<Map<String, String>> _countryCodes = [
    {'label': 'Malaysia (+60)', 'code': '+60'},
    {'label': 'Singapore (+65)', 'code': '+65'},
    {'label': 'Thailand (+66)', 'code': '+66'},
    {'label': 'Indonesia (+62)', 'code': '+62'},
    {'label': 'Philippines (+63)', 'code': '+63'},
    {'label': 'Australia (+61)', 'code': '+61'},
    {'label': 'Japan (+81)', 'code': '+81'},
    {'label': 'South Korea (+82)', 'code': '+82'},
    {'label': 'China (+86)', 'code': '+86'},
    {'label': 'Hong Kong (+852)', 'code': '+852'},
    {'label': 'Taiwan (+886)', 'code': '+886'},
    {'label': 'United States (+1)', 'code': '+1'},
    {'label': 'United Kingdom (+44)', 'code': '+44'},
    {'label': 'Canada (+1)', 'code': '+1'},
    {'label': 'India (+91)', 'code': '+91'},
    {'label': 'United Arab Emirates (+971)', 'code': '+971'},
    {'label': 'Saudi Arabia (+966)', 'code': '+966'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCountryCode = _countryCodes.first['code'];
    final currentYear = DateTime.now().year;
    final maxYear = currentYear - 18;
    _years = List.generate(
      82,
      (index) => (maxYear - index).toString(),
    );
    _loadUserProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobilePhoneController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final profile = await _authService.getUserProfile();
      
      setState(() {
        _userProfile = profile;
        _firstNameController.text = profile['first_name'] ?? '';
        _lastNameController.text = profile['last_name'] ?? '';
        _emailController.text = profile['email'] ?? '';
        _selectedCountryCode = profile['country_code'] ?? '+60';
        _mobilePhoneController.text = profile['phone_number'] ?? '';
        
        _selectedRegion = profile['region']?.toString().isEmpty == true || profile['region'] == null
            ? null
            : profile['region'].toString();
        
        _selectedArea = profile['area']?.toString().isEmpty == true || profile['area'] == null
            ? null
            : profile['area'].toString();
        
        _selectedGender = profile['gender']?.toString().isEmpty == true || profile['gender'] == null
            ? null
            : profile['gender'].toString();
        
        _selectedMonth = profile['birthday_month']?.toString().isEmpty == true || profile['birthday_month'] == null
            ? null
            : profile['birthday_month'].toString();
        
        _selectedYear = profile['birthday_year']?.toString().isEmpty == true || profile['birthday_year'] == null
            ? null
            : profile['birthday_year'].toString();
        
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getInitials(String? firstName, String? lastName) {
    final first = firstName?.isNotEmpty == true ? firstName![0] : '';
    final last = lastName?.isNotEmpty == true ? lastName![0] : '';
    return '${first}${last}'.toUpperCase();
  }

  String _getFullName() {
    if (_userProfile == null) return '';
    final firstName = _userProfile!['first_name'] ?? '';
    final lastName = _userProfile!['last_name'] ?? '';
    return '${firstName} ${lastName}'.trim();
  }

  String _getJoinedYear() {
    if (_userProfile == null) return '';
    final createdAt = _userProfile!['created_at'];
    if (createdAt == null) return '';
    try {
      final date = DateTime.parse(createdAt.toString());
      return date.year.toString();
    } catch (e) {
      return '';
    }
  }

  Future<void> _handleChangePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New password and confirm password do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isChangingPassword = true;
      });

      try {
        await _authService.changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear password fields
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isChangingPassword = false;
          });
        }
      }
    }
  }

  Future<void> _handleSaveChanges() async {
    if (_formKey.currentState!.validate()) {
      final phoneError = _validatePhoneInputs();
      if (phoneError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(phoneError),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final ageError = _validateAdultAge();
      if (ageError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ageError),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        final fullPhoneNumber = '${_selectedCountryCode!}${_mobilePhoneController.text.trim()}';

        await _authService.updateProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          mobilePhone: fullPhoneNumber,
          region: _selectedRegion,
          area: _selectedArea,
          gender: _selectedGender,
          birthdayMonth: _selectedMonth,
          birthdayYear: _selectedYear,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Reload profile and navigate back
          await _loadUserProfile();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.pop();
            }
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  String? _validatePhoneInputs() {
    if (_selectedCountryCode == null || _selectedCountryCode!.isEmpty) {
      return 'Please select a country code for the mobile number';
    }
    if (!RegExp(r'^[0-9]{7,11}$').hasMatch(_mobilePhoneController.text.trim())) {
      return 'Enter digits only (7-11 numbers) for the mobile phone';
    }
    return null;
  }

  String? _validateAdultAge() {
    if (_selectedMonth == null || _selectedYear == null) {
      return null;
    }

    final monthIndex = _months.indexOf(_selectedMonth!);
    final year = int.tryParse(_selectedYear!);
    if (monthIndex == -1 || year == null) {
      return 'Invalid birthday selection';
    }

    final birthDate = DateTime(year, monthIndex + 1, 1);
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    if (age < 18) {
      return 'User must be at least 18 years old';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: CustomScrollView(
        slivers: [
          // Sticky Header
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              child: HomepageHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : _userProfile != null
                          ? Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile Header
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(40),
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
                                      children: [
                                        // Profile Picture
                                        Stack(
                                          children: [
                                            Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color(0xFFFFA500),
                                                  width: 3,
                                                ),
                                              ),
                                              child: _userProfile!['profile_picture'] != null &&
                                                      _userProfile!['profile_picture'].toString().isNotEmpty
                                                  ? ClipOval(
                                                      child: Image.network(
                                                        _userProfile!['profile_picture'],
                                                        width: 120,
                                                        height: 120,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return CircleAvatar(
                                                            radius: 60,
                                                            backgroundColor: AppTheme.primaryColor,
                                                            child: Text(
                                                              _getInitials(
                                                                _userProfile!['first_name'],
                                                                _userProfile!['last_name'],
                                                              ),
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 36,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : CircleAvatar(
                                                      radius: 60,
                                                      backgroundColor: AppTheme.primaryColor,
                                                      child: Text(
                                                        _getInitials(
                                                          _userProfile!['first_name'],
                                                          _userProfile!['last_name'],
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 36,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Upload Picture',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _getFullName(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Joined in ${_getJoinedYear()}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Change Password Section
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(40),
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
                                    child: Form(
                                      key: _passwordFormKey,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Change Password',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          _buildPasswordField(
                                            controller: _currentPasswordController,
                                            label: 'Current Password',
                                            hint: 'Current Password',
                                            obscureText: !_showCurrentPassword,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _showCurrentPassword
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _showCurrentPassword = !_showCurrentPassword;
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          _buildPasswordField(
                                            controller: _newPasswordController,
                                            label: 'New Password',
                                            hint: 'New Password',
                                            obscureText: !_showNewPassword,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _showNewPassword
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _showNewPassword = !_showNewPassword;
                                                });
                                              },
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter new password';
                                              }
                                              if (value.length < 6) {
                                                return 'Password must be at least 6 characters';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          _buildPasswordField(
                                            controller: _confirmPasswordController,
                                            label: 'Confirm Password',
                                            hint: 'Confirm Password',
                                            obscureText: !_showConfirmPassword,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _showConfirmPassword
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _showConfirmPassword = !_showConfirmPassword;
                                                });
                                              },
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please confirm password';
                                              }
                                              if (value != _newPasswordController.text) {
                                                return 'Passwords do not match';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: _isChangingPassword ? null : _handleChangePassword,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.primaryColor,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: _isChangingPassword
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Change Password',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Edit Profile Section
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(40),
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
                                        const Text(
                                          'Edit Profile',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildTextField(
                                                controller: _firstNameController,
                                                label: 'First Name',
                                                hint: 'Enter first name',
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please enter first name';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 24),
                                            Expanded(
                                              child: _buildTextField(
                                                controller: _lastNameController,
                                                label: 'Last Name',
                                                hint: 'Enter last name',
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please enter last name';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        _buildPhoneField(),
                                        const SizedBox(height: 20),
                                        _buildTextField(
                                          controller: _emailController,
                                          label: 'Email Address',
                                          hint: 'Enter email address',
                                          enabled: false,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter email address';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        _buildDropdown(
                                          label: 'Region',
                                          value: _selectedRegion,
                                          items: _regions,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedRegion = value;
                                              _selectedArea = null;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please select region';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        _buildAreaDropdown(),
                                        const SizedBox(height: 20),
                                        _buildDropdown(
                                          label: 'Gender',
                                          value: _selectedGender,
                                          items: _genders,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedGender = value;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please select gender';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildDropdown(
                                                label: 'Birthday Month',
                                                value: _selectedMonth,
                                                items: _months,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedMonth = value;
                                                  });
                                                },
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please select month';
                                                  }
                                                  final ageError = _validateAdultAge();
                                                  if (ageError != null) {
                                                    return ageError;
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildDropdown(
                                                label: 'Birthday Year',
                                                value: _selectedYear,
                                                items: _years,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedYear = value;
                                                  });
                                                },
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please select year';
                                                  }
                                                  final ageError = _validateAdultAge();
                                                  if (ageError != null) {
                                                    return ageError;
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  
                                  // Action Buttons
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isSubmitting ? null : _handleSaveChanges,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: _isSubmitting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Save Changes',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6D6D6D),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: !enabled,
            fillColor: enabled ? Colors.white : const Color(0xFFF9F9F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required Widget suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mobile Phone',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 3,
              child: _buildCountryCodeDropdown(),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 5,
              child: _buildPhoneNumberField(),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phone verification feature coming soon'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Verify'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCountryCodeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCountryCode,
      onChanged: (value) {
        setState(() {
          _selectedCountryCode = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Select code';
        }
        return null;
      },
      items: _countryCodes
          .map(
            (code) => DropdownMenuItem<String>(
              value: code['code'],
              child: Text(
                code['label'] ?? '',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        isDense: true,
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return _buildTextField(
      controller: _mobilePhoneController,
      label: '',
      hint: 'Enter mobile phone',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter mobile phone';
        }
        if (!RegExp(r'^[0-9]{7,11}$').hasMatch(value)) {
          return 'Enter digits only (7-11 numbers)';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: label.isNotEmpty ? 'Select $label' : 'Select',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.arrow_drop_down),
        ),
      ],
    );
  }

  Widget _buildAreaDropdown() {
    final isEnabled = _selectedRegion != null;
    final areas = isEnabled ? (_regionAreas[_selectedRegion] ?? []) : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Area',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: isEnabled ? _selectedArea : null,
          items: areas
              .map(
                (area) => DropdownMenuItem<String>(
                  value: area,
                  child: Text(area),
                ),
              )
              .toList(),
          onChanged: isEnabled
              ? (value) {
                  setState(() {
                    _selectedArea = value;
                  });
                }
              : null,
          validator: (value) {
            if (!isEnabled) {
              return 'Select a region first';
            }
            if (value == null || value.isEmpty) {
              return 'Please select area';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: isEnabled ? 'Select Area' : 'Select region first',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.arrow_drop_down),
        ),
      ],
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

