import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  static const String profilesKey = 'profiles';
  static const String selectedProfileKey = 'selected_profile_name';

  List<Map<String, dynamic>> profiles = [];

  String? selectedProfileName;

  bool isLoading = true;

  final List<Color> profileColors = [
    Colors.red,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.green,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  final List<IconData> profileIcons = [
    Icons.face_rounded,
    Icons.person_rounded,
    Icons.child_care_rounded,
    Icons.star_rounded,
    Icons.rocket_launch_rounded,
    Icons.sports_esports_rounded,
    Icons.music_note_rounded,
    Icons.pets_rounded,
  ];

  @override
  void initState() {
    super.initState();
    loadProfiles();
  }

  // ============================================================
  // LOAD PROFILES
  // ============================================================

  Future<void> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();

    final savedProfiles = prefs.getStringList(profilesKey);

    if (savedProfiles == null || savedProfiles.isEmpty) {
      profiles = [
        {
          'name': 'Padmini',
          'color': Colors.red.toARGB32(),
          'icon': Icons.face_rounded.codePoint,
        },
        {
          'name': 'Guest',
          'color': Colors.blue.toARGB32(),
          'icon': Icons.person_rounded.codePoint,
        },
        {
          'name': 'Kids',
          'color': Colors.orange.toARGB32(),
          'icon': Icons.child_care_rounded.codePoint,
        },
      ];

      await saveProfiles();
    } else {
      profiles = savedProfiles.map((profile) {
        final decoded = jsonDecode(profile) as Map<String, dynamic>;

        return Map<String, dynamic>.from(decoded);
      }).toList();
    }

    final savedSelected = prefs.getString(selectedProfileKey);

    if (savedSelected != null &&
        profiles.any(
          (profile) => profile['name'].toString() == savedSelected,
        )) {
      selectedProfileName = savedSelected;
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  // ============================================================
  // SAVE ALL PROFILES
  // ============================================================

  Future<void> saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();

    final savedProfiles = profiles
        .map((profile) => jsonEncode(profile))
        .toList();

    await prefs.setStringList(profilesKey, savedProfiles);
  }

  // ============================================================
  // SAVE SELECTED PROFILE
  // ============================================================

  Future<void> saveSelectedProfile(String profileName) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(selectedProfileKey, profileName);
  }

  // ============================================================
  // CONTINUE TO HOME
  // ============================================================

  Future<void> continueToHome() async {
    if (selectedProfileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a profile first.'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final profileName = selectedProfileName!;

    await saveSelectedProfile(profileName);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(profileName: profileName),
      ),
    );
  }

  // ============================================================
  // ADD PROFILE
  // ============================================================

  Future<void> addProfile() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff181818),
          title: const Text(
            'Add Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 20,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter profile name',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(
                Icons.person_outline,
                color: Colors.white54,
              ),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isEmpty) {
                  return;
                }

                Navigator.pop(context, name);
              },
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.trim().isEmpty) {
      return;
    }

    final name = result.trim();

    final alreadyExists = profiles.any(
      (profile) =>
          profile['name'].toString().toLowerCase() == name.toLowerCase(),
    );

    if (alreadyExists) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A profile with this name already exists.'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final colorIndex = profiles.length % profileColors.length;
    final iconIndex = profiles.length % profileIcons.length;

    setState(() {
      profiles.add({
        'name': name,
        'color': profileColors[colorIndex].toARGB32(),
        'icon': profileIcons[iconIndex].codePoint,
      });
    });

    await saveProfiles();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name profile added successfully.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  Future<void> editProfile(int index) async {
    final oldName = profiles[index]['name'].toString();

    final controller = TextEditingController(text: oldName);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff181818),
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 20,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Profile name',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(
                Icons.edit_outlined,
                color: Colors.white54,
              ),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isEmpty) {
                  return;
                }

                Navigator.pop(context, name);
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.trim().isEmpty) {
      return;
    }

    final newName = result.trim();

    final duplicate = profiles.asMap().entries.any((entry) {
      if (entry.key == index) {
        return false;
      }

      return entry.value['name'].toString().toLowerCase() ==
          newName.toLowerCase();
    });

    if (duplicate) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Another profile already has this name.'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      profiles[index]['name'] = newName;

      if (selectedProfileName == oldName) {
        selectedProfileName = newName;
      }
    });

    await saveProfiles();

    if (selectedProfileName == newName) {
      await saveSelectedProfile(newName);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ============================================================
  // DELETE PROFILE
  // ============================================================

  Future<void> deleteProfile(int index) async {
    if (profiles.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one profile must remain.'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final profileName = profiles[index]['name'].toString();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff181818),
          title: const Text(
            'Delete Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "$profileName"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final wasSelected = selectedProfileName == profileName;

    setState(() {
      profiles.removeAt(index);

      if (wasSelected) {
        selectedProfileName = null;
      }
    });

    await saveProfiles();

    final prefs = await SharedPreferences.getInstance();

    if (wasSelected) {
      await prefs.remove(selectedProfileKey);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$profileName profile deleted.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ============================================================
  // MANAGE PROFILES
  // ============================================================

  Future<void> manageProfiles() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff181818),
          title: const Text(
            'Manage Profiles',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 450,
            child: profiles.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No profiles available.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {
                      final profile = profiles[index];

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        leading: profileAvatar(profile, size: 45),
                        title: Text(
                          profile['name'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () async {
                                Navigator.pop(context);

                                await editProfile(index);

                                if (!mounted) {
                                  return;
                                }

                                await manageProfiles();
                              },
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.white70,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () async {
                                Navigator.pop(context);

                                await deleteProfile(index);

                                if (!mounted) {
                                  return;
                                }

                                await manageProfiles();
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PROFILE AVATAR
  // ============================================================

  Widget profileAvatar(Map<String, dynamic> profile, {double size = 100}) {
    final color = Color(profile['color'] as int);

    final icon = IconData(profile['icon'] as int, fontFamily: 'MaterialIcons');

    final isSelected = selectedProfileName == profile['name'].toString();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.15),
        border: Border.all(
          color: isSelected ? Colors.white : Colors.transparent,
          width: isSelected ? 4 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.48),
    );
  }

  // ============================================================
  // PROFILE ITEM
  // ============================================================

  Widget profileItem(Map<String, dynamic> profile) {
    final name = profile['name'].toString();

    final isSelected = selectedProfileName == name;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedProfileName = name;
        });
      },
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
          width: 120,
          child: Column(
            children: [
              profileAvatar(profile, size: 100),
              const SizedBox(height: 12),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Icon(Icons.check_circle, color: Colors.red, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
            child: Column(
              children: [
                // Netflix-style N
                const Text(
                  'N',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 65,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Who's watching?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 45),

                // Profiles
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 30,
                  runSpacing: 30,
                  children: [
                    ...profiles.map((profile) => profileItem(profile)),

                    // Add Profile
                    GestureDetector(
                      onTap: addProfile,
                      child: SizedBox(
                        width: 120,
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white70,
                                size: 45,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Add Profile',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // Continue
                SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: continueToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Manage Profiles
                OutlinedButton.icon(
                  onPressed: manageProfiles,
                  icon: const Icon(
                    Icons.manage_accounts,
                    color: Colors.white70,
                  ),
                  label: const Text(
                    'Manage Profiles',
                    style: TextStyle(color: Colors.white70),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                Text(
                  'Netflix Clone • Flutter Project',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
