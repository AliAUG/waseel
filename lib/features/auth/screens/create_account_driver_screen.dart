import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/auth/screens/login_by_phone_screen.dart';
import 'package:waseel/features/auth/screens/otp_verify_screen.dart';

class CreateAccountDriverScreen extends StatefulWidget {
  const CreateAccountDriverScreen({super.key});

  @override
  State<CreateAccountDriverScreen> createState() =>
      _CreateAccountDriverScreenState();
}

class _CreateAccountDriverScreenState extends State<CreateAccountDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _carColorController = TextEditingController();
  final _carPlateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _carLicenseImage;
  XFile? _carRegistrationImage;
  XFile? _personalPhotoImage;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  bool _showDocuments = false;
  bool _documentsSaved = false;
  final String _countryCode = '+961';

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _carColorController.dispose();
    _carPlateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Colors.grey.shade800,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Create driver account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up to drive and earn with RideGo',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your full name' : null,
              ),
              const SizedBox(height: 20),
              _buildPhoneField(),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'your.email@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Email is required for OTP verification';
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildDocumentsSection(),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Create a password',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 22,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) => (v == null || v.length < 6)
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Re-enter your password',
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 22,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                validator: (v) =>
                    v != _passwordController.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleCreateAccount,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Account'),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const LoginByPhoneScreen(forDriver: true),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Log in',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_countryCode, style: TextStyle(fontSize: 15, color: Colors.grey.shade800)),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey.shade600),
                ],
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  return digits.length < 8 ? 'Enter a valid phone number' : null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                  TextInputFormatter.withFunction((old, newText) {
                    if (newText.text.isEmpty) return newText;
                    final digits = newText.text.replaceAll(RegExp(r'\D'), '');
                    if (digits.length <= 2) return TextEditingValue(text: digits);
                    if (digits.length <= 5) {
                      return TextEditingValue(
                        text: '${digits.substring(0, 2)} ${digits.substring(2)}',
                        selection: TextSelection.collapsed(
                          offset: '${digits.substring(0, 2)} ${digits.substring(2)}'.length,
                        ),
                      );
                    }
                    return TextEditingValue(
                      text: '${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5)}',
                      selection: TextSelection.collapsed(
                        offset:
                            '${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5)}'
                                .length,
                      ),
                    );
                  }),
                ],
                decoration: InputDecoration(
                  hintText: '70 123 456',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _showDocuments = !_showDocuments),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Documents (Optional)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                  Icon(
                    _showDocuments
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You can skip these for now and add them later.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (_documentsSaved) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: AppTheme.primaryTeal),
                const SizedBox(width: 6),
                Text(
                  'Documents saved',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ],
            ),
          ],
          if (_showDocuments) ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _carColorController,
              label: 'Car Color',
              hint: 'e.g. White',
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _carPlateController,
              label: 'Car Plate Number',
              hint: 'e.g. Lebanon A-12345',
            ),
            const SizedBox(height: 14),
            _buildUploadTile(
              title: 'Car License Image',
              selectedFile: _carLicenseImage,
              onTap: () => _pickImage(
                onSelected: (file) => setState(() => _carLicenseImage = file),
              ),
            ),
            const SizedBox(height: 10),
            _buildUploadTile(
              title: 'Car Registration Image',
              selectedFile: _carRegistrationImage,
              onTap: () => _pickImage(
                onSelected: (file) =>
                    setState(() => _carRegistrationImage = file),
              ),
            ),
            const SizedBox(height: 10),
            _buildUploadTile(
              title: 'Personal Photo',
              selectedFile: _personalPhotoImage,
              onTap: () => _pickImage(
                onSelected: (file) => setState(() => _personalPhotoImage = file),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => _documentsSaved = false),
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _showDocuments = false),
                    child: const Text('Hide'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _documentsSaved = true;
                        _showDocuments = false;
                      });
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Documents saved'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadTile({
    required String title,
    required XFile? selectedFile,
    required VoidCallback onTap,
  }) {
    final hasFile = selectedFile != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? AppTheme.primaryTeal : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasFile ? Icons.check_circle : Icons.upload_file,
              color: hasFile ? AppTheme.primaryTeal : Colors.grey.shade600,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasFile ? selectedFile.name : 'Tap to upload (optional)',
                    style: TextStyle(
                      fontSize: 12,
                      color: hasFile ? AppTheme.primaryTeal : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage({
    required ValueChanged<XFile> onSelected,
  }) async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (file == null) return;
      onSelected(file);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not pick image. Please try again.')),
      );
    }
  }

  Future<void> _handleCreateAccount() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phoneDigits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final email = _emailController.text.trim();

    setState(() => _isSubmitting = true);
    final success = await context.read<AuthProvider>().registerEmail(
          fullName: _fullNameController.text.trim(),
          email: email,
          password: _passwordController.text,
          role: 'Driver',
          phoneNumber: '$_countryCode$phoneDigits',
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!success) {
      final error = context.read<AuthProvider>().lastError ?? 'Sign up failed';
      final lower = error.toLowerCase();
      if (lower.contains('already registered') || lower.contains('already exist')) {
        final resent = await context.read<AuthProvider>().requestRegistrationEmailOtp(
              email: email,
            );
        if (!mounted) return;
        if (resent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account exists. New verification code sent.')),
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OtpVerifyScreen(
                phoneNumber: '$_countryCode$phoneDigits',
                forDriver: true,
                userName: _fullNameController.text.trim(),
                userEmail: email,
              ),
            ),
          );
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerifyScreen(
          phoneNumber: '$_countryCode$phoneDigits',
          forDriver: true,
          userName: _fullNameController.text.trim(),
          userEmail: email,
        ),
      ),
    );
  }
}
