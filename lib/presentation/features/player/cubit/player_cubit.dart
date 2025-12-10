import 'dart:async';

import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';

part 'player_state.dart';

@singleton
class PlayerCubit extends Cubit<PlayerState> {
  final AudioPlayer _audioPlayer;
  final AuthCubit _authCubit;
  StreamSubscription? _authSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _speedSubscription;

  PlayerCubit(this._audioPlayer, this._authCubit) : super(const PlayerState()) {
    _listenToPlayerChanges();
    _listenToAuthState();
  }

  void _listenToPlayerChanges() {
    // Đoạn code này giữ nguyên
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      // Lấy trạng thái xử lý và trạng thái phát
      final processingState = playerState.processingState;
      final isPlaying = playerState.playing;

      // Xác định PlayerStatus mới dựa trên thông tin từ AudioPlayer
      PlayerStatus newStatus;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        newStatus = PlayerStatus.loading;
      } else if (!isPlaying) {
        // Nếu không phát, có thể là do paused, completed hoặc stopped
        if (state.status == PlayerStatus.stopped) {
          newStatus = PlayerStatus.stopped;
        } else if (processingState == ProcessingState.completed) {
          // Khi một bài hát kết thúc, chúng ta sẽ xử lý nó ở dưới
          newStatus = PlayerStatus.completed;
        } else {
          newStatus = PlayerStatus.paused;
        }
      } else {
        // Nếu đang phát
        newStatus = PlayerStatus.playing;
      }

      // Phát ra state mới
      emit(state.copyWith(status: newStatus));

