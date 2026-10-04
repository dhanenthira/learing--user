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
  final Map<int, String> _selectedAnswers = {};
  final Set<int> _markedForReview = {};

  final List<Map<String, dynamic>> _testQuestions = [
    {
      "id": "tq1",
      "title": "Train Relative Velocity & Crossing Time",
      "content": "A train running at 60 km/hr crosses a pole in 9 seconds. What is the length of the train in meters?",
      "options": ["120 metres", "150 metres", "180 metres", "324 metres"],
      "correct": "150 metres",
      "marks": 10,
    },
    {
      "id": "tq2",
      "title": "Profit and Cost Ratio Analysis",
      "content": "A shopkeeper sells an article for \$240 and gains 20%. What was the cost price of the article?",
      "options": ["\$190", "\$200", "\$210", "\$220"],
      "correct": "\$200",
      "marks": 10,
    },
    {
      "id": "tq3",
      "title": "Algorithm Asymptotic Time Complexity",
      "content": "What is the worst-case time complexity of Binary Search on a sorted array of n elements?",
      "options": ["O(1)", "O(n)", "O(log n)", "O(n log n)"],
      "correct": "O(log n)",
      "marks": 10,
    },
    {
      "id": "tq4",
      "title": "Network Protocol Authentication Codes",
      "content": "Which HTTP status code signifies that authentication is required and has failed or has not yet been provided?",
      "options": ["400 Bad Request", "401 Unauthorized", "403 Forbidden", "404 Not Found"],
      "correct": "401 Unauthorized",
      "marks": 10,
    },
  ];

  @override
  void initState() {
    super.initState();
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
    for (int i = 0; i < _testQuestions.length; i++) {
      if (_selectedAnswers[i] == _testQuestions[i]["correct"]) {
        score += (_testQuestions[i]["marks"] as int);
      }
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => TestResultScreen(
          score: score,
          maxScore: 40,
          totalQuestions: _testQuestions.length,
          timeTakenSeconds: 1800 - _secondsLeft,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: AppRadii.badgeRadius,
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.clock, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              backgroundColor: AppColors.surfaceElevated,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(currentQ["title"], style: AppTypography.h3(context, color: AppColors.textPrimary)),
                      AppBadge(label: "${currentQ["marks"]} Marks", color: AppColors.primary.withOpacity(0.15), textColor: AppColors.primaryLight),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Text(currentQ["content"], style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space5),

            ...List.generate((currentQ["options"] as List).length, (optIdx) {
              final opt = currentQ["options"][optIdx] as String;
              final isSelected = _selectedAnswers[_currentIndex] == opt;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => _selectedAnswers[_currentIndex] = opt),
                  borderRadius: AppRadii.cardSmallRadius,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                      borderRadius: AppRadii.cardSmallRadius,
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 1.5 : 1),
                    ),
                    child: Row(
                      children: [
                        Text(String.fromCharCode(65 + optIdx), style: TextStyle(fontWeight: FontWeight.w700, color: isSelected ? AppColors.primary : AppColors.textMuted)),
                        const SizedBox(width: 14),
                        Expanded(child: Text(opt, style: TextStyle(fontSize: 15, color: isSelected ? AppColors.textPrimary : AppColors.textSecondary))),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.space6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton(
                  text: "← Previous",
                  variant: AppButtonVariant.secondary,
                  onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null,
                ),
                if (_currentIndex < _testQuestions.length - 1)
                  AppButton(
                    text: "Save & Next →",
                    variant: AppButtonVariant.primary,
                    onPressed: () => setState(() => _currentIndex++),
                  )
                else
                  AppButton(
                    text: "Submit Assessment",
                    variant: AppButtonVariant.primary,
                    onPressed: _submitTest,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
