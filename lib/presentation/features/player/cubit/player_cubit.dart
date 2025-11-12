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
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
        emit(state.copyWith(status: PlayerStatus.loading));
      } else if (!isPlaying) {
        
        emit(state.copyWith(status: PlayerStatus.paused));
      } else if (processingState != ProcessingState.completed) {
        emit(state.copyWith(status: PlayerStatus.playing));
      } else {
        emit(state.copyWith(status: PlayerStatus.completed));
      }
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      emit(state.copyWith(duration: duration ?? Duration.zero));
    });

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      emit(state.copyWith(position: position));
    });
  }

  Future<void> loadAudio(String url) async {
    try {
      emit(state.copyWith(status: PlayerStatus.loading));
      await _audioPlayer.setUrl(url);
      emit(state.copyWith(status: PlayerStatus.loaded));
    } catch (e) {
      emit(state.copyWith(status: PlayerStatus.error, errorMessage: 'Không thể tải audio.'));
    }
  }

  void play() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  Future<void> close() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}

// **QUAN TRỌNG**: Đăng ký AudioPlayer trong file injection_container
// Mở file `core/injection/register_module.dart`
// @module
// abstract class RegisterModule {
//   @injectable
//   AudioPlayer get audioPlayer => AudioPlayer();
// }