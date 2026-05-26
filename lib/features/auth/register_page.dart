import 'package:flutter/material.dart';

import '../../theme/colors_config.dart';
import '../../services/auth_service.dart';
import '../../widgets/components/app_button.dart';
import '../../widgets/components/app_input.dart';
import '../../widgets/layout/app_shell.dart';
import 'password_policy.dart';
import 'widgets/password_requirements_panel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _isSubmitting = false;

  final List<Map<String, String>> _countryCodes = [
    {'name': 'Indonesia', 'code': 'ID', 'dial_code': '+62', 'flag': '🇮🇩'},
    {'name': 'Malaysia', 'code': 'MY', 'dial_code': '+60', 'flag': '🇲🇾'},
    {'name': 'Singapore', 'code': 'SG', 'dial_code': '+65', 'flag': '🇸🇬'},
    {'name': 'Philippines', 'code': 'PH', 'dial_code': '+63', 'flag': '🇵🇭'},
    {'name': 'Thailand', 'code': 'TH', 'dial_code': '+66', 'flag': '🇹🇭'},
    {'name': 'Vietnam', 'code': 'VN', 'dial_code': '+84', 'flag': '🇻🇳'},
    {'name': 'United States', 'code': 'US', 'dial_code': '+1', 'flag': '🇺🇸'},
    {'name': 'United Kingdom', 'code': 'UK', 'dial_code': '+44', 'flag': '🇬🇧'},
    {'name': 'Australia', 'code': 'AU', 'dial_code': '+61', 'flag': '🇦🇺'},
  ];
  Map<String, String>? _selectedCountry;

  String? _emailError;
  bool _isEmailValid = false;

  String? _phoneError;
  bool _isPhoneValid = false;

  String? _passwordError;
  bool _isPasswordValid = false;

  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final _phoneRegex = RegExp(r'^[0-9]{8,15}$');

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countryCodes.firstWhere((c) => c['code'] == 'ID');
    
    _passwordFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    _confirmPasswordController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    if (value.isEmpty) {
      setState(() {
        _emailError = null;
        _isEmailValid = false;
      });
      return;
    }
    setState(() {
      if (!_emailRegex.hasMatch(value)) {
        _emailError = 'Please enter a valid email address';
        _isEmailValid = false;
      } else {
        _emailError = null;
        _isEmailValid = true;
      }
    });
  }

  void _validatePhone(String value) {
    if (value.isEmpty) {
      setState(() {
        _phoneError = null;
        _isPhoneValid = false;
      });
      return;
    }
    setState(() {
      if (!_phoneRegex.hasMatch(value)) {
        _phoneError = 'Must be 8-15 digits';
        _isPhoneValid = false;
      } else {
        _phoneError = null;
        _isPhoneValid = true;
      }
    });
  }

  void _validatePassword(String value) {
    final error = PasswordPolicy.validate(value);
    setState(() {
      _passwordError = value.isEmpty ? null : error;
      _isPasswordValid = error == null && value.isNotEmpty;
    });
  }

  Future<void> _handleRegister() async {
    // Final check before submit
    _validateEmail(_emailController.text);
    _validatePhone(_phoneController.text);
    _validatePassword(_passwordController.text);

    if (_emailError != null || _phoneError != null || _passwordError != null) {
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final phone = _selectedCountry != null 
          ? '${_selectedCountry!['dial_code']}${_phoneController.text}'
          : _phoneController.text;

      await AuthService.register(
        namaLengkap: _nameController.text,
        email: _emailController.text,
        nomorHp: phone,
        password: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account successfully created.')),
      );
      Navigator.of(context).pushReplacementNamed('/app');
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Registration failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorsConfig>()!;
    final textTheme = Theme.of(context).textTheme;

    final isFormValid = _emailController.text.isNotEmpty &&
        _isEmailValid &&
        _phoneController.text.isNotEmpty &&
        _isPhoneValid &&
        _isPasswordValid &&
        _passwordController.text == _confirmPasswordController.text &&
        _nameController.text.isNotEmpty;

    return AppShell(
      showHeader: false,
      showBottomNavigation: false,
      bodyPadding: EdgeInsets.zero,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(height: 8),
            Text(
              'Create Account',
              style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter at least an email or phone number. Both can be used for account recovery. An active internet connection is required to register.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            AppTextField(
              label: 'Full Name',
              hintText: 'Ariana Rizki',
              controller: _nameController,
              onChanged: (v) => setState((){}),
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Email',
              hintText: 'name@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: _validateEmail,
              errorText: _emailError,
              isValid: _isEmailValid,
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Phone Number',
              hintText: '81234567890',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: _validatePhone,
              errorText: _phoneError,
              isValid: _isPhoneValid,
              prefix: _countryCodes.isEmpty 
                  ? const Padding(
                      padding: EdgeInsets.all(12), 
                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 12),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<Map<String, String>>(
                            value: _selectedCountry,
                            icon: const Icon(Icons.arrow_drop_down, size: 18),
                            isDense: true,
                            style: TextStyle(color: colors.textOnSurface, fontSize: 14, fontWeight: FontWeight.w500),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedCountry = newValue;
                                _validatePhone(_phoneController.text);
                              });
                            },
                            items: _countryCodes.map<DropdownMenuItem<Map<String, String>>>((Map<String, String> value) {
                              return DropdownMenuItem<Map<String, String>>(
                                value: value,
                                child: Text('${value['flag']}  ${value['code']} (${value['dial_code']})'),
                              );
                            }).toList(),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: colors.outline,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 18),
            AppPasswordField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              hintText: 'Minimum 8 characters',
              onChanged: _validatePassword,
              errorText: _passwordError,
              isValid: _isPasswordValid,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _passwordFocusNode.hasFocus
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: PasswordRequirementsPanel(password: _passwordController.text),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 18),
            AppPasswordField(
              label: 'Retype Password',
              hintText: 'Enter the same password',
              controller: _confirmPasswordController,
            ),
            const SizedBox(height: 10),
            if (_confirmPasswordController.text.isNotEmpty)
              Text(
                _confirmPasswordController.text == _passwordController.text
                    ? 'Passwords match.'
                    : 'Passwords do not match.',
                style: textTheme.bodyMedium?.copyWith(
                  color: _confirmPasswordController.text == _passwordController.text
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: _isSubmitting ? 'Creating...' : 'Create Account',
              onPressed: (_isSubmitting || !isFormValid) ? null : _handleRegister,
            ),
            const SizedBox(height: 14),
            AppButton.text(
              label: 'Back to Login',
              onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
