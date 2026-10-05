import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/road_report.dart';
import '../../repositories/report_repository.dart';
import '../../widgets/roadcare_photo_layout.dart';

class ReportDamageScreen extends StatefulWidget {
  final int userId;

  const ReportDamageScreen({super.key, required this.userId});

  @override
  State<ReportDamageScreen> createState() => _ReportDamageScreenState();
}

class _ReportDamageScreenState extends State<ReportDamageScreen> {
  // =========================================================
  // FORM
  // =========================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  // =========================================================
  // SERVICES
  // =========================================================

  final ReportRepository _reportRepository = ReportRepository();

  final ImagePicker _imagePicker = ImagePicker();

  // =========================================================
  // FORM VALUES
  // =========================================================

  String _damageType = 'Pothole';

  String _severity = 'Medium';

  // =========================================================
  // STATES
  // =========================================================

  bool _isSubmitting = false;

  bool _isGettingLocation = false;

  bool _isPickingImage = false;

  bool _isRestoringDraft = true;

  bool _isNavigating = false;

  // =========================================================
  // LOCATION
  // =========================================================

  double? _latitude;

  double? _longitude;

  // =========================================================
  // IMAGE
  // =========================================================

  XFile? _selectedPhoto;

  Uint8List? _selectedPhotoBytes;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _initializeScreen();
  }

  // =========================================================
  // INITIALIZE
  // =========================================================

  Future<void> _initializeScreen() async {
    try {
      await _recoverLostImage();

      await _restoreDraft();
    } catch (e) {
      debugPrint('Screen initialization error: $e');
    }

    if (!mounted) return;

    setState(() {
      _isRestoringDraft = false;
    });
  }

  // =========================================================
  // SAVE DRAFT BEFORE CAMERA
  // =========================================================

  Future<void> _saveDraftBeforeCamera() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setBool('roadcare_pending_camera', true);

      await prefs.setInt('roadcare_pending_user_id', widget.userId);

      await prefs.setString('roadcare_draft_title', _titleController.text);

      await prefs.setString(
        'roadcare_draft_description',
        _descriptionController.text,
      );

      await prefs.setString('roadcare_draft_address', _addressController.text);

      await prefs.setString('roadcare_draft_damage_type', _damageType);

      await prefs.setString('roadcare_draft_severity', _severity);

      if (_latitude != null) {
        await prefs.setDouble('roadcare_draft_latitude', _latitude!);
      } else {
        await prefs.remove('roadcare_draft_latitude');
      }

      if (_longitude != null) {
        await prefs.setDouble('roadcare_draft_longitude', _longitude!);
      } else {
        await prefs.remove('roadcare_draft_longitude');
      }
    } catch (e) {
      debugPrint('Draft save error: $e');
    }
  }

  // =========================================================
  // RESTORE DRAFT
  // =========================================================

  Future<void> _restoreDraft() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final bool pendingCamera =
          prefs.getBool('roadcare_pending_camera') ?? false;

      final int? pendingUserId = prefs.getInt('roadcare_pending_user_id');

      if (!pendingCamera || pendingUserId != widget.userId) {
        return;
      }

      _titleController.text = prefs.getString('roadcare_draft_title') ?? '';

      _descriptionController.text =
          prefs.getString('roadcare_draft_description') ?? '';

      _addressController.text = prefs.getString('roadcare_draft_address') ?? '';

      const List<String> damageTypes = [
        'Pothole',
        'Crack',
        'Damaged Road',
        'Water Logging',
        'Broken Road Edge',
        'Other',
      ];

      final String savedDamageType =
          prefs.getString('roadcare_draft_damage_type') ?? 'Pothole';

      if (damageTypes.contains(savedDamageType)) {
        _damageType = savedDamageType;
      }

      const List<String> severities = ['Low', 'Medium', 'High', 'Critical'];

      final String savedSeverity =
          prefs.getString('roadcare_draft_severity') ?? 'Medium';

      if (severities.contains(savedSeverity)) {
        _severity = savedSeverity;
      }

      _latitude = prefs.getDouble('roadcare_draft_latitude');

      _longitude = prefs.getDouble('roadcare_draft_longitude');
    } catch (e) {
      debugPrint('Draft restore error: $e');
    }
  }

  // =========================================================
  // CLEAR CAMERA DRAFT
  // =========================================================

  Future<void> _clearCameraDraft() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.remove('roadcare_pending_camera');

      await prefs.remove('roadcare_pending_user_id');

      await prefs.remove('roadcare_draft_title');

      await prefs.remove('roadcare_draft_description');

      await prefs.remove('roadcare_draft_address');

      await prefs.remove('roadcare_draft_damage_type');

      await prefs.remove('roadcare_draft_severity');

      await prefs.remove('roadcare_draft_latitude');

      await prefs.remove('roadcare_draft_longitude');
    } catch (e) {
      debugPrint('Draft clear error: $e');
    }
  }

  // =========================================================
  // IMAGE PICKER
  // =========================================================

  Future<void> _pickImageFromGallery() async {
    if (_isSubmitting || _isPickingImage) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
        requestFullMetadata: false,
      );

      if (image == null) {
        return;
      }

      final Uint8List bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedPhoto = image;
        _selectedPhotoBytes = bytes;
        _isPickingImage = false;
      });

      _showSuccessMessage('Photo added successfully!');
    } catch (e) {
      debugPrint('Gallery error: $e');

      if (!mounted) return;

      setState(() {
        _isPickingImage = false;
      });

      _showErrorMessage('Unable to select photo. Please try again.');
    }
  }

  // =========================================================
  // CAMERA
  // =========================================================

  Future<void> _takePhoto() async {
    if (_isSubmitting || _isPickingImage) {
      return;
    }

    // Camera draft is useful on Android.
    if (!kIsWeb) {
      await _saveDraftBeforeCamera();
    }

    if (!mounted) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
        requestFullMetadata: false,
      );

      if (image == null) {
        if (!mounted) return;

        setState(() {
          _isPickingImage = false;
        });

        if (!kIsWeb) {
          await _clearCameraDraft();
        }

        return;
      }

      final Uint8List bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedPhoto = image;
        _selectedPhotoBytes = bytes;
        _isPickingImage = false;
      });

      _showSuccessMessage('Photo captured successfully!');
    } catch (e) {
      debugPrint('Camera error: $e');

      if (!mounted) return;

      setState(() {
        _isPickingImage = false;
      });

      _showErrorMessage('Unable to capture photo. Please try again.');
    }
  }

  // =========================================================
  // LOST IMAGE RECOVERY
  // =========================================================

  Future<void> _recoverLostImage() async {
    // Lost-data recovery is mainly useful for Android.
    if (kIsWeb) {
      return;
    }

    try {
      final LostDataResponse response = await _imagePicker.retrieveLostData();

      if (response.isEmpty) {
        return;
      }

      XFile? image;

      if (response.files != null && response.files!.isNotEmpty) {
        image = response.files!.first;
      }

      if (image == null) {
        return;
      }

      final Uint8List bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedPhoto = image;
        _selectedPhotoBytes = bytes;
        _isPickingImage = false;
      });

      _showSuccessMessage('Photo recovered successfully!');
    } catch (e) {
      debugPrint('Lost image recovery error: $e');

      if (!mounted) return;

      setState(() {
        _isPickingImage = false;
      });
    }
  }

  // =========================================================
  // PHOTO SOURCE DIALOG
  // =========================================================

  void _showImageSourceDialog() {
    if (_isSubmitting || _isPickingImage) {
      return;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(sheetContext).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Add Photo Evidence',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // CAMERA
                // =================================================
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  title: const Text(
                    'Take Photo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Capture road damage using camera'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();

                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (mounted) {
                        _takePhoto();
                      }
                    });
                  },
                ),

                const SizedBox(height: 8),

                // =================================================
                // DEVICE / GALLERY
                // =================================================
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.folder_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    kIsWeb ? 'Choose From Computer' : 'Choose From Gallery',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    kIsWeb
                        ? 'Select an image from your computer'
                        : 'Select an existing road damage photo',
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();

                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (mounted) {
                        _pickImageFromGallery();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // REMOVE PHOTO
  // =========================================================

  void _removeImage() {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _selectedPhoto = null;
      _selectedPhotoBytes = null;
    });

    _showSuccessMessage('Photo removed.');
  }

  // =========================================================
  // LOCATION
  // =========================================================

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation || _isSubmitting || _isPickingImage) {
      return;
    }

    setState(() {
      _isGettingLocation = true;
    });

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          _isGettingLocation = false;
        });

        _showErrorMessage('Location service is disabled. Please turn on GPS.');

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        setState(() {
          _isGettingLocation = false;
        });

        _showErrorMessage('Location permission was denied.');

        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          _isGettingLocation = false;
        });

        _showErrorMessage(
          'Location permission is permanently denied. '
          'Please enable it from app settings.',
        );

        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;

        _longitude = position.longitude;

        _addressController.text =
            'Latitude: '
            '${position.latitude.toStringAsFixed(6)}, '
            'Longitude: '
            '${position.longitude.toStringAsFixed(6)}';

        _isGettingLocation = false;
      });

      _showSuccessMessage('Current location captured successfully!');
    } catch (e) {
      debugPrint('Location error: $e');

      if (!mounted) return;

      setState(() {
        _isGettingLocation = false;
      });

      _showErrorMessage('Unable to get current location. Please try again.');
    }
  }

  // =========================================================
  // SAVE IMAGE FOR MOBILE
  // =========================================================

  Future<String?> _saveImageForMobile(XFile image) async {
    if (kIsWeb) {
      return image.path;
    }

    try {
      final Directory appDir = await getApplicationDocumentsDirectory();

      final Directory reportImagesDir = Directory(
        '${appDir.path}/roadcare_reports',
      );

      if (!await reportImagesDir.exists()) {
        await reportImagesDir.create(recursive: true);
      }

      String extension = '.jpg';

      final String lowerPath = image.path.toLowerCase();

      if (lowerPath.endsWith('.png')) {
        extension = '.png';
      } else if (lowerPath.endsWith('.webp')) {
        extension = '.webp';
      } else if (lowerPath.endsWith('.jpeg')) {
        extension = '.jpeg';
      }

      final String fileName =
          'road_${DateTime.now().millisecondsSinceEpoch}'
          '$extension';

      final String newPath = '${reportImagesDir.path}/$fileName';

      final File sourceFile = File(image.path);

      if (await sourceFile.exists()) {
        final File copiedFile = await sourceFile.copy(newPath);

        return copiedFile.path;
      }

      final List<int> bytes = await image.readAsBytes();

      final File newFile = File(newPath);

      await newFile.writeAsBytes(bytes, flush: true);

      return newFile.path;
    } catch (e) {
      debugPrint('Image save error: $e');

      return null;
    }
  }

  // =========================================================
  // SUBMIT REPORT
  // =========================================================

  Future<void> _submitReport() async {
    if (_isSubmitting ||
        _isPickingImage ||
        _isRestoringDraft ||
        _isNavigating) {
      return;
    }

    FocusScope.of(context).unfocus();

    // -------------------------------------------------------
    // VALIDATE FORM
    // -------------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // -------------------------------------------------------
    // GPS REQUIRED
    // -------------------------------------------------------

    if (_latitude == null || _longitude == null) {
      _showErrorMessage('Please capture your current GPS location.');

      return;
    }

    // -------------------------------------------------------
    // PHOTO REQUIRED
    // -------------------------------------------------------

    if (_selectedPhoto == null || _selectedPhotoBytes == null) {
      _showErrorMessage('Please add a photo of the road damage.');

      return;
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // -----------------------------------------------------
      // SAVE IMAGE
      // -----------------------------------------------------

      final String? imagePath = await _saveImageForMobile(_selectedPhoto!);

      if (imagePath == null || imagePath.isEmpty) {
        throw Exception('Unable to save selected image');
      }

      // -----------------------------------------------------
      // CURRENT TIME
      // -----------------------------------------------------

      final String now = DateTime.now().toIso8601String();

      // -----------------------------------------------------
      // CREATE REPORT
      // -----------------------------------------------------

      final RoadReport report = RoadReport(
        userId: widget.userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        damageType: _damageType,
        severity: _severity,
        latitude: _latitude,
        longitude: _longitude,
        address: _addressController.text.trim(),
        status: 'Pending',
        createdAt: now,
        updatedAt: now,
      );

      // -----------------------------------------------------
      // DATABASE
      // -----------------------------------------------------

      debugPrint('Submitting report...');

      debugPrint('Image path: $imagePath');

      final int reportId = await _reportRepository.createReport(
        report,
        imagePath: imagePath,
      );

      debugPrint('Report ID: $reportId');

      if (!mounted) return;

      if (reportId > 0) {
        // ---------------------------------------------------
        // CLEAR DRAFT
        // ---------------------------------------------------

        await _clearCameraDraft();

        if (!mounted) return;

        setState(() {
          _isSubmitting = false;
          _isNavigating = true;
        });

        // ---------------------------------------------------
        // RETURN TO PREVIOUS SCREEN
        // ---------------------------------------------------

        Navigator.of(context).pop(true);

        return;
      }

      // -----------------------------------------------------
      // FAILED
      // -----------------------------------------------------

      setState(() {
        _isSubmitting = false;
      });

      _showErrorMessage('Failed to submit report. Please try again.');
    } catch (e, stackTrace) {
      debugPrint('Submit Report Error: $e');

      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _isNavigating = false;
      });

      _showErrorMessage('Failed to submit report. Please try again.');
    }
  }

  // =========================================================
  // SUCCESS MESSAGE
  // =========================================================

  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // =========================================================
  // ERROR MESSAGE
  // =========================================================

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // =========================================================
  // INPUT DECORATION
  // =========================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      prefixIcon: Icon(icon, color: colorScheme.primary),
      filled: true,
      fillColor: theme.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
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
  // IMAGE PREVIEW
  // =========================================================

  Widget _buildImagePreview() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_selectedPhotoBytes == null) {
      return Container(
        height: 230,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 50,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 8),
            Text('Unable to preview image'),
          ],
        ),
      );
    }

    // IMPORTANT:
    // Image.memory works on Chrome/Web
    // AND Android/iOS.
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.memory(
        _selectedPhotoBytes!,
        width: double.infinity,
        height: 230,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 230,
            alignment: Alignment.center,
            color: colorScheme.surfaceContainerHighest,
            child: Text(
              'Unable to preview image',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          );
        },
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
    final TextStyle sectionHeadingStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        surfaceTintColor: theme.appBarTheme.surfaceTintColor,
        elevation: 0,
        title: Text(
          'Report Road Damage',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      body: Column(
        children: [
          const RoadCarePhotoHeader(
            imageAsset: 'assets/images/road-repair.jpg',
            eyebrow: 'Report with confidence',
            title: 'Help fix a road hazard.',
            description:
                'Add a photo and GPS location so the right team can find it.',
            height: 235,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const SizedBox(height: 8),

                      // =================================================
                      // TITLE
                      // =================================================
                      Text('Report Title', style: sectionHeadingStyle),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(color: colorScheme.onSurface),
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          hintText: 'Example: Large pothole near main road',
                          icon: Icons.title,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a report title';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 22),

                      // =================================================
                      // DAMAGE TYPE
                      // =================================================
                      Text('Damage Type', style: sectionHeadingStyle),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        initialValue: _damageType,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: _inputDecoration(
                          hintText: 'Select damage type',
                          icon: Icons.construction_outlined,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Pothole',
                            child: Text('Pothole'),
                          ),
                          DropdownMenuItem(
                            value: 'Crack',
                            child: Text('Road Crack'),
                          ),
                          DropdownMenuItem(
                            value: 'Damaged Road',
                            child: Text('Damaged Road'),
                          ),
                          DropdownMenuItem(
                            value: 'Water Logging',
                            child: Text('Water Logging'),
                          ),
                          DropdownMenuItem(
                            value: 'Broken Road Edge',
                            child: Text('Broken Road Edge'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: _isSubmitting || _isPickingImage
                            ? null
                            : (value) {
                                if (value == null) {
                                  return;
                                }

                                setState(() {
                                  _damageType = value;
                                });
                              },
                      ),

                      const SizedBox(height: 22),

                      // =================================================
                      // SEVERITY
                      // =================================================
                      Text('Severity', style: sectionHeadingStyle),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        initialValue: _severity,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: _inputDecoration(
                          hintText: 'Select severity',
                          icon: Icons.warning_amber_outlined,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Low', child: Text('Low')),
                          DropdownMenuItem(
                            value: 'Medium',
                            child: Text('Medium'),
                          ),
                          DropdownMenuItem(value: 'High', child: Text('High')),
                          DropdownMenuItem(
                            value: 'Critical',
                            child: Text('Critical'),
                          ),
                        ],
                        onChanged: _isSubmitting || _isPickingImage
                            ? null
                            : (value) {
                                if (value == null) {
                                  return;
                                }

                                setState(() {
                                  _severity = value;
                                });
                              },
                      ),

                      const SizedBox(height: 22),

                      // =================================================
                      // DESCRIPTION
                      // =================================================
                      Text('Description', style: sectionHeadingStyle),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Describe the road damage in detail...',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 80),
                            child: Icon(
                              Icons.description_outlined,
                              color: colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please describe the road damage';
                          }

                          if (value.trim().length < 10) {
                            return 'Please provide more details';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 22),

                      // =================================================
                      // LOCATION
                      // =================================================
                      Text('Location', style: sectionHeadingStyle),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        style: TextStyle(color: colorScheme.onSurface),
                        readOnly: _latitude != null,
                        decoration: InputDecoration(
                          hintText: 'Enter road location or use GPS',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                            color: colorScheme.primary,
                          ),
                          suffixIcon: _isGettingLocation
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  onPressed: _isSubmitting || _isPickingImage
                                      ? null
                                      : _getCurrentLocation,
                                  icon: Icon(
                                    Icons.my_location,
                                    color: colorScheme.primary,
                                  ),
                                ),
                          filled: true,
                          fillColor: theme.cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the location';
                          }

                          return null;
                        },
                      ),

                      if (_latitude != null && _longitude != null) ...[
                        const SizedBox(height: 10),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.gps_fixed, color: Colors.green),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'GPS: '
                                  '${_latitude!.toStringAsFixed(6)}, '
                                  '${_longitude!.toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 25),

                      // =================================================
                      // PHOTO
                      // =================================================
                      Text('Photo Evidence', style: sectionHeadingStyle),

                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.blue.shade50),
                        ),
                        child: Column(
                          children: [
                            // =================================================
                            // NO IMAGE
                            // =================================================

                            if (_selectedPhotoBytes == null) ...[
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 45,
                                color: colorScheme.primary,
                              ),

                              const SizedBox(height: 10),

                              Text(
                                'Add Photo Evidence',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                kIsWeb
                                    ? 'Choose an image from your computer or use a camera.'
                                    : 'Take a photo or choose one from your gallery.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 15),

                              OutlinedButton.icon(
                                onPressed:
                                    _isRestoringDraft ||
                                        _isSubmitting ||
                                        _isPickingImage
                                    ? null
                                    : _showImageSourceDialog,
                                icon: _isPickingImage
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.add_a_photo_outlined),
                                label: Text(
                                  _isPickingImage ? 'Opening...' : 'Add Photo',
                                ),
                              ),
                            ]
                            // =================================================
                            // IMAGE SELECTED
                            // =================================================
                            else ...[
                              _buildImagePreview(),

                              const SizedBox(height: 12),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Photo added successfully!',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          _isSubmitting || _isPickingImage
                                          ? null
                                          : _showImageSourceDialog,
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Change'),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _isSubmitting
                                          ? null
                                          : _removeImage,
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Remove'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // =================================================
                      // SUBMIT
                      // =================================================
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isSubmitting ||
                                  _isPickingImage ||
                                  _isRestoringDraft ||
                                  _isNavigating
                              ? null
                              : _submitReport,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_outlined),
                          label: Text(
                            _isSubmitting ? 'Submitting...' : 'Submit Report',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: colorScheme.primary
                                .withValues(alpha: 0.55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        'User ID: ${widget.userId}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _titleController.dispose();

    _descriptionController.dispose();

    _addressController.dispose();

    super.dispose();
  }
}
