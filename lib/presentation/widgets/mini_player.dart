// presentation/widgets/mini_player.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:audiobooks/presentation/features/player/cubit/player_cubit.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng BlocBuilder để lắng nghe PlayerCubit (singleton)
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        // Nếu không có sách nào đang phát, không hiển thị gì cả
        if (state.status == PlayerStatus.stopped || state.currentBook == null) {
          return const SizedBox.shrink();
        }

        final book = state.currentBook!;
        final isPlaying = state.status == PlayerStatus.playing;

        return GestureDetector(
          // Khi nhấn vào mini player, mở PlayerPage
          onTap: () {
            context.push('/player');
          },
          child: Container(
            height: 65,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                // Thanh tiến trình
                LinearProgressIndicator(
                  value: (state.duration.inSeconds > 0)
                      ? state.position.inSeconds / state.duration.inSeconds
                      : 0.0,
                  backgroundColor: Colors.grey[300],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // Ảnh bìa nhỏ
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            book.coverImageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.music_note),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Tên sách
                        Expanded(
                          child: Text(
                            book.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Nút Play/Pause
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          onPressed: () {
                            if (isPlaying) {
                              context.read<PlayerCubit>().pause();
                            } else {
                              context.read<PlayerCubit>().play();
                            }
                          },
                        ),
                        // Nút Đóng
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => context.read<PlayerCubit>().stop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
