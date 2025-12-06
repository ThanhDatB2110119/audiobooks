import 'dart:async';

import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';

part 'player_state.dart';

@singleton
class PlayerCubit extends Cubit<PlayerState> {
  final AudioPlayer _audioPlayer;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _speedSubscription;

  PlayerCubit(this._audioPlayer) : super(const PlayerState()) {
    _listenToPlayerChanges();
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
    if (books.isEmpty) return;

    emit(
      state.copyWith(
        playlist: books,
        currentIndex: startIndex,
        currentBook: books[startIndex],
        status: PlayerStatus.loading,
      ),
    );

    await _audioPlayer.setUrl(books[startIndex].audioUrl);
    _audioPlayer.play();
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
    _audioPlayer.dispose();
    return super.close();
  }
}
