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
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/responsive_layout.dart';

class BattleLiveScreen extends StatefulWidget {
  final String roomCode;

  const BattleLiveScreen({super.key, required this.roomCode});

  @override
  State<BattleLiveScreen> createState() => _BattleLiveScreenState();
}

class _BattleLiveScreenState extends State<BattleLiveScreen> {
  int _currentQIndex = 0;
  int _myScore = 0;
  int _rivalScore = 0;
  bool _isFinished = false;
  String? _selectedOption;

  final List<Map<String, dynamic>> _battleQuestions = [
    {
      "q": "What is the time complexity of searching an element in a balanced Binary Search Tree?",
      "opts": ["O(1)", "O(n)", "O(log n)", "O(n log n)"],
      "correct": "O(log n)"
    },
    {
      "q": "Which data structure uses LIFO (Last In First Out) ordering?",
      "opts": ["Queue", "Stack", "Array", "Linked List"],
      "correct": "Stack"
    },
    {
      "q": "A train crosses a 300m bridge in 20 seconds at 90 km/hr. Length of train?",
      "opts": ["150m", "200m", "250m", "300m"],
      "correct": "200m"
    },
  ];

  void _handleOption(String opt) {
    if (_selectedOption != null) return;
    setState(() => _selectedOption = opt);

    final isCorrect = opt == _battleQuestions[_currentQIndex]["correct"];
    if (isCorrect) {
      _myScore += 120;
    }

    // Simulate rival score update
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _rivalScore += 100;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_currentQIndex < _battleQuestions.length - 1) {
        setState(() {
          _currentQIndex++;
          _selectedOption = null;
        });
      } else {
        setState(() {
          _isFinished = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMob = ResponsiveLayout.isMobile(context);

    if (_isFinished) {
      final iWon = _myScore >= _rivalScore;
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: AppCard(
              backgroundColor: AppColors.surfaceElevated,
              borderColor: iWon ? AppColors.success : AppColors.secondary,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: iWon ? AppColors.success.withOpacity(0.15) : AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iWon ? LucideIcons.trophy : LucideIcons.award, size: 40, color: iWon ? AppColors.streak : AppColors.primaryLight),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(iWon ? "Victory! You Won!" : "Good Match!", style: AppTypography.h1(context, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    iWon ? "You scored higher with faster accurate responses!" : "Well played battle against Sophia Chen.",
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const Divider(height: 36),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const AppAvatar(name: "Alex", radius: 22),
                          const SizedBox(height: 4),
                          const Text("Alex (You)", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text("$_myScore pts", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.primaryLight)),
                        ],
                      ),
                      const Text("VS", style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted, fontSize: 18)),
                      Column(
                        children: [
                          const AppAvatar(name: "Sophia Chen", radius: 22),
                          const SizedBox(height: 4),
                          const Text("Sophia Chen", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text("$_rivalScore pts", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.secondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space6),

                  AppButton(
                    text: "Return to Battle Hub",
                    variant: AppButtonVariant.primary,
                    width: double.infinity,
                    onPressed: () => context.go("/student/battles"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final q = _battleQuestions[_currentQIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text("Live Battle Arena • ${widget.roomCode}", style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go("/student/battles"),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop),
        child: Column(
          children: [
            // Top Live Scoreboard
            AppCard(
              backgroundColor: const Color(0xFF1E1B4B),
              child: Row(
                children: [
                  // You
                  const CircleAvatar(radius: 20, backgroundImage: NetworkImage("https://api.dicebear.com/7.x/avataaars/svg?seed=Alex")),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Alex (You)", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13)),
                      Text("$_myScore XP", style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryLight, fontSize: 16)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(LucideIcons.swords, color: AppColors.purple, size: 24),
                  const Spacer(),
                  // Rival
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Sophia Chen", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13)),
                      Text("$_rivalScore XP", style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.secondary, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const CircleAvatar(radius: 20, backgroundImage: NetworkImage("https://api.dicebear.com/7.x/avataaars/svg?seed=Sophia")),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space6),

            // Live Question Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Round ${_currentQIndex + 1} of ${_battleQuestions.length}", style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryLight)),
                      const AppBadge(label: "SPEED BONUS ACTIVE", color: Color(0x22F59E0B), textColor: AppColors.warning, isPill: true),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Text(q["q"], style: AppTypography.h3(context, color: AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space4),

            // Option Choices
            ...List.generate((q["opts"] as List).length, (idx) {
              final opt = q["opts"][idx] as String;
              final isChosen = _selectedOption == opt;
              final isCorrect = opt == q["correct"];

              Color bg = AppColors.surface;
              Color borderC = AppColors.border;

              if (_selectedOption != null) {
                if (isCorrect) {
                  bg = AppColors.success.withOpacity(0.2);
                  borderC = AppColors.success;
                } else if (isChosen) {
                  bg = AppColors.error.withOpacity(0.2);
                  borderC = AppColors.error;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _handleOption(opt),
                  borderRadius: AppRadii.cardSmallRadius,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: AppRadii.cardSmallRadius,
                      border: Border.all(color: borderC, width: isChosen ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        Text(String.fromCharCode(65 + idx), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                        const SizedBox(width: 14),
                        Expanded(child: Text(opt, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary))),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
