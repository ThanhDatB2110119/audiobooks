part of 'player_cubit.dart';

enum PlayerStatus {
  stopped,
  loading,
  loaded,
  playing,
  paused,
  completed,
  error,
}

class PlayerState extends Equatable {
  final PlayerStatus status;
  final BookEntity? currentBook; // Sách đang phát, có thể null
  final List<BookEntity> playlist; // Danh sách phát hiện tại
  final int currentIndex; // Vị trí của sách hiện tại trong playlist
  final Duration duration;
  final Duration position;
  final String? errorMessage;
  final double speed;
  const PlayerState({
    this.status = PlayerStatus.stopped,
    this.currentBook,
    this.playlist = const [],
    this.currentIndex = -1,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.errorMessage,
    this.speed = 1.0,
  });

  PlayerState copyWith({
    PlayerStatus? status,
    BookEntity? currentBook,
    List<BookEntity>? playlist,
    int? currentIndex,
    Duration? duration,
    Duration? position,
    String? errorMessage,
    double? speed,
    bool clearCurrentBook = false,
  }) {
    return PlayerState(
      status: status ?? this.status,
      currentBook: clearCurrentBook ? null : currentBook ?? this.currentBook,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      errorMessage: errorMessage ?? this.errorMessage,
      speed: speed ?? this.speed,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentBook,
    playlist,
    currentIndex,
    duration,
    position,
    errorMessage,
    speed,
  ];
}
