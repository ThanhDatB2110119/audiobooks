part of 'player_cubit.dart';

enum PlayerStatus {
  initial,
  loading,
  loaded,
  playing,
  paused,
  completed,
  error,
}

class PlayerState extends Equatable {
  final PlayerStatus status;
  final Duration duration;
  final Duration position;
  final String? errorMessage;
  final double speed;
  const PlayerState({
    this.status = PlayerStatus.initial,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.errorMessage,
    this.speed = 1.0,
  });

  PlayerState copyWith({
    PlayerStatus? status,
    Duration? duration,
    Duration? position,
    String? errorMessage,
    double? speed,
  }) {
    return PlayerState(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      errorMessage: errorMessage ?? this.errorMessage,
      speed: speed ?? this.speed,
    );
  }

  @override
  List<Object?> get props => [status, duration, position, errorMessage, speed];
}
