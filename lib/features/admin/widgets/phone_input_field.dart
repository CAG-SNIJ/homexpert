import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? selectedCountryCode;
  final List<Map<String, String>> countryCodes;
  final ValueChanged<String?> onCountryCodeChanged;
  final String? Function(String?)? validator;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.selectedCountryCode,
    required this.countryCodes,
    required this.onCountryCodeChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
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
      value: selectedCountryCode,
      onChanged: onCountryCodeChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Select code';
        }
        return null;
      },
      items: countryCodes
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
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      validator: validator ??
          (value) {
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
    );
  }
}

