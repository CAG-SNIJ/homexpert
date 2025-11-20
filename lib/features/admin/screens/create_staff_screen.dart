import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/phone_input_field.dart';

class CreateStaffScreen extends StatefulWidget {
  const CreateStaffScreen({super.key});

  @override
  State<CreateStaffScreen> createState() => _CreateStaffScreenState();
}

class _CreateStaffScreenState extends State<CreateStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobilePhoneController = TextEditingController();
  final _emailController = TextEditingController();
  final ValueNotifier<String> _emailPrefixNotifier = ValueNotifier<String>('');

  String? _selectedRegion;
  String? _selectedArea;
  String? _selectedGender;
  String? _selectedRole;
  String? _selectedCountryCode;
  String? _selectedMonth;
  String? _selectedYear;
  late final List<String> _years;

  bool _isSubmitting = false;

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

  final List<String> _staffRoles = [
    'Customer Service',
    'Agent Support',
    'Admin',
    'General Staff',
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
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
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobilePhoneController.dispose();
    _emailController.dispose();
    super.dispose();
    _emailPrefixNotifier.dispose();
  }

  void _handleReset() {
    _formKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _mobilePhoneController.clear();
    _emailController.clear();
    _emailPrefixNotifier.value = '';
    setState(() {
      _selectedRegion = null;
      _selectedArea = null;
      _selectedGender = null;
      _selectedRole = null;
      _selectedMonth = null;
      _selectedYear = null;
    });
  }

  Future<void> _handleCreateStaff() async {
    if (!_formKey.currentState!.validate()) return;

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

    final fullPhoneNumber =
        '${_selectedCountryCode ?? ''}${_mobilePhoneController.text.trim()}';

    try {
      await _adminService.createStaff(
        staffRole: _selectedRole!,
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Staff created successfully'),
          backgroundColor: Colors.green,
        ),
      );

      _handleReset();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error creating staff: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Create Staff',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF387366),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildDropdown(
                                    label: 'Staff Role',
                                    value: _selectedRole,
                                    items: _staffRoles,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRole = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select staff role';
                                      }
                                      return null;
                                    },
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
                                  PhoneInputField(
                                    controller: _mobilePhoneController,
                                    selectedCountryCode: _selectedCountryCode,
                                    countryCodes: _countryCodes,
                                    onCountryCodeChanged: (value) {
                                      setState(() {
                                        _selectedCountryCode = value;
                                      });
                                    },
                                  ),
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
                                    validator: (value) => null,
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
                                      onPressed: _isSubmitting
                                          ? null
                                          : _handleCreateStaff,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                      ),
                                      child: _isSubmitting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Create Staff',
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
                                      onPressed: _handleReset,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF6D6D6D),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                      ),
                                      child: const Text(
                                        'Reset',
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
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              top: 70,
              bottom: 0,
              child: const AdminSidebar(
                currentRoute: '/admin/staff/create',
              ),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    const suffixes = ['@gmail.com', '@yahoo.com', '@hotmail.com', '@outlook.com'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Address',
          style: TextStyle(
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
        Row(
          children: [
            SizedBox(
              width: 110,
              child: DropdownButtonFormField<String>(
                value: _selectedCountryCode,
                onChanged: (value) {
                  setState(() {
                    _selectedCountryCode = value;
                  });
                },
                items: _countryCodes
                    .map(
                      (code) => DropdownMenuItem<String>(
                        value: code['code']!,
                        child: Text(code['label'] ?? code['code']!),
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _mobilePhoneController,
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
                decoration: InputDecoration(
                  hintText: 'Enter mobile phone',
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
                    borderSide:
                        const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.arrow_drop_down),
        ),
      ],
    );
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
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    if (age < 18) {
      return 'Staff must be at least 18 years old';
    }

    return null;
  }
}

