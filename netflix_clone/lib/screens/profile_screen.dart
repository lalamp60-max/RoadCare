import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/language_service.dart';
import 'my_list_screen.dart';
import 'signin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String profileName = 'Netflix User';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final savedName = prefs.getString('selected_profile_name');

    if (!mounted) return;

    setState(() {
      profileName = savedName ?? 'Netflix User';
    });
  }

  String text(String english, String telugu) {
    return LanguageService.text(english, telugu);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.language,
      builder: (context, language, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              text('Profile', 'ప్రొఫైల్'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // PROFILE HEADER
                _buildProfileHeader(),

                const SizedBox(height: 30),

                // ACCOUNT
                _buildSectionTitle(text('Account', 'అకౌంట్')),

                const SizedBox(height: 10),

                _buildSettingTile(
                  icon: Icons.person_outline,
                  title: text('Account', 'అకౌంట్'),
                  subtitle: text(
                    'Manage your account settings',
                    'మీ అకౌంట్ సెట్టింగ్స్‌ను నిర్వహించండి',
                  ),
                  onTap: _showAccountDialog,
                ),

                _buildSettingTile(
                  icon: Icons.playlist_add_check,
                  title: text('My List', 'నా జాబితా'),
                  subtitle: text(
                    'View movies saved for later',
                    'తర్వాత చూడటానికి సేవ్ చేసిన సినిమాలు',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyListScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                // SETTINGS
                _buildSectionTitle(text('Settings', 'సెట్టింగ్స్')),

                const SizedBox(height: 10),

                _buildSettingTile(
                  icon: Icons.notifications_none,
                  title: text('Notifications', 'నోటిఫికేషన్స్'),
                  subtitle: text(
                    'Manage notification preferences',
                    'నోటిఫికేషన్ ప్రాధాన్యతలను నిర్వహించండి',
                  ),
                  onTap: _showNotificationsDialog,
                ),

                _buildSettingTile(
                  icon: Icons.language,
                  title: text('Language', 'భాష'),
                  subtitle: LanguageService.language.value,
                  onTap: _showLanguageDialog,
                ),

                _buildSettingTile(
                  icon: Icons.dark_mode_outlined,
                  title: text('Appearance', 'అపియరెన్స్'),
                  subtitle: text('Dark mode', 'డార్క్ మోడ్'),
                  onTap: _showAppearanceDialog,
                ),

                const SizedBox(height: 25),

                // ABOUT
                _buildSectionTitle(text('About', 'గురించి')),

                const SizedBox(height: 10),

                _buildSettingTile(
                  icon: Icons.info_outline,
                  title: text('About App', 'యాప్ గురించి'),
                  subtitle: text(
                    'Netflix-style Flutter application',
                    'Netflix తరహా Flutter అప్లికేషన్',
                  ),
                  onTap: _showAboutDialog,
                ),

                const SizedBox(height: 30),

                // LOGOUT
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showLogoutDialog,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: Text(
                      text('Logout', 'లాగ్ అవుట్'),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  'Netflix Clone • Flutter',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 95,
          height: 95,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'N',
              style: TextStyle(
                color: Colors.white,
                fontSize: 55,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          profileName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Netflix Member',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.red),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      ),
    );
  }

  // ------------------------------------------------------------
  // LANGUAGE
  // ------------------------------------------------------------

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181818),
          title: Text(
            text('Choose Language', 'భాషను ఎంచుకోండి'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _languageOption(
                dialogContext: dialogContext,
                languageName: 'English',
                displayName: 'English',
                isSelected: LanguageService.isEnglish,
              ),
              const SizedBox(height: 10),
              _languageOption(
                dialogContext: dialogContext,
                languageName: 'Telugu',
                displayName: 'తెలుగు',
                isSelected: LanguageService.isTelugu,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption({
    required BuildContext dialogContext,
    required String languageName,
    required String displayName,
    required bool isSelected,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        await LanguageService.setLanguage(languageName);

        if (!dialogContext.mounted) return;

        Navigator.pop(dialogContext);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.red.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.red
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              languageName == 'English' ? Icons.language : Icons.translate,
              color: isSelected ? Colors.red : Colors.white60,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.red),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ACCOUNT
  // ------------------------------------------------------------

  void _showAccountDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181818),
          title: Text(
            text('Account', 'అకౌంట్'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            text(
              'You are currently using the Netflix Clone application.',
              'మీరు ప్రస్తుతం Netflix Clone అప్లికేషన్‌ను ఉపయోగిస్తున్నారు.',
            ),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                text('OK', 'సరే'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // NOTIFICATIONS
  // ------------------------------------------------------------

  void _showNotificationsDialog() {
    bool notificationsEnabled = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF181818),
              title: Text(
                text('Notifications', 'నోటిఫికేషన్స్'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  text('Enable Notifications', 'నోటిఫికేషన్స్ ప్రారంభించండి'),
                  style: const TextStyle(color: Colors.white),
                ),
                value: notificationsEnabled,
                activeThumbColor: Colors.red,
                onChanged: (value) {
                  setDialogState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    text('Done', 'పూర్తయింది'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // APPEARANCE
  // ------------------------------------------------------------

  void _showAppearanceDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181818),
          title: Text(
            text('Appearance', 'అపియరెన్స్'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode, color: Colors.red),
                title: Text(
                  text('Dark Mode', 'డార్క్ మోడ్'),
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.check, color: Colors.red),
              ),
              ListTile(
                leading: const Icon(Icons.light_mode, color: Colors.white54),
                title: Text(
                  text('Light Mode', 'లైట్ మోడ్'),
                  style: const TextStyle(color: Colors.white54),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        text(
                          'Dark mode is enabled for this app.',
                          'ఈ యాప్‌లో డార్క్ మోడ్ ప్రారంభించబడింది.',
                        ),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // ABOUT
  // ------------------------------------------------------------

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181818),
          title: const Text(
            'Netflix Clone',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(
            text(
              'A Netflix-style streaming application developed using Flutter. '
                  'It includes profiles, movie browsing, search, movie details, '
                  'video playback, My List and language support.',
              'Flutter ఉపయోగించి రూపొందించిన Netflix తరహా streaming application. '
                  'ఇందులో profiles, movie browsing, search, movie details, '
                  'video playback, My List మరియు language support ఉన్నాయి.',
            ),
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                text('Close', 'మూసివేయి'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181818),
          title: Text(
            text('Logout', 'లాగ్ అవుట్'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            text(
              'Are you sure you want to logout?',
              'మీరు ఖచ్చితంగా లాగ్ అవుట్ కావాలనుకుంటున్నారా?',
            ),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                text('Cancel', 'రద్దు'),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();

                await prefs.setBool('is_signed_in', false);

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (route) => false,
                );
              },
              child: Text(
                text('Logout', 'లాగ్ అవుట్'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
