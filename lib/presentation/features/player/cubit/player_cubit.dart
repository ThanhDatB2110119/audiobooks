import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';

part 'player_state.dart';

@injectable
class PlayerCubit extends Cubit<PlayerState> {
  final AudioPlayer _audioPlayer;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;

  PlayerCubit(this._audioPlayer) : super(const PlayerState()) {
    _listenToPlayerChanges();
  }

  void _listenToPlayerChanges() {
    // Đoạn code này giữ nguyên
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        emit(state.copyWith(status: PlayerStatus.loading));
      } else if (!isPlaying) {
        // Chỉ cập nhật thành paused nếu audio đã sẵn sàng (không phải initial/completed)
        if (processingState != ProcessingState.completed &&
            processingState != ProcessingState.idle) {
          emit(state.copyWith(status: PlayerStatus.paused));
        }
      } else if (processingState != ProcessingState.completed) {
        emit(state.copyWith(status: PlayerStatus.playing));
      } else {
        // Khi audio chạy xong, seek về đầu và pause
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
        emit(
          state.copyWith(
            status: PlayerStatus.completed,
            position: Duration.zero,
          ),
        );
      }
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      emit(state.copyWith(duration: duration ?? Duration.zero));
    });

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      emit(state.copyWith(position: position));
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

    return super.close();
  }
}
