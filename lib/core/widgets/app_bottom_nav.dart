import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/constants/app_icons.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final String currentRoute;

  const AppBottomNav({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final unselectedColor = isDark ? AppColors.textMuted : AppColors.lightTextMuted;

    int getIndex() {
      if (currentRoute.startsWith("/student/dashboard")) return 0;
      if (currentRoute.startsWith("/student/learning")) return 1;
      if (currentRoute.startsWith("/student/practice")) return 2;
      if (currentRoute.startsWith("/student/coding")) return 3;
      if (currentRoute.startsWith("/student/battles")) return 4;
      return 0;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: getIndex(),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go("/student/dashboard");
              break;
            case 1:
              context.go("/student/learning");
              break;
            case 2:
              context.go("/student/practice");
              break;
            case 3:
              context.go("/student/coding");
              break;
            case 4:
              context.go("/student/battles");
              break;
          }
        },
        backgroundColor: bgColor,
        selectedItemColor: isDark ? AppColors.primary : AppColors.primaryDark,
        unselectedItemColor: unselectedColor,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home, size: 20), label: "Home"),
          BottomNavigationBarItem(icon: Icon(LucideIcons.bookOpen, size: 20), label: "Learn"),
          BottomNavigationBarItem(icon: Icon(LucideIcons.brain, size: 20), label: "Practice"),
          BottomNavigationBarItem(icon: Icon(LucideIcons.code2, size: 20), label: "Coding"),
          BottomNavigationBarItem(icon: Icon(LucideIcons.swords, size: 20), label: "Battle"),
        ],
      ),
    );
  }
}

