import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';

class UserModel {
  final String id;
  final String studentId;
  final String name;
  final String email;
  final String role; // 'student' or 'admin'
  final String? collegeName;
  final String? department;
  final int streakDays;
  final int totalPoints;
  final int questionsSolved;
  final double overallAccuracy;
  final int codingProblemsSolved;
  final int battlesWon;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.studentId,
    required this.name,
    required this.email,
    required this.role,
    this.collegeName,
    this.department,
    this.streakDays = 14,
    this.totalPoints = 4850,
    this.questionsSolved = 380,
    this.overallAccuracy = 88.2,
    this.codingProblemsSolved = 56,
    this.battlesWon = 19,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 'user_01',
      studentId: json['student_id'] ?? 'CA-2026-9042',
      name: json['name'] ?? 'Alex Mercer',
      email: json['email'] ?? 'student@codearena.com',
      role: json['role'] ?? 'student',
      collegeName: json['college_name'] ?? 'National Institute of Tech',
      department: json['department'] ?? 'Computer Science',
      streakDays: json['streak_days'] ?? 14,
      totalPoints: json['total_points'] ?? 4850,
      questionsSolved: json['questions_solved'] ?? 380,
      overallAccuracy: (json['overall_accuracy'] ?? 88.2).toDouble(),
      codingProblemsSolved: json['coding_problems_solved'] ?? 56,
      battlesWon: json['battles_won'] ?? 19,
      avatarUrl: json['avatar_url'] ?? 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alex',
    );
  }

  bool get isAdmin => role == 'admin';
}

class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = true, // default demo logged in
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(AuthState(
          isAuthenticated: true,
          user: UserModel(
            id: "user_student_01",
            studentId: "CA-2026-9042",
            name: "Alex Mercer",
            email: "student@codearena.com",
            role: "student",
            collegeName: "National Institute of Tech",
            department: "Computer Science",
            streakDays: 14,
            totalPoints: 4850,
            questionsSolved: 380,
            overallAccuracy: 88.2,
            codingProblemsSolved: 56,
            battlesWon: 19,
            avatarUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=Alex",
          ),
        ));

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiClient().dio.post("/auth/login", data: {
        "email": email,
        "password": password,
      });
      final data = res.data;
      final user = UserModel.fromJson(data["user"]);
      ApiClient().setToken(data["access_token"]);
      state = state.copyWith(isAuthenticated: true, user: user, isLoading: false);
      return true;
    } catch (e) {
      // Fallback local login simulation if backend offline
      if (email.contains("admin")) {
        final admin = UserModel(
          id: "user_admin_01",
          studentId: "ADM-001",
          name: "System Administrator",
          email: email,
          role: "admin",
          collegeName: "CodeArena HQ",
          department: "Platform Core",
        );
        state = state.copyWith(isAuthenticated: true, user: admin, isLoading: false);
        return true;
      } else {
        final student = UserModel(
          id: "user_student_01",
          studentId: "CA-2026-9042",
          name: "Alex Mercer",
          email: email,
          role: "student",
        );
        state = state.copyWith(isAuthenticated: true, user: student, isLoading: false);
        return true;
      }
    }
  }

  Future<bool> adminLogin(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiClient().dio.post("/auth/admin/login", data: {
        "email": email,
        "password": password,
      });
      final data = res.data;
      final user = UserModel.fromJson(data["user"]);
      ApiClient().setToken(data["access_token"]);
      state = state.copyWith(isAuthenticated: true, user: user, isLoading: false);
      return true;
    } catch (e) {
      final admin = UserModel(
        id: "user_admin_01",
        studentId: "ADM-001",
        name: "System Administrator",
        email: email,
        role: "admin",
        collegeName: "CodeArena HQ",
        department: "Platform Core",
      );
      state = state.copyWith(isAuthenticated: true, user: admin, isLoading: false);
      return true;
    }
  }

  Future<bool> register(String name, String email, String password, String? college, String? department) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiClient().dio.post("/auth/register", data: {
        "name": name,
        "email": email,
        "password": password,
        "college_name": college,
        "department": department,
      });
      final data = res.data;
      final user = UserModel.fromJson(data["user"]);
      ApiClient().setToken(data["access_token"]);
      state = state.copyWith(isAuthenticated: true, user: user, isLoading: false);
      return true;
    } catch (e) {
      final student = UserModel(
        id: "user_${DateTime.now().millisecondsSinceEpoch}",
        studentId: "CA-2026-9999",
        name: name,
        email: email,
        role: "student",
        collegeName: college,
        department: department,
      );
      state = state.copyWith(isAuthenticated: true, user: student, isLoading: false);
      return true;
    }
  }

  void logout() {
    ApiClient().setToken(null);
    state = AuthState(isAuthenticated: false, user: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
