import 'package:flutter/material.dart';

import '../../services/app_settings.dart';
import '../../widgets/roadcare_photo_layout.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();

    _notifications = AppSettings.notificationsNotifier.value;
    _darkMode = AppSettings.darkModeNotifier.value;
  }

  // =========================================================
  // NOTIFICATIONS
  // =========================================================

  Future<void> _changeNotifications(bool value) async {
    setState(() {
      _notifications = value;
    });

    await AppSettings.setNotifications(value);

    if (!mounted) return;

    _showMessage(value ? 'Notifications enabled.' : 'Notifications disabled.');
  }

  // =========================================================
  // DARK MODE
  // =========================================================

  Future<void> _changeDarkMode(bool value) async {
    // Update local UI immediately.
    setState(() {
      _darkMode = value;
    });

    // This updates the global ValueNotifier.
    // RoadCareApp listens to this notifier and changes
    // ThemeMode for the complete application.
    await AppSettings.setDarkMode(value);

    if (!mounted) return;

    _showMessage(value ? 'Dark mode enabled.' : 'Light mode enabled.');
  }

  // =========================================================
  // ABOUT
  // =========================================================

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.add_road, color: colorScheme.primary),
              const SizedBox(width: 10),
              const Text('RoadCare'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Road Damage Reporting System',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 10),

              const Text(
                'RoadCare helps users report potholes '
                'and damaged roads with photo evidence '
                'and GPS location.',
              ),

              const SizedBox(height: 15),

              Text(
                'Version 1.0.0',
                style: TextStyle(color: theme.textTheme.bodySmall?.color),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // RESET SETTINGS
  // =========================================================

  Future<void> _resetSettings() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Settings?'),
          content: const Text(
            'This will restore all RoadCare '
            'application settings to their default values.',
          ),
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
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    // Reset saved settings.
    await AppSettings.resetSettings();

    if (!mounted) return;

    setState(() {
      _notifications = true;
      _darkMode = false;
    });

    _showMessage('Settings reset successfully.');
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          backgroundColor: colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // =========================================================
  // SETTING TILE
  // =========================================================

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.cardColor,
        elevation: isDark ? 0 : 2,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 8,
          ),

          // =====================================================
          // ICON
          // =====================================================
          leading: Container(
            padding: const EdgeInsets.all(11),

            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, color: colorScheme.primary),
          ),

          // =====================================================
          // TITLE
          // =====================================================
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),

          // =====================================================
          // SUBTITLE
          // =====================================================
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),

            child: Text(
              subtitle,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),

          trailing: trailing,

          onTap: onTap,
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // =====================================================
      // BACKGROUND
      // =====================================================

      backgroundColor: theme.scaffoldBackgroundColor,

      // =====================================================
      // APP BAR
      // =====================================================
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        title: Text(
          'Settings',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),

      // =====================================================
      // BODY
      // =====================================================
      body: Column(
        children: [
          const RoadCarePhotoHeader(
            imageAsset: 'assets/images/city-avenue.jpg',
            eyebrow: 'Make RoadCare yours',
            title: 'Settings',
            description:
                'Manage notifications, appearance and app preferences.',
            height: 225,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // HEADER
                  // =================================================

                  // =================================================
                  // PREFERENCES
                  // =================================================
                  Text(
                    'Preferences',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =================================================
                  // NOTIFICATIONS
                  // =================================================
                  _settingTile(
                    icon: Icons.notifications_none,

                    title: 'Notifications',

                    subtitle: _notifications
                        ? 'Notifications are enabled'
                        : 'Notifications are disabled',

                    trailing: Switch(
                      value: _notifications,
                      onChanged: _changeNotifications,
                    ),
                  ),

                  // =================================================
                  // DARK MODE
                  // =================================================
                  _settingTile(
                    icon: Icons.dark_mode_outlined,

                    title: 'Dark Mode',

                    subtitle: _darkMode
                        ? 'Dark mode is enabled'
                        : 'Light mode preference is enabled',

                    trailing: Switch(
                      value: _darkMode,
                      onChanged: _changeDarkMode,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // GENERAL
                  // =================================================
                  Text(
                    'General',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =================================================
                  // ABOUT
                  // =================================================
                  _settingTile(
                    icon: Icons.info_outline,

                    title: 'About RoadCare',

                    subtitle: 'Application information and version',

                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),

                    onTap: _showAbout,
                  ),

                  // =================================================
                  // RESET
                  // =================================================
                  _settingTile(
                    icon: Icons.restore,

                    title: 'Reset Settings',

                    subtitle: 'Restore application settings to default',

                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),

                    onTap: _resetSettings,
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // LOCAL STORAGE INFORMATION
                  // =================================================
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(
                        alpha: isDark ? 0.15 : 0.08,
                      ),

                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: colorScheme.primary,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            'Your settings are stored locally on this device.',

                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
