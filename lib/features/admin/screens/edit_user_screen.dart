import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_sidebar.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;
  
  const EditUserScreen({
    super.key,
    required this.userId,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();
  
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobilePhoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Dropdown values
  String? _selectedRegion;
  String? _selectedArea;
  String? _selectedGender;
  String? _selectedMonth;
  String? _selectedYear;
  String? _selectedCountryCode;
  
  bool _isSubmitting = false;
  bool _isLoading = true;
  final ValueNotifier<String> _emailPrefixNotifier = ValueNotifier<String>('');

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
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobilePhoneController.dispose();
    _emailController.dispose();
    _emailPrefixNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userData = await _adminService.getUserById(widget.userId);

      if (mounted) {
        setState(() {
          _firstNameController.text = userData['first_name'] ?? '';
          _lastNameController.text = userData['last_name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _selectedCountryCode = userData['country_code'] ?? '+60';
          _mobilePhoneController.text = userData['phone_number'] ?? '';
          
          final region = userData['region'];
          _selectedRegion = (region == null || region.toString().isEmpty) ? null : region.toString();
          
          final area = userData['area'];
          _selectedArea = (area == null || area.toString().isEmpty) ? null : area.toString();
          
          final gender = userData['gender'];
          _selectedGender = (gender == null || gender.toString().isEmpty) ? null : gender.toString();
          
          final month = userData['birthday_month'];
          _selectedMonth = (month == null || month.toString().isEmpty) ? null : month.toString();
          
          final year = userData['birthday_year'];
          _selectedYear = (year == null || year.toString().isEmpty) ? null : year.toString();
          
          // Set email prefix for suggestions
          final email = userData['email'] ?? '';
          final atIndex = email.indexOf('@');
          if (atIndex != -1) {
            _emailPrefixNotifier.value = email.substring(0, atIndex);
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        // Navigate back after showing error
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/admin/users');
          }
        });
      }
    }
  }

  void _resetForm() {
    _loadUserData();
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
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

        final fullPhoneNumber = '${_selectedCountryCode!}${_mobilePhoneController.text.trim()}';

        await _adminService.updateUser(
          userId: widget.userId,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
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
              content: Text('User updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Navigate back to manage users screen
          context.go('/admin/users');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating user: ${e.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              if (mounted) {
                context.go(AppConstants.routeHome);
              }
            }
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  const SizedBox(width: 260),
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        Expanded(
                          child: Container(
                            color: Colors.white,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Positioned(
                left: 0,
                top: 70,
                bottom: 0,
                child: AdminSidebar(currentRoute: '/admin/users'),
              ),
              const Positioned(
                left: 0,
                top: 0,
                right: 0,
                child: AdminHeader(),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            if (mounted) {
              context.go(AppConstants.routeHome);
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Content (bottom layer)
            Row(
              children: [
                const SizedBox(width: 260), // Spacer for sidebar
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 60), // Spacer for header
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  const Text(
                                    'Edit User',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF387366),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Form Fields
                                  Column(
                                    children: [
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
                                      _buildEmailField(),
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
                                      const SizedBox(height: 32),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _isSubmitting ? null : _handleUpdate,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryColor,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                                                  'Update',
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _resetForm,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF6D6D6D),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                          ),
                                          child: const Text(
                                            'Reset',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
            // Sidebar (middle layer)
            Positioned(
              left: 0,
              top: 70,
              bottom: 0,
              child: AdminSidebar(
                currentRoute: '/admin/users/edit',
              ),
            ),
            // Header (top layer)
            const Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: AdminHeader(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    const suffixes = ['@gmail.com', '@yahoo.com', '@hotmail.com', '@outlook.com'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<String>(
          valueListenable: _emailPrefixNotifier,
          builder: (context, prefix, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    final atIndex = value.indexOf('@');
                    final extractedPrefix = atIndex == -1 ? value : value.substring(0, atIndex);
                    _emailPrefixNotifier.value = extractedPrefix;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter email address',
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
                ),
                if (prefix.isNotEmpty && !prefix.contains(' '))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: suffixes.map((suffix) {
                        return OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            visualDensity: VisualDensity.compact,
                            side: const BorderSide(color: Color(0xFF387366)),
                          ),
                          onPressed: () {
                            _emailController.text = '$prefix$suffix';
                            _emailController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _emailController.text.length),
                            );
                            _emailPrefixNotifier.value = prefix;
                          },
                          child: Text(
                            suffix,
                            style: const TextStyle(color: Color(0xFF387366)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
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
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 360;
            final dropdown = _buildCountryCodeDropdown();
            final phoneInput = _buildPhoneNumberField();

            if (isCompact) {
              return Column(
                children: [
                  dropdown,
                  const SizedBox(height: 12),
                  phoneInput,
                ],
              );
            }

            return Row(
              children: [
                Flexible(
                  flex: 2,
                  child: dropdown,
                ),
                const SizedBox(width: 12),
                Flexible(
                  flex: 8,
                  child: phoneInput,
                ),
              ],
            );
          },
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
              child: Text(code['label'] ?? ''),
            ),
          )
          .toList(),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return _buildTextField(
      controller: _mobilePhoneController,
      label: '',
      hint: 'Enter mobile phone',
      keyboardType: TextInputType.phone,
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
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
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
}

