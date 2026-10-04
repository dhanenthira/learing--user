import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // Selected answers: question_index -> option_string
  final Map<int, String> _selectedAnswers = {};
  final Set<int> _markedForReview = {};

  final List<Map<String, dynamic>> _questions = [
    {
      "id": "q1",
      "title": "Train Speed & Distance Calculation",
      "content": "A train running at the speed of 60 km/hr crosses a telephone pole in 9 seconds. What is the length of the train in meters?",
      "category": "Aptitude",
      "options": ["120 metres", "150 metres", "180 metres", "324 metres"],
      "correct": "150 metres",
      "explanation": "Speed in m/s = 60 * (5/18) = 50/3 m/s. Length = Speed * Time = (50/3) * 9 = 150 metres."
    },
    {
      "id": "q2",
      "title": "Profit and Loss Calculation",
      "content": "A shopkeeper sells an article for \$240 and gains 20%. What was the cost price of the article?",
      "category": "Aptitude",
      "options": ["\$190", "\$200", "\$210", "\$220"],
      "correct": "\$200",
      "explanation": "Cost Price = (Selling Price * 100) / (100 + Gain%) = (240 * 100) / 120 = \$200."
    },
    {
      "id": "q3",
      "title": "Worst-Case Time Complexity",
      "content": "What is the worst-case time complexity of Binary Search on a sorted array of n elements?",
      "category": "Technical",
      "options": ["O(1)", "O(n)", "O(log n)", "O(n log n)"],
      "correct": "O(log n)",
      "explanation": "Each iteration divides the search space in half, resulting in logarithmic time complexity O(log n)."
    },
    {
      "id": "q4",
      "title": "HTTP Status Code Specification",
      "content": "Which HTTP status code signifies that authentication is required and has failed or has not yet been provided?",
      "category": "Technical",
      "options": ["400 Bad Request", "401 Unauthorized", "403 Forbidden", "404 Not Found"],
      "correct": "401 Unauthorized",
      "explanation": "HTTP 401 Unauthorized is sent when authentication credentials are required to access the target resource."
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.timerEnabled) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          _timer?.cancel();
          _submitPractice();
        }
      });
    }
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
        "question": q["content"],
        "options": q["options"],
        "selected": selected,
        "correct": q["correct"],
        "isCorrect": isCorrect,
        "explanation": q["explanation"],
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.divider, height: 1),
        ),
      ),
      body: Row(
        children: [
          // Main Question Section
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBadge(label: currentQ["category"], isPill: true, color: AppColors.primary.withOpacity(0.15), textColor: AppColors.primary),
                      Row(
                        children: [
                          Checkbox(
                            value: _markedForReview.contains(_currentIndex),
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _markedForReview.add(_currentIndex);
                                } else {
                                  _markedForReview.remove(_currentIndex);
                                }
                              });
                            },
                            activeColor: AppColors.warning,
                          ),
                          const Text("Mark for Review", style: TextStyle(color: AppColors.warning, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space4),

                  // Question Box
                  AppCard(
                    backgroundColor: AppColors.surfaceElevated,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentQ["title"],
                          style: AppTypography.h3(context, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        Text(
                          currentQ["content"],
                          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space5),

                  // Options
                  Text("Select One Option:", style: AppTypography.labelLarge(context, color: AppColors.textMuted)),
                  const SizedBox(height: AppSpacing.space3),

                  ...List.generate((currentQ["options"] as List).length, (optIdx) {
                    final optText = currentQ["options"][optIdx] as String;
                    final isSelected = _selectedAnswers[_currentIndex] == optText;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedAnswers[_currentIndex] = optText;
                          });
                        },
                        borderRadius: AppRadii.cardSmallRadius,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                            borderRadius: AppRadii.cardSmallRadius,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + optIdx),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: isSelected ? Colors.white : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  optText,
                                  style: TextStyle(
                                    fontSize: 15,
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
                  }),
                  const SizedBox(height: AppSpacing.space6),

                  // Bottom Action Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppButton(
                        text: "← Previous",
                        variant: AppButtonVariant.secondary,
                        onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null,
                      ),
                      if (_currentIndex < _questions.length - 1)
                        AppButton(
                          text: "Next Question →",
                          variant: AppButtonVariant.primary,
                          onPressed: () => setState(() => _currentIndex++),
                        )
                      else
                        AppButton(
                          text: "Submit Practice",
                          variant: AppButtonVariant.primary,
                          icon: LucideIcons.checkCheck,
                          onPressed: _submitPractice,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Question Navigator Grid (Right side on desktop)
          if (!isMob)
            Container(
              width: 280,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(left: BorderSide(color: AppColors.border, width: 1)),
              ),
              padding: const EdgeInsets.all(AppSpacing.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Question Navigator", style: AppTypography.h4(context, color: AppColors.textPrimary)),
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
                      final isCurrent = _currentIndex == idx;

                      Color bg = AppColors.surfaceElevated;
                      Color borderC = AppColors.border;
                      Color textC = AppColors.textSecondary;

                      if (isCurrent) {
                        borderC = AppColors.primary;
                      }
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
