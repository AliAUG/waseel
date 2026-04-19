import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/profile_image_provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/models/user_model.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _loadingProfile = true;
  bool _saving = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  UserModel _defaultUser() => const UserModel(
        name: 'Passenger',
        phone: '+961 70 123 456',
        email: 'user@email.com',
      );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserIntoForm());
  }

  Future<void> _loadUserIntoForm() async {
    final auth = context.read<AuthProvider>();
    final t = auth.token;
    if (t != null && t.isNotEmpty && t != 'local-session') {
      await auth.refreshProfile();
    }
    if (!mounted) return;
    final user = auth.user ?? _defaultUser();
    _nameController.text = user.name;
    _emailController.text = user.email ?? '';
    _phoneController.text = user.phone;
    _selectedImage = null;
    final path = user.profileImagePath;
    if (path != null &&
        path.isNotEmpty &&
        !path.toLowerCase().startsWith('http://') &&
        !path.toLowerCase().startsWith('https://')) {
      final file = File(path);
      if (file.existsSync()) {
        _selectedImage = file;
      }
    }
    setState(() => _loadingProfile = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
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
        title: Text(
          flow.editPersonalInfoTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user ?? _defaultUser();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _ProfilePhoto(
                  initials: user.initials,
                  imagePath: _selectedImage?.path ?? user.profileImagePath,
                  onTap: _showImageSourceBottomSheet,
                  changePhotoLabel: flow.profileChangePhoto,
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _nameController,
                  label: flow.profileFullName,
                  hint: flow.profileFullNameHint,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  label: flow.profileEmail,
                  hint: flow.profileEmailHint,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _phoneController,
                  label: flow.profilePhone,
                  hint: flow.profilePhoneHint,
                  keyboardType: TextInputType.phone,
                  enabled: false,
                  helperText: flow.profilePhoneLockedHint,
                ),
                const SizedBox(height: 20),
                _InfoBox(
                  text: flow.profileDataInfo,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving
                        ? null
                        : () async {
                            final name = _nameController.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(flow.profilePleaseEnterName),
                                ),
                              );
                              return;
                            }
                            final emailText = _emailController.text.trim();
                            final email =
                                emailText.isEmpty ? null : emailText;

                            setState(() => _saving = true);
                            String? savedPath;
                            if (_selectedImage != null) {
                              savedPath =
                                  await _saveProfileImage(_selectedImage!);
                            }
                            if (!context.mounted) return;

                            final token = auth.token;
                            final useApi = token != null &&
                                token.isNotEmpty &&
                                token != 'local-session';

                            if (useApi) {
                              final ok = await auth.saveProfileToBackend(
                                fullName: name,
                                email: email,
                              );
                              if (!context.mounted) return;
                              setState(() => _saving = false);
                              if (!ok) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      auth.lastError ?? 'Could not save profile',
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (savedPath != null) {
                                auth.updateProfile(profileImagePath: savedPath);
                              }
                            } else {
                              auth.updateProfile(
                                name: name,
                                email: email,
                                profileImagePath: savedPath ??
                                    auth.user?.profileImagePath,
                              );
                              if (mounted) setState(() => _saving = false);
                            }

                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(flow.profileSaveChanges),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final flow = PassengerFlowStrings(
          sheetContext.read<SettingsProvider>().language,
        );
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(flow.profileTakePhoto),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(flow.profileChooseGallery),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _saveProfileImage(File sourceFile) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      const fileName = 'profile_photo.jpg';
      final destFile = File('${dir.path}/$fileName');
      await sourceFile.copy(destFile.path);
      return destFile.path;
    } catch (e) {
      if (mounted) {
        final flow = PassengerFlowStrings(
          context.read<SettingsProvider>().language,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(flow.profileCouldNotSavePhoto(e))),
        );
      }
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        final flow = PassengerFlowStrings(
          context.read<SettingsProvider>().language,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(flow.profileCouldNotPickImage(e))),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool enabled = true,
    String? helperText,
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ],
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({
    required this.initials,
    required this.onTap,
    required this.changePhotoLabel,
    this.imagePath,
  });

  final String initials;
  final VoidCallback onTap;
  final String changePhotoLabel;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final bg = profileImageProvider(imagePath);
    final hasImage = bg != null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.primaryTeal,
                backgroundImage: bg,
                child: !hasImage
                    ? Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            changePhotoLabel,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.primaryTeal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.blue.shade900,
        ),
      ),
    );
  }
}
