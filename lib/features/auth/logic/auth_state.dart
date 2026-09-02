abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final Map<String, dynamic> user;
  final String token;

  Authenticated({required this.user, required this.token});
}

typedef AuthAuthenticated = Authenticated;

class Unauthenticated extends AuthState {}

typedef AuthUnauthenticated = Unauthenticated;

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class SecurityQuestionLoaded extends AuthState {
  final String questionText;

  SecurityQuestionLoaded(this.questionText);
}

class PasswordResetSuccess extends AuthState {
  final String message;

  PasswordResetSuccess(this.message);
}
