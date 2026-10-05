import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../repositories/report_repository.dart';
import '../../repositories/user_repository.dart';
import '../../services/session_manager.dart';
import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/roadcare_photo_layout.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepository = UserRepository();

  final ReportRepository _reportRepository = ReportRepository();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  RoadUser? _user;

  int _reportCount = 0;

  bool _isLoading = true;

  bool _isSaving = false;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  // =========================================================
  // LOAD PROFILE
  // =========================================================

  Future<void> _loadProfile() async {
    try {
      final RoadUser? user = await _userRepository.getUserById(widget.userId);

      final reports = await _reportRepository.getReportsByUser(widget.userId);

      if (!mounted) return;

      setState(() {
        _user = user;

        _nameController.text = user?.name ?? widget.userName;

        _emailController.text = user?.email ?? '';

        _reportCount = reports.length;

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Profile load error: $e');

      if (!mounted) return;

      setState(() {
        _nameController.text = widget.userName;
        _isLoading = false;
      });
    }
  }

  // =========================================================
  // EDIT PROFILE
  // =========================================================

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  // =========================================================
  // SAVE PROFILE
  // =========================================================

  Future<void> _saveProfile() async {
    final String name = _nameController.text.trim();

    final String email = _emailController.text.trim();

    if (name.isEmpty) {
      _showMessage('Name cannot be empty.', isError: true);

      return;
    }

    if (email.isEmpty) {
      _showMessage('Email cannot be empty.', isError: true);

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final int updatedRows = await _userRepository.updateUser(
        userId: widget.userId,
        name: name,
        email: email,
      );

      if (updatedRows == 0) {
        throw Exception('User was not updated.');
      }

      await SessionManager.updateUserName(name);

      final RoadUser updatedUser = RoadUser(
        id: widget.userId,
        name: name,
        email: email,
      );

      if (!mounted) return;

      setState(() {
        _user = updatedUser;
        _isEditing = false;
        _isSaving = false;
      });

      _showMessage('Profile updated successfully!');
    } catch (e) {
      debugPrint('Save profile error: $e');

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage('Unable to update profile.', isError: true);
    }
  }

  // =========================================================
  // CANCEL EDIT
  // =========================================================

  void _cancelEditing() {
    setState(() {
      _nameController.text = _user?.name ?? widget.userName;

      _emailController.text = _user?.email ?? '';

      _isEditing = false;
    });
  }

  // =========================================================
  // SETTINGS
  // =========================================================

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await SessionManager.clearSession();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // =========================================================
  // INPUT
  // =========================================================

  InputDecoration _inputDecoration(String label, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: colorScheme.primary),
      filled: true,
      fillColor: theme.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    );
  }

  // =========================================================
  // INFO ROW
  // =========================================================

  Widget _infoRow(IconData icon, String title, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        surfaceTintColor: theme.appBarTheme.surfaceTintColor,
        elevation: 0,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          if (!_isEditing)
            IconButton(
              tooltip: 'Edit Profile',
              onPressed: _isLoading ? null : _startEditing,
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                RoadCarePhotoHeader(
                  imageAsset: 'assets/images/community-street.jpg',
                  eyebrow: 'Your RoadCare profile',
                  title: _nameController.text,
                  description: _emailController.text,
                  height: 230,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // =================================================
                        // PROFILE HEADER
                        // =================================================

                        // =================================================
                        // EDIT FIELDS
                        // =================================================
                        if (_isEditing) ...[
                          TextField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                              'Name',
                              Icons.person_outline,
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              'Email',
                              Icons.email_outlined,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSaving ? null : _cancelEditing,
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveProfile,
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.save_outlined),
                                  label: Text(_isSaving ? 'Saving...' : 'Save'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),
                        ],

                        // =================================================
                        // ACCOUNT INFORMATION
                        // =================================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: theme.brightness == Brightness.dark
                                ? null
                                : const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Column(
                            children: [
                              _infoRow(
                                Icons.person_outline,
                                'Name',
                                _nameController.text,
                              ),

                              const Divider(height: 28),

                              _infoRow(
                                Icons.email_outlined,
                                'Email',
                                _emailController.text,
                              ),

                              const Divider(height: 28),

                              _infoRow(
                                Icons.badge_outlined,
                                'User ID',
                                '${widget.userId}',
                              ),

                              const Divider(height: 28),

                              _infoRow(
                                Icons.description_outlined,
                                'My Reports',
                                '$_reportCount',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // =================================================
                        // SETTINGS
                        // =================================================
                        Material(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.settings_outlined,
                                color: colorScheme.primary,
                              ),
                            ),
                            title: const Text(
                              'Settings',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text('Manage application settings'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _openSettings,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // =================================================
                        // LOGOUT
                        // =================================================
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              'Logout',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(color: Colors.red.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Text(
                          'RoadCare • Road Damage Reporting System',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();

    super.dispose();
  }
}
