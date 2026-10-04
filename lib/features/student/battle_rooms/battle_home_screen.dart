import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/theme_service.dart';

class BattleHomeScreen extends ConsumerStatefulWidget {
  const BattleHomeScreen({super.key});

  @override
  ConsumerState<BattleHomeScreen> createState() => _BattleHomeScreenState();
}

class _BattleHomeScreenState extends ConsumerState<BattleHomeScreen> {
  final _roomCodeCtrl = TextEditingController(text: "CA-9042");

  void _showCreateRoomDialog() {
    String roomName = "Grand Algorithm Showdown";
    String category = "technical";
    String difficulty = "medium";
    int questionCount = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.modalRadius, side: const BorderSide(color: AppColors.border)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Create Battle Room", style: AppTypography.h3(context, color: AppColors.textPrimary)),
                    IconButton(icon: const Icon(LucideIcons.x, size: 20), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(height: 24),
                AppTextField(
                  label: "Room Name",
                  hint: "e.g. 1v1 Placement Showdown",
                  controller: TextEditingController(text: roomName),
                  onChanged: (v) => roomName = v,
                ),
                const SizedBox(height: AppSpacing.space4),

                Text("Challenge Category", style: AppTypography.labelLarge(context, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: ["Aptitude", "Technical", "Coding"].map((cat) {
                    final isSel = category.toLowerCase() == cat.toLowerCase();
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      onSelected: (v) => setModalState(() => category = cat.toLowerCase()),
                      selectedColor: AppColors.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.space4),

                Text("Questions Count", style: AppTypography.labelLarge(context, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [3, 5, 10].map((count) {
                    final isSel = questionCount == count;
                    return ChoiceChip(
                      label: Text("$count Questions"),
                      selected: isSel,
                      onSelected: (v) => setModalState(() => questionCount = count),
                      selectedColor: AppColors.secondary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.space6),

                AppButton(
                  text: "Launch Battle Room",
                  variant: AppButtonVariant.primary,
                  width: double.infinity,
                  onPressed: () {
                    Navigator.pop(context);
                    context.go("/student/battles/live/CA-9042");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isMob = ResponsiveLayout.isMobile(context);

    final activeRooms = [
      {
        "code": "CA-9042",
        "name": "Alex vs Sophia 1v1 Showdown",
        "host": "Alex Mercer",
        "category": "Technical Core",
        "players": "2 / 4 Players",
        "status": "In Lobby",
        "color": AppColors.primary,
      },
      {
        "code": "CA-4180",
        "name": "Speed Aptitude Sprint",
        "host": "Marcus Vance",
        "category": "Aptitude Fast Track",
        "players": "3 / 4 Players",
        "status": "Starting in 30s",
        "color": AppColors.secondary,
      },
    ];

    Widget content = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop,
        vertical: AppSpacing.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner & Quick Actions
          AppCard(
            backgroundColor: const Color(0xFF1E1B4B),
            borderColor: AppColors.secondary.withOpacity(0.4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppBadge(
                        label: "MULTIPLAYER 1V1 & SQUAD COMPETITIONS",
                        color: Color(0x228B5CF6),
                        textColor: AppColors.secondary,
                        isPill: true,
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      Text("Live Competitive Battle Arena", style: AppTypography.h2(context, color: AppColors.textPrimary)),
                      const SizedBox(height: AppSpacing.space2),
                      const Text(
                        "Compete in real-time synchronized matches with live score progression, speed multipliers, and winner podiums.",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: AppSpacing.space5),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          AppButton(
                            text: "Create New Room",
                            variant: AppButtonVariant.primary,
                            icon: LucideIcons.plus,
                            onPressed: _showCreateRoomDialog,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 140,
                                height: 44,
                                child: TextField(
                                  controller: _roomCodeCtrl,
                                  style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, color: AppColors.primaryLight, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: "Room Code",
                                    fillColor: AppColors.surfaceElevated,
                                    border: OutlineInputBorder(borderRadius: AppRadii.inputRadius, borderSide: const BorderSide(color: AppColors.border)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AppButton(
                                text: "Join Room",
                                variant: AppButtonVariant.secondary,
                                onPressed: () => context.go("/student/battles/live/${_roomCodeCtrl.text.trim()}"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space6),

          Text("Active Battle Rooms", style: AppTypography.h3(context, color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.space4),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeRooms.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 14),
            itemBuilder: (ctx, idx) {
              final r = activeRooms[idx];
              return AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (r["color"] as Color).withOpacity(0.12),
                        borderRadius: AppRadii.inputRadius,
                      ),
                      child: Icon(LucideIcons.swords, color: r["color"] as Color, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.space4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(r["name"] as String, style: AppTypography.h4(context, color: AppColors.textPrimary)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: AppRadii.badgeRadius),
                                child: Text(r["code"] as String, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("Host: ${r["host"]} • ${r["category"]} • ${r["players"]}", style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                    AppBadge(label: r["status"] as String, isPill: true, color: AppColors.success.withOpacity(0.15), textColor: AppColors.success),
                    const SizedBox(width: 14),
                    AppButton(
                      text: "Join Match",
                      variant: AppButtonVariant.primary,
                      onPressed: () => context.go("/student/battles/live/${r["code"]}"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (!isMob) const AppSidebar(currentRoute: "/student/battles"),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: "Multiplayer Battle Rooms",
                  subtitle: "1v1 and squad speed coding and aptitude matches",
                  isDarkMode: isDark,
                  onThemeToggle: () => ref.read(themeProvider.notifier).toggleTheme(),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMob ? const AppBottomNav(currentRoute: "/student/battles") : null,
    );
  }
}
