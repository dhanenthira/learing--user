import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';

class UserModel {
  final String id;
  final String studentId;
  final String name;
  final String email;
  final String role; // 'student' or 'admin'
  final String? collegeName;
  final String? department;
  final int? graduationYear;
  final String? bio;
  final int streakDays;
  final int totalPoints;
  final int questionsSolved;
  final double overallAccuracy;
  final int codingProblemsSolved;
  final int battlesWon;
  final int followersCount;
  final int followingCount;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.studentId,
    required this.name,
    required this.email,
    required this.role,
    this.collegeName,
    this.department,
    this.graduationYear,
    this.bio,
    this.streakDays = 0,
    this.totalPoints = 0,
    this.questionsSolved = 0,
    this.overallAccuracy = 0.0,
    this.codingProblemsSolved = 0,
    this.battlesWon = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      collegeName: json['college_name'],
      department: json['department'],
      graduationYear: json['graduation_year'],
      bio: json['bio'],
      streakDays: json['streak_days'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      questionsSolved: json['questions_solved'] ?? 0,
      overallAccuracy: (json['overall_accuracy'] ?? 0.0).toDouble(),
      codingProblemsSolved: json['coding_problems_solved'] ?? 0,
      battlesWon: json['battles_won'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      avatarUrl: json['avatar_url'],
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
    this.isAuthenticated = false,
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
          isAuthenticated: false,
          user: null,
        ));

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiClient().dio.post("/auth/login", data: {
        "email": email.trim(),
        "password": password.trim(),
      });
      final data = res.data;
      final user = UserModel.fromJson(data["user"]);
      ApiClient().setToken(data["access_token"]);
      state = state.copyWith(isAuthenticated: true, user: user, isLoading: false, error: null);
      return true;
    } catch (e) {
      String msg = "Invalid email or password.";
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data["detail"] != null) {
          msg = e.response!.data["detail"].toString();
        } else if (e.type == DioExceptionType.connectionTimeout ||
                   e.type == DioExceptionType.receiveTimeout ||
                   e.type == DioExceptionType.connectionError) {
          msg = "Cannot connect to server (${ApiClient.getBaseUrl()}). Please ensure backend is running.";
        }
      }
      state = state.copyWith(isAuthenticated: false, user: null, isLoading: false, error: msg);
      return false;
    }
  }

  Future<bool> adminLogin(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiClient().dio.post("/auth/admin/login", data: {
        "email": email.trim(),
        "password": password.trim(),
      });
      final data = res.data;
      final user = UserModel.fromJson(data["user"]);
      ApiClient().setToken(data["access_token"]);
      state = state.copyWith(isAuthenticated: true, user: user, isLoading: false, error: null);
      return true;
    } catch (e) {
      String msg = "Invalid administrator credentials or unauthorized.";
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data["detail"] != null) {
          msg = e.response!.data["detail"].toString();
        } else if (e.type == DioExceptionType.connectionTimeout ||
                   e.type == DioExceptionType.receiveTimeout ||
                   e.type == DioExceptionType.connectionError) {
          msg = "Cannot connect to server (${ApiClient.getBaseUrl()}). Please ensure backend is running.";
        }
      }
      state = state.copyWith(isAuthenticated: false, user: null, isLoading: false, error: msg);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String? college, String? department) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiClient().dio.post("/auth/register", data: {
        "name": name.trim(),
        "email": email.trim(),
        "password": password.trim(),
        "college_name": college?.trim(),
        "department": department?.trim(),
      });
      final data = res.data;
      final user = UserModel.fromJson(data["user"]);
      ApiClient().setToken(data["access_token"]);
      state = state.copyWith(isAuthenticated: true, user: user, isLoading: false, error: null);
      return true;
    } catch (e) {
      String errorMsg = "Registration failed. Email may already be in use.";
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data["detail"] != null) {
          errorMsg = e.response!.data["detail"].toString();
        } else if (e.type == DioExceptionType.connectionTimeout ||
                   e.type == DioExceptionType.receiveTimeout ||
                   e.type == DioExceptionType.connectionError) {
          errorMsg = "Cannot connect to server (${ApiClient.getBaseUrl()}). Please ensure backend is running.";
        }
      }
      state = state.copyWith(isAuthenticated: false, user: null, isLoading: false, error: errorMsg);
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? collegeName,
    String? department,
    int? graduationYear,
    String? bio,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data["name"] = name.trim();
      if (collegeName != null) data["college_name"] = collegeName.trim();
      if (department != null) data["department"] = department.trim();
      if (graduationYear != null) data["graduation_year"] = graduationYear;
      if (bio != null) data["bio"] = bio.trim();
      if (avatarUrl != null) data["avatar_url"] = avatarUrl.trim();

      final res = await ApiClient().dio.put("/students/profile", data: data);
      final updatedUser = UserModel.fromJson(res.data);
      state = state.copyWith(user: updatedUser, isLoading: false, error: null);
      return true;
    } catch (e) {
      String msg = "Failed to update profile";
      if (e is DioException && e.response?.data != null) {
        msg = e.response?.data["detail"] ?? msg;
      }
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      final res = await ApiClient().dio.get("/auth/me");
      if (res.data != null) {
        final updatedUser = UserModel.fromJson(res.data);
        state = state.copyWith(user: updatedUser);
      }
    } catch (_) {}
  }

  void logout() {
    ApiClient().setToken(null);
    state = AuthState(isAuthenticated: false, user: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
