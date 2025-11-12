// presentation/features/player/pages/player_page.dart
import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/presentation/features/player/cubit/player_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class PlayerPage extends StatelessWidget {
  final BookEntity book;

  const PlayerPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      //create: (context) => GetIt.instance<PlayerCubit>()..loadAudio(book.audioUrl),
      create: (context) =>
          GetIt.instance<PlayerCubit>()
            ..loadAudio(book.audioUrl, autoplay: true),
      child: Scaffold(
        appBar: AppBar(title: Text(book.title)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ảnh bìa
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    book.coverImageUrl,
                    height: 300,
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 32),
                // Tên sách và tác giả
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  book.author,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Thanh tiến trình và thời gian
                BlocBuilder<PlayerCubit, PlayerState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        Slider(
                          min: 0.0,
                          max: state.duration.inSeconds.toDouble(),
                          value: state.position.inSeconds.toDouble().clamp(
                            0.0,
                            state.duration.inSeconds.toDouble(),
                          ),
                          onChanged: (value) {
                            context.read<PlayerCubit>().seek(
                              Duration(seconds: value.toInt()),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(state.position)),
                              Text(_formatDuration(state.duration)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Nút điều khiển
                BlocBuilder<PlayerCubit, PlayerState>(
                  builder: (context, state) {
                    if (state.status == PlayerStatus.loading) {
                      return const CircularProgressIndicator();
                    }

                    final isPlaying = state.status == PlayerStatus.playing;
                    return IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 70.0,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          context.read<PlayerCubit>().pause();
                        } else {
                          context.read<PlayerCubit>().play();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }
}
