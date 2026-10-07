import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/admin_login_screen.dart';
import '../../features/student/dashboard/student_dashboard_screen.dart';
import '../../features/student/learning/learning_home_screen.dart';
import '../../features/student/learning/lesson_viewer_screen.dart';
import '../../features/student/daily_practice/daily_practice_home_screen.dart';
import '../../features/student/daily_practice/practice_session_screen.dart';
import '../../features/student/coding_arena/coding_home_screen.dart';
import '../../features/student/coding_arena/coding_workspace_screen.dart';
import '../../features/student/tests/tests_list_screen.dart';
import '../../features/student/tests/test_active_screen.dart';
import '../../features/student/friends/friends_screen.dart';
import '../../features/student/battle_rooms/battle_home_screen.dart';
import '../../features/student/battle_rooms/battle_live_screen.dart';
import '../../features/student/leaderboard/leaderboard_screen.dart';
import '../../features/student/reports/student_reports_screen.dart';
import '../../features/student/profile/student_profile_screen.dart';
import '../../features/student/friends/student_search_screen.dart';
import '../../features/admin/dashboard/admin_dashboard_screen.dart';
import '../../features/admin/students/admin_students_screen.dart';
import '../../features/admin/question_management/admin_questions_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/auth/login',
  routes: [
    // Auth Routes
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/admin/login',
      builder: (context, state) => const AdminLoginScreen(),
    ),

    // Student Routes
    GoRoute(
      path: '/student/dashboard',
      builder: (context, state) => const StudentDashboardScreen(),
    ),
    GoRoute(
      path: '/student/learning',
      builder: (context, state) => const LearningHomeScreen(),
      routes: [
        GoRoute(
          path: 'lesson/:id',
          builder: (context, state) => LessonViewerScreen(
            lessonId: state.pathParameters['id'] ?? 'py_intro',
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/student/practice',
      builder: (context, state) => const DailyPracticeHomeScreen(),
      routes: [
        GoRoute(
          path: 'session/:category',
          builder: (context, state) {
            final cat = state.pathParameters['category'] ?? 'aptitude';
            final timer = state.uri.queryParameters['timer'] != 'false';
            return PracticeSessionScreen(categoryId: cat, timerEnabled: timer);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/student/coding',
      builder: (context, state) => const CodingHomeScreen(),
      routes: [
        GoRoute(
          path: 'workspace/:id',
          builder: (context, state) => CodingWorkspaceScreen(
            problemId: state.pathParameters['id'] ?? 'cp_two_sum',
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/student/tests',
      builder: (context, state) => const TestsListScreen(),
      routes: [
        GoRoute(
          path: 'active/:id',
          builder: (context, state) => TestActiveScreen(
            testId: state.pathParameters['id'] ?? 'test_nationwide_01',
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/student/friends',
      builder: (context, state) => const FriendsScreen(),
    ),
    GoRoute(
      path: '/student/search',
      builder: (context, state) => const StudentSearchScreen(),
    ),
    GoRoute(
      path: '/student/battles',
      builder: (context, state) => const BattleHomeScreen(),
      routes: [
        GoRoute(
          path: 'live/:code',
          builder: (context, state) => BattleLiveScreen(
            roomCode: state.pathParameters['code'] ?? 'CA-9042',
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/student/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/student/reports',
      builder: (context, state) => const StudentReportsScreen(),
    ),
    GoRoute(
      path: '/student/profile',
      builder: (context, state) => const StudentProfileScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => StudentProfileScreen(
            studentId: state.pathParameters['id'],
          ),
        ),
      ],
    ),

    // Admin Routes
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/students',
      builder: (context, state) => const AdminStudentsScreen(),
    ),
    GoRoute(
      path: '/admin/questions',
      builder: (context, state) => const AdminQuestionsScreen(),
    ),
    GoRoute(
      path: '/admin/learning',
      builder: (context, state) => const AdminQuestionsScreen(),
    ),
    GoRoute(
      path: '/admin/daily-challenges',
      builder: (context, state) => const AdminQuestionsScreen(),
    ),
    GoRoute(
      path: '/admin/coding',
      builder: (context, state) => const AdminQuestionsScreen(),
    ),
    GoRoute(
      path: '/admin/tests',
      builder: (context, state) => const AdminQuestionsScreen(),
    ),
    GoRoute(
      path: '/admin/battles',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/analytics',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/notifications',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/settings',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);
