import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/road_report.dart';

class FeedbackScreen extends StatefulWidget {
  final RoadReport report;
  final int userId;

  const FeedbackScreen({super.key, required this.report, required this.userId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // =========================================================
  // CONTROLLERS
  // =========================================================

  final TextEditingController _commentController = TextEditingController();

  // =========================================================
  // STATE
  // =========================================================

  int _selectedRating = 0;

  int? _feedbackId;

  bool _isLoading = true;

  bool _isSubmitting = false;

  // =========================================================
  // THEME
  // =========================================================

  Color get _cardColor => Theme.of(context).cardColor;

  Color get _textColor => Theme.of(context).colorScheme.onSurface;

  Color get _secondaryTextColor =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  Color get _primaryColor => Theme.of(context).colorScheme.primary;

  Color get _iconBackgroundColor =>
      Theme.of(context).colorScheme.primaryContainer;

  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadExistingFeedback();
  }

  // =========================================================
  // LOAD EXISTING FEEDBACK
  // =========================================================

  Future<void> _loadExistingFeedback() async {
    try {
      final Map<String, dynamic>? feedback = await DatabaseHelper.instance
          .getFeedbackByReport(
            userId: widget.userId,
            reportId: widget.report.id!,
          );

      if (!mounted) return;

      if (feedback != null) {
        setState(() {
          _feedbackId = feedback['id'] as int?;
          _selectedRating = feedback['rating'] as int? ?? 0;
          _commentController.text = feedback['comment'] as String? ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load feedback error: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Unable to load feedback.', isError: true);
    }
  }

  // =========================================================
  // SUBMIT FEEDBACK
  // =========================================================

  Future<void> _submitFeedback() async {
    FocusScope.of(context).unfocus();

    // -------------------------------------------------------
    // RATING REQUIRED
    // -------------------------------------------------------

    if (_selectedRating == 0) {
      _showMessage('Please select a rating.', isError: true);

      return;
    }

    // -------------------------------------------------------
    // COMMENT
    // -------------------------------------------------------

    final String comment = _commentController.text.trim();

    if (comment.isEmpty) {
      _showMessage('Please enter your feedback comment.', isError: true);

      return;
    }

    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      int result;

      // -----------------------------------------------------
      // UPDATE EXISTING FEEDBACK
      // -----------------------------------------------------

      if (_feedbackId != null) {
        result = await DatabaseHelper.instance.updateFeedback(
          feedbackId: _feedbackId!,
          rating: _selectedRating,
          comment: comment,
        );

        if (result > 0) {
          if (!mounted) return;

          setState(() {
            _isSubmitting = false;
          });

          _showMessage('Feedback updated successfully!');

          await Future.delayed(const Duration(milliseconds: 500));

          if (!mounted) return;

          Navigator.pop(context, true);

          return;
        }
      }

      // -----------------------------------------------------
      // INSERT NEW FEEDBACK
      // -----------------------------------------------------

      result = await DatabaseHelper.instance.insertFeedback(
        userId: widget.userId,
        reportId: widget.report.id!,
        rating: _selectedRating,
        comment: comment,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (result > 0) {
        _showMessage('Thank you! Your feedback was submitted.');

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        Navigator.pop(context, true);
      } else {
        _showMessage('Failed to submit feedback.', isError: true);
      }
    } catch (e) {
      debugPrint('Submit feedback error: $e');

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        'Unable to submit feedback. Please try again.',
        isError: true,
      );
    }
  }

  // =========================================================
  // STAR WIDGET
  // =========================================================

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final int starNumber = index + 1;

        return IconButton(
          tooltip: '$starNumber star',

          onPressed: () {
            setState(() {
              _selectedRating = starNumber;
            });
          },

          iconSize: 42,

          icon: Icon(
            starNumber <= _selectedRating ? Icons.star : Icons.star_border,
            color: starNumber <= _selectedRating
                ? Colors.amber
                : _secondaryTextColor,
          ),
        );
      }),
    );
  }

  // =========================================================
  // RATING TEXT
  // =========================================================

  String _ratingText() {
    switch (_selectedRating) {
      case 1:
        return 'Very Poor';

      case 2:
        return 'Poor';

      case 3:
        return 'Average';

      case 4:
        return 'Good';

      case 5:
        return 'Excellent';

      default:
        return 'Select your rating';
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Give Feedback',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,

        foregroundColor: _textColor,

        elevation: 0,
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // =================================================
                  // RESOLVED REPORT CARD
                  // =================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: _isDarkMode ? 0.30 : 0.08,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),

                              decoration: BoxDecoration(
                                color: _iconBackgroundColor,
                                borderRadius: BorderRadius.circular(14),
                              ),

                              child: Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 30,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    'Resolved Report',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _textColor,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    widget.report.title,
                                    style: TextStyle(
                                      color: _secondaryTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =================================================
                  // HEADING
                  // =================================================
                  Center(
                    child: Text(
                      _feedbackId != null
                          ? 'Update Your Feedback'
                          : 'How was the resolution?',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      'Rate your experience with the resolution of this report.',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: _secondaryTextColor,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =================================================
                  // RATING CARD
                  // =================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),

                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(20),

                      border: Border.all(
                        color: _isDarkMode
                            ? Colors.white10
                            : Colors.blue.shade50,
                      ),
                    ),

                    child: Column(
                      children: [
                        Text(
                          'Your Rating',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _buildRatingStars(),

                        const SizedBox(height: 5),

                        Text(
                          _ratingText(),
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // COMMENT
                  // =================================================
                  Text(
                    'Your Comments',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: _isDarkMode ? 0.20 : 0.05,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),

                    child: TextField(
                      controller: _commentController,

                      maxLines: 5,

                      maxLength: 500,

                      style: TextStyle(color: _textColor),

                      decoration: InputDecoration(
                        hintText: 'Tell us about your experience...',
                        hintStyle: TextStyle(color: _secondaryTextColor),

                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 8,
                            bottom: 75,
                          ),

                          child: Icon(
                            Icons.comment_outlined,
                            color: _primaryColor,
                          ),
                        ),

                        filled: true,

                        fillColor: Colors.transparent,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _primaryColor,
                            width: 1.5,
                          ),
                        ),

                        contentPadding: const EdgeInsets.all(18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =================================================
                  // SUBMIT BUTTON
                  // =================================================
                  SizedBox(
                    width: double.infinity,
                    height: 54,

                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitFeedback,

                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              _feedbackId != null ? Icons.update : Icons.send,
                            ),

                      label: Text(
                        _isSubmitting
                            ? 'Submitting...'
                            : _feedbackId != null
                            ? 'Update Feedback'
                            : 'Submit Feedback',

                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,

                        disabledBackgroundColor: _primaryColor.withValues(
                          alpha: 0.5,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =================================================
                  // INFO
                  // =================================================
                  Center(
                    child: Text(
                      'Your feedback helps improve RoadCare services.',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 12,
                        color: _secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _commentController.dispose();

    super.dispose();
  }
}
