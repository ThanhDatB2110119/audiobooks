part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final UserProfileEntity userProfile;
  const AuthAuthenticated(this.user, this.userProfile);

  @override
  List<Object> get props => [user, userProfile];
}

final class AuthUnauthenticated extends AuthState {}
