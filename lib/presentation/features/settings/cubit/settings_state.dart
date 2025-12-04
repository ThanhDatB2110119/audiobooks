// presentation/features/settings/cubit/settings_state.dart

import 'package:audiobooks/domain/entities/user_profile_entity.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserProfileEntity userProfile;
  const SettingsLoaded(this.userProfile);
  @override
  List<Object?> get props => [userProfile];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
  @override
  List<Object> get props => [message];
}
