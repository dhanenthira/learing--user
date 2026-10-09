import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/network/api_client.dart';
import 'practice_result_screen.dart';

class PracticeSessionScreen extends StatefulWidget {
  final String categoryId;
  final bool timerEnabled;

  const PracticeSessionScreen({
    super.key,
    required this.categoryId,
    this.timerEnabled = true,
  });

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  int _currentIndex = 0;
  int _secondsLeft = 600; // 10 mins
  Timer? _timer;
  bool _isLoading = true;

  // Selected answers: question_index -> option_string
  final Map<int, String> _selectedAnswers = {};
  final Set<int> _markedForReview = {};

  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> params = {};
      final cat = widget.categoryId.toLowerCase();
      if (cat != 'mixed' && cat.isNotEmpty) {
        params['category'] = cat;
      }
      final res = await ApiClient().dio.get("/questions", queryParameters: params);
      if (res.data != null && res.data is List && (res.data as List).isNotEmpty) {
        setState(() {
          _questions = List<Map<String, dynamic>>.from((res.data as List).map((q) => {
            "id": q["id"] ?? "",
            "title": q["title"] ?? "",
            "content": q["content"] ?? q["title"] ?? "",
            "category": (q["category"] ?? "Aptitude").toString().toUpperCase(),
            "options": List<String>.from(q["options"] ?? []),
            "correct": q["correct_answer"] ?? q["answer"] ?? "",
            "explanation": q["explanation"] ?? "",
          }));
          _isLoading = false;
        });
        if (_questions.isNotEmpty && widget.timerEnabled) {
          _startTimer();
        }
      } else {
        setState(() {
          _questions = [];
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _questions = [];
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        _submitPractice();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submitPractice() {
    _timer?.cancel();
    int correctCount = 0;
    List<Map<String, dynamic>> reviewData = [];

    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final selected = _selectedAnswers[i];
      final isCorrect = selected == q["correct"];
      if (isCorrect) correctCount++;

      reviewData.add({
        "title": q["title"],
        "content": q["content"],
        "selected": selected ?? "Skipped",
        "correct": q["correct"],
        "explanation": q["explanation"],
        "isCorrect": isCorrect,
      });
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => PracticeResultScreen(
          totalQuestions: _questions.length,
          correctCount: correctCount,
          timeSpentSeconds: 600 - _secondsLeft,
          reviews: reviewData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: const Text("Daily Practice", style: TextStyle(color: AppColors.textPrimary)),
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
            onPressed: () => context.go("/student/practice"),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AppCard(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.helpCircle, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      "No Questions in Database",
                      style: AppTypography.h4(context, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "There are currently no questions stored in the database for '${widget.categoryId}'. Only questions actually available in the database are displayed.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: "Back to Practice Hub",
                      variant: AppButtonVariant.primary,
                      onPressed: () => context.go("/student/practice"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final currentQ = _questions[_currentIndex];
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    final isMob = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Daily Practice • Question ${_currentIndex + 1} of ${_questions.length}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const Spacer(),
            if (widget.timerEnabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _secondsLeft < 120 ? AppColors.error.withOpacity(0.15) : AppColors.surfaceElevated,
                  borderRadius: AppRadii.badgeRadius,
                  border: Border.all(
                    color: _secondsLeft < 120 ? AppColors.error : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 16,
                      color: _secondsLeft < 120 ? AppColors.error : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _secondsLeft < 120 ? AppColors.error : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      body: Row(
        children: [
          // Main Question Workspace
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop,
                vertical: AppSpacing.space6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topic Badge & Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBadge(
                        label: currentQ["category"],
                        color: AppColors.primary.withOpacity(0.15),
                        textColor: AppColors.primaryLight,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _markedForReview.contains(_currentIndex)
                                  ? LucideIcons.bookmarkCheck
                                  : LucideIcons.bookmark,
                              color: _markedForReview.contains(_currentIndex)
                                  ? AppColors.warning
                                  : AppColors.textMuted,
                            ),
                            tooltip: "Mark for Review",
                            onPressed: () {
                              setState(() {
                                if (_markedForReview.contains(_currentIndex)) {
                                  _markedForReview.remove(_currentIndex);
                                } else {
                                  _markedForReview.add(_currentIndex);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space4),

                  // Problem Title & Content
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.space6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentQ["title"],
                          style: AppTypography.h3(context, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.space4),
                        Text(
                          currentQ["content"],
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space6),

                  // MCQ Options
                  Text("Select Correct Option:", style: AppTypography.labelLarge(context, color: AppColors.textMuted)),
                  const SizedBox(height: AppSpacing.space3),

                  ...List.generate(
                    (currentQ["options"] as List).length,
                    (optIdx) {
                      final optText = currentQ["options"][optIdx];
                      final isSelected = _selectedAnswers[_currentIndex] == optText;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedAnswers[_currentIndex] = optText;
                            });
                          },
                          borderRadius: AppRadii.cardStandardRadius,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.12)
                                  : AppColors.surface,
                              borderRadius: AppRadii.cardStandardRadius,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.border,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + optIdx),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? Colors.white : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    optText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.space6),

                  // Navigation Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppButton(
                        text: "Previous",
                        variant: AppButtonVariant.secondary,
                        icon: LucideIcons.arrowLeft,
                        onPressed: _currentIndex > 0
                            ? () => setState(() => _currentIndex--)
                            : null,
                      ),
                      Row(
                        children: [
                          if (_currentIndex < _questions.length - 1)
                            AppButton(
                              text: "Next",
                              variant: AppButtonVariant.primary,
                              icon: LucideIcons.arrowRight,
                              onPressed: () => setState(() => _currentIndex++),
                            )
                          else
                            AppButton(
                              text: "Finish & Submit",
                              variant: AppButtonVariant.primary,
                              icon: LucideIcons.checkCircle2,
                              onPressed: _submitPractice,
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Question Grid Drawer (Desktop Sidebar)
          if (!isMob)
            Container(
              width: 280,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(left: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.all(AppSpacing.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Question Palette", style: AppTypography.h4(context, color: AppColors.textPrimary)),
                  const SizedBox(height: AppSpacing.space4),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _questions.length,
                    itemBuilder: (ctx, idx) {
                      final isAnswered = _selectedAnswers.containsKey(idx);
                      final isReview = _markedForReview.contains(idx);
                      final isCurrent = idx == _currentIndex;

                      Color bg = AppColors.surfaceElevated;
                      Color textC = AppColors.textMuted;
                      Color borderC = AppColors.border;

                      if (isAnswered) {
                        bg = AppColors.success.withOpacity(0.2);
                        textC = AppColors.success;
                        borderC = AppColors.success;
                      } else if (isReview) {
                        bg = AppColors.warning.withOpacity(0.2);
                        textC = AppColors.warning;
                        borderC = AppColors.warning;
                      }

                      return InkWell(
                        onTap: () => setState(() => _currentIndex = idx),
                        borderRadius: AppRadii.badgeRadius,
                        child: Container(
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: AppRadii.badgeRadius,
                            border: Border.all(color: borderC, width: isCurrent ? 2 : 1),
                          ),
                          child: Center(
                            child: Text(
                              "${idx + 1}",
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textC),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  AppButton(
                    text: "Submit Practice",
                    variant: AppButtonVariant.primary,
                    width: double.infinity,
                    onPressed: _submitPractice,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
