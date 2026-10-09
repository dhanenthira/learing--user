import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/main.dart';
import 'package:frontend/app/router/app_router.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_badge.dart';
import 'package:frontend/core/widgets/app_avatar.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('CodeArena app smoke test loads Student Dashboard by default', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: CodeArenaApp()));
    appRouter.go('/student/dashboard');
    await tester.pumpAndSettle();

    expect(find.byType(CodeArenaApp), findsOneWidget);
    expect(find.text("Student Dashboard"), findsWidgets);
    expect(find.textContaining("CodeArena"), findsWidgets);
  });

  testWidgets('LoginScreen renders auth form with proper branding', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Welcome Back"), findsOneWidget);
    expect(find.text("Sign In"), findsWidgets);
    expect(find.text("Email Address"), findsOneWidget);
    expect(find.text("Password"), findsOneWidget);
  });

  testWidgets('AppButton renders and handles onTap', (WidgetTester tester) async {
    bool clicked = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            text: "Start Challenge",
            onPressed: () => clicked = true,
          ),
        ),
      ),
    );

    expect(find.text("Start Challenge"), findsOneWidget);
    await tester.tap(find.text("Start Challenge"));
    expect(clicked, isTrue);
  });

  testWidgets('AppBadge renders difficulty and streak correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppBadge.difficulty("hard"),
              AppBadge.streak(14),
            ],
          ),
        ),
      ),
    );

    expect(find.text("HARD"), findsOneWidget);
    expect(find.text("14 Day Streak"), findsOneWidget);
  });

  testWidgets('AppAvatar renders initials correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppAvatar(name: "John Doe"),
        ),
      ),
    );

    expect(find.text("JD"), findsOneWidget);
  });
}
