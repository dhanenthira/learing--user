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
import 'test_result_screen.dart';

class TestActiveScreen extends StatefulWidget {
  final String testId;

  const TestActiveScreen({super.key, required this.testId});

  @override
  State<TestActiveScreen> createState() => _TestActiveScreenState();
}

class _TestActiveScreenState extends State<TestActiveScreen> {
  int _currentIndex = 0;
  int _secondsLeft = 1800; // 30 mins
  Timer? _timer;
  bool _isLoading = true;
  final Map<int, String> _selectedAnswers = {};
  final Set<int> _markedForReview = {};

  List<Map<String, dynamic>> _testQuestions = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get("/questions");
      if (res.data != null && res.data is List && (res.data as List).isNotEmpty) {
        setState(() {
          _testQuestions = List<Map<String, dynamic>>.from((res.data as List).map((q) => {
            "id": q["id"] ?? "",
            "title": q["title"] ?? "",
            "content": q["content"] ?? q["title"] ?? "",
            "options": List<String>.from(q["options"] ?? []),
            "correct": q["correct_answer"] ?? q["answer"] ?? "",
            "marks": q["marks"] ?? 10,
          }));
          _isLoading = false;
        });
        if (_testQuestions.isNotEmpty) {
          _startTimer();
        }
      } else {
        setState(() {
          _testQuestions = [];
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _testQuestions = [];
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
        _submitTest();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submitTest() {
    _timer?.cancel();
    int score = 0;
    int maxScore = 0;
    for (int i = 0; i < _testQuestions.length; i++) {
      final m = (_testQuestions[i]["marks"] as int?) ?? 10;
      maxScore += m;
      if (_selectedAnswers[i] == _testQuestions[i]["correct"]) {
        score += m;
      }
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => TestResultScreen(
          score: score,
          maxScore: maxScore > 0 ? maxScore : 10,
          totalQuestions: _testQuestions.length,
          timeTakenSeconds: 1800 - _secondsLeft,
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

    if (_testQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: const Text("Assessment Test", style: TextStyle(color: AppColors.textPrimary)),
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
            onPressed: () => context.go("/student/tests"),
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
                      "No Assessment Questions in Database",
                      style: AppTypography.h4(context, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "There are currently no questions stored in the database for this assessment. Only questions actually available in the database are displayed.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: "Back to Assessments",
                      variant: AppButtonVariant.primary,
                      onPressed: () => context.go("/student/tests"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final currentQ = _testQuestions[_currentIndex];
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    final isMob = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text("Assessment • Question ${_currentIndex + 1} of ${_testQuestions.length}", style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: AppRadii.badgeRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.clock, size: 16, color: AppColors.streak),
                const SizedBox(width: 8),
                Text(
                  "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, color: AppColors.streak),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop,
          vertical: AppSpacing.space6,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppBadge(
                            label: "+${currentQ["marks"]} Marks",
                            color: AppColors.success.withOpacity(0.15),
                            textColor: AppColors.success,
                          ),
                          TextButton.icon(
                            icon: Icon(
                              _markedForReview.contains(_currentIndex) ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
                              size: 16,
                              color: _markedForReview.contains(_currentIndex) ? AppColors.warning : AppColors.textMuted,
                            ),
                            label: Text(
                              _markedForReview.contains(_currentIndex) ? "Marked" : "Review Later",
                              style: TextStyle(
                                color: _markedForReview.contains(_currentIndex) ? AppColors.warning : AppColors.textMuted,
                              ),
                            ),
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
                      const SizedBox(height: AppSpacing.space4),
                      Text(currentQ["title"], style: AppTypography.h3(context, color: AppColors.textPrimary)),
                      const SizedBox(height: AppSpacing.space3),
                      Text(
                        currentQ["content"],
                        style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space6),

                // Options
                Text("Select Answer", style: AppTypography.labelLarge(context, color: AppColors.textMuted)),
                const SizedBox(height: AppSpacing.space3),

                ...List.generate(
                  (currentQ["options"] as List).length,
                  (optIdx) {
                    final opt = currentQ["options"][optIdx];
                    final isSelected = _selectedAnswers[_currentIndex] == opt;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedAnswers[_currentIndex] = opt;
                          });
                        },
                        borderRadius: AppRadii.cardStandardRadius,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.12) : AppColors.surface,
                            borderRadius: AppRadii.cardStandardRadius,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                                ),
                                child: isSelected
                                    ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  opt,
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

                // Footer Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppButton(
                      text: "Previous",
                      variant: AppButtonVariant.secondary,
                      icon: LucideIcons.arrowLeft,
                      onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null,
                    ),
                    Row(
                      children: [
                        if (_currentIndex < _testQuestions.length - 1)
                          AppButton(
                            text: "Next",
                            variant: AppButtonVariant.primary,
                            icon: LucideIcons.arrowRight,
                            onPressed: () => setState(() => _currentIndex++),
                          )
                        else
                          AppButton(
                            text: "Submit Assessment",
                            variant: AppButtonVariant.primary,
                            icon: LucideIcons.checkCircle2,
                            onPressed: _submitTest,
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