      // Xử lý logic khi một bài hát kết thúc
      // Chúng ta làm việc này sau khi emit state `completed`
      if (processingState == ProcessingState.completed) {
        // ignore: avoid_print
        print("--- Track Completed. Attempting to play next. ---");
        // Gọi hàm tự động chuyển bài
        playNext();
      }
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (!isClosed) emit(state.copyWith(duration: duration ?? Duration.zero));
    });

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (!isClosed) emit(state.copyWith(position: position));
    });
    _speedSubscription = _audioPlayer.speedStream.listen((speed) {
      if (!isClosed) emit(state.copyWith(speed: speed));
    });
  }

  /// Lắng nghe sự thay đổi trạng thái xác thực.
  void _listenToAuthState() {
    // Lắng nghe stream của AuthCubit
    _authSubscription = _authCubit.stream.listen((authState) {
      // Nếu người dùng không còn được xác thực (ví dụ: đã đăng xuất)
      if (authState is! AuthAuthenticated) {
        print(
          '--- Auth state changed to unauthenticated. Stopping player. ---',
        );
        // Gọi hàm stop để dừng nhạc và xóa state
        stop();
      }
    });
  }
  // ======================= THAY ĐỔI 1: CẬP NHẬT PHƯƠNG THỨC loadAudio =======================
  // File cũ:
  // Future<void> loadAudio(String url) async {
  //   try {
  //     emit(state.copyWith(status: PlayerStatus.loading));
  //     await _audioPlayer.setUrl(url);
  //     emit(state.copyWith(status: PlayerStatus.loaded));
  //   } catch (e) {
  //     emit(state.copyWith(status: PlayerStatus.error, errorMessage: 'Không thể tải audio.'));
  //   }
  // }

  // File mới:
  Future<void> loadAudio(String url, {bool autoplay = false}) async {
    try {
      emit(state.copyWith(status: PlayerStatus.loading));

      await _audioPlayer.stop();

      await _audioPlayer.setUrl(url);

      // Nếu autoplay là true, gọi play() ngay lập tức
      if (autoplay) {
        _audioPlayer.play();
        // Không cần emit state playing ở đây, vì stream listener sẽ tự động làm điều đó.
      } else {
        // Nếu không autoplay, chỉ emit state loaded
        emit(state.copyWith(status: PlayerStatus.loaded));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: 'Không thể tải audio.',
        ),
      );
    }
  }

  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
  }
  // ========================================================================================

  // Các phương thức còn lại giữ nguyên
  void play() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void seekForward() {
    final newPosition = _audioPlayer.position + const Duration(seconds: 5);
    // Đảm bảo không tua quá thời lượng của audio
    if (newPosition < (_audioPlayer.duration ?? Duration.zero)) {
      _audioPlayer.seek(newPosition);
    }
  }

  Future<void> startNewPlaylist(List<BookEntity> books, int startIndex) async {
    // Kiểm tra đầu vào hợp lệ
    if (books.isEmpty || startIndex < 0 || startIndex >= books.length) return;

    final bookToPlay = books[startIndex];

    // --- BƯỚC KIỂM TRA QUAN TRỌNG NHẤT ---
    // Kiểm tra xem sách được chọn có URL audio hợp lệ hay không
    if (bookToPlay.audioUrl == null || bookToPlay.audioUrl!.isEmpty) {
      // Nếu không có URL, phát ra state lỗi và dừng lại
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: 'Không tìm thấy file audio cho phần này.',
        ),
      );
      return;
    }

    // Nếu code chạy đến đây, chúng ta chắc chắn 100% rằng `bookToPlay.audioUrl` không phải là null.

    emit(
      state.copyWith(
        playlist: books,
        currentIndex: startIndex,
        currentBook: bookToPlay,
        status: PlayerStatus.loading,
        position: Duration.zero,
        duration: Duration.zero,
      ),
    );

    try {
      // Bây giờ chúng ta có thể dùng toán tử `!` (bang operator) một cách an toàn
      // để khẳng định với Dart rằng `audioUrl` không phải là null.
      await _audioPlayer.setUrl(bookToPlay.audioUrl!);

      await _audioPlayer.setSpeed(state.speed);
      _audioPlayer.play();
    } catch (e) {
      // Xử lý lỗi nếu setUrl thất bại (ví dụ: URL không hợp lệ)
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: 'Lỗi khi tải audio. Vui lòng kiểm tra lại đường dẫn.',
        ),
      );
    }
  }

  /// Phát sách tiếp theo trong danh sách
  Future<void> playNext() async {
    if (state.currentIndex < state.playlist.length - 1) {
      final nextIndex = state.currentIndex + 1;
      await startNewPlaylist(state.playlist, nextIndex);
    } else {
      // Đã hết playlist, dừng lại
      stop();
    }
  }

  /// Phát sách trước đó trong danh sách
  Future<void> playPrevious() async {
    if (state.currentIndex > 0) {
      final prevIndex = state.currentIndex - 1;
      await startNewPlaylist(state.playlist, prevIndex);
    }
  }

  /// Dừng phát hoàn toàn và xóa state
  Future<void> stop() async {
    await _audioPlayer.stop();
    emit(
      state.copyWith(
        status: PlayerStatus.stopped,
        clearCurrentBook: true, // Xóa sách hiện tại
        playlist: [],
        currentIndex: -1,
        position: Duration.zero,
        duration: Duration.zero,
      ),
    );
  }
  // Future<void> startNewPlaylist(List<BookEntity> books, int startIndex) async {
  //     if (books.isEmpty || startIndex < 0 || startIndex >= books.length) return;

  //     final bookToPlay = books[startIndex];
  //     // Kiểm tra xem sách có URL audio không
  //     if (bookToPlay.audioUrl == null || bookToPlay.audioUrl!.isEmpty) {
  //       emit(state.copyWith(status: PlayerStatus.error, errorMessage: 'Không tìm thấy file audio cho phần này.'));
  //       return;
  //     }

  //     emit(state.copyWith(
  //       playlist: books,
  //       currentIndex: startIndex,
  //       currentBook: bookToPlay,
  //       status: PlayerStatus.loading,
  //       position: Duration.zero, // Reset vị trí khi bắt đầu bài mới
  //       duration: Duration.zero,
  //     ));

  //     try {
  //       await _audioPlayer.setUrl(bookToPlay.audioUrl!);
  //       await _audioPlayer.setSpeed(state.speed); // Đảm bảo tốc độ được giữ nguyên
  //       _audioPlayer.play();
  //     } catch (e) {
  //        emit(state.copyWith(status: PlayerStatus.error, errorMessage: 'Lỗi khi tải audio.'));
  //     }
  //   }

  /// Tua lùi 5 giây.
  void seekBackward() {
    final newPosition = _audioPlayer.position - const Duration(seconds: 5);
    // Đảm bảo không tua về trước thời điểm 0
    if (newPosition > Duration.zero) {
      _audioPlayer.seek(newPosition);
    } else {
      _audioPlayer.seek(Duration.zero);
    }
  }

  void replay() {
    // Sử dụng seek để quay về vị trí 0 giây
    _audioPlayer.seek(Duration.zero);
    // Sau khi seek xong, ra lệnh phát
    _audioPlayer.play();
  }

  @override
  Future<void> close() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _speedSubscription?.cancel();
    _authSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
