import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/network/api_client.dart';

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
  bool _isLoading = true;

  List<Map<String, dynamic>> _battleQuestions = [];

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
          _battleQuestions = List<Map<String, dynamic>>.from((res.data as List).map((q) => {
            "q": q["title"] ?? q["content"] ?? "",
            "opts": List<String>.from(q["options"] ?? []),
            "correct": q["correct_answer"] ?? q["answer"] ?? "",
          }));
          _isLoading = false;
        });
      } else {
        setState(() {
          _battleQuestions = [];
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _battleQuestions = [];
        _isLoading = false;
      });
    }
  }

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

    // Advance to next question after delay
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_currentQIndex < _battleQuestions.length - 1) {
        setState(() {
          _currentQIndex++;
          _selectedOption = null;
        });
      } else {
        setState(() => _isFinished = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_battleQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text("Battle Arena #${widget.roomCode}", style: const TextStyle(color: AppColors.textPrimary)),
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
            onPressed: () => context.go("/student/battles"),
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
                    const Icon(LucideIcons.swords, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      "No Battle Questions in Database",
                      style: AppTypography.h4(context, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "There are currently no questions stored in the database for battle rounds. Only questions actually available in the database are displayed.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: "Back to Battle Rooms",
                      variant: AppButtonVariant.primary,
                      onPressed: () => context.go("/student/battles"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_isFinished) {
      final didWin = _myScore >= _rivalScore;
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(32),
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    didWin ? LucideIcons.trophy : LucideIcons.frown,
                    size: 64,
                    color: didWin ? AppColors.warning : AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(didWin ? "VICTORY!" : "DEFEAT", style: AppTypography.h1(context, color: didWin ? AppColors.success : AppColors.error)),
                  const SizedBox(height: 8),
                  Text("Match Concluded in Room #${widget.roomCode}", style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text("Your Score", style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          Text("$_myScore", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Rival Score", style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          Text("$_rivalScore", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    text: "Return to Arena Lobby",
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
        title: Text("1v1 Live Arena • Room #${widget.roomCode}", style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          children: [
            // Score Header Matchup
            AppCard(
              backgroundColor: AppColors.surfaceElevated,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const CircleAvatar(radius: 20, backgroundImage: NetworkImage("https://api.dicebear.com/7.x/avataaars/svg?seed=You")),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("You", style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text("$_myScore PTS", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryLight)),
                    ],
                  ),
                  const Spacer(),
                  const Text("VS", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textMuted, fontSize: 18)),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Rival", style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text("$_rivalScore PTS", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.streak)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(radius: 20, backgroundImage: NetworkImage("https://api.dicebear.com/7.x/avataaars/svg?seed=Rival")),
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
