import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/presentation/features/player/cubit/player_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
// GoRouter không cần thiết ở đây nữa
// import 'package:go_router/go_router.dart';

class PlayerPage extends StatefulWidget {
  final List<BookEntity> books;
  final int initialIndex;

  const PlayerPage({
    super.key,
    required this.books,
    required this.initialIndex,
  });
  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  // ======================= THAY ĐỔI 1: TÁCH CUBIT RA NGOÀI BUILD =======================
  // Chúng ta sẽ tự quản lý vòng đời của Cubit thay vì phụ thuộc vào BlocProvider
  late final PlayerCubit _playerCubit;
  // ====================================================================================

  // Quản lý index và sách hiện tại trong state của widget
  late int currentIndex;
  late BookEntity currentBook;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    currentBook = widget.books[currentIndex];

    // Khởi tạo Cubit và tải audio ngay trong initState
    _playerCubit = GetIt.instance<PlayerCubit>();
    _playerCubit.loadAudio(currentBook.audioUrl, autoplay: true);
  }

  // ======================= THAY ĐỔI 2: TỰ DỌN DẸP CUBIT =======================
  // Khi widget này bị hủy (ví dụ khi người dùng nhấn Back), chúng ta phải tự gọi close()
  @override
  void dispose() {
    _playerCubit.close();
    super.dispose();
  }
  // ====================================================================================

  @override
  Widget build(BuildContext context) {
    // ======================= THAY ĐỔI 3: DÙNG BLOCPROVIDER.VALUE =======================
    // Chúng ta không `create` cubit mới nữa, mà `cung cấp` (provide)
    // cubit mà chúng ta đã tạo trong initState.
    return BlocProvider.value(
      value: _playerCubit,
      // ====================================================================================
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: Text(currentBook.title)),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        currentBook.coverImageUrl,
                        height: 300,
                        width: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      width: 300,
                      // Sử dụng Builder để có context hợp lệ
                      child: Builder(
                        builder: (overlayContext) {
                          return _buildSeekOverlay(overlayContext);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  currentBook.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  currentBook.author,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
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
                BlocBuilder<PlayerCubit, PlayerState>(
                  builder: (context, state) {
                    if (state.status == PlayerStatus.loading ||
                        state.status == PlayerStatus.loaded) {
                      return const SizedBox(
                        height: 70,
                        width: 70,
                        child: CircularProgressIndicator(),
                      );
                    }
                    final isPlaying = state.status == PlayerStatus.playing;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous, size: 40.0),
                          onPressed: currentIndex > 0
                              ? () => _changeTrack(-1)
                              : null,
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            size: 70.0,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            if (isPlaying) {
                              context.read<PlayerCubit>().pause();
                            } else {
                              context.read<PlayerCubit>().play();
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.skip_next, size: 40.0),
                          onPressed: currentIndex < widget.books.length - 1
                              ? () => _changeTrack(1)
                              : null,
                        ),
                      ],
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

  Widget _buildSeekOverlay(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.read<PlayerCubit>().seekBackward(),
            behavior: HitTestBehavior.opaque,
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => context.read<PlayerCubit>().seekForward(),
            behavior: HitTestBehavior.opaque,
          ),
        ),
      ],
    );
  }

  // ======================= THAY ĐỔI 4: VIẾT LẠI HOÀN TOÀN HÀM _changeTrack =======================
  void _changeTrack(int direction) {
    // Tính toán index mới
    final newIndex = currentIndex + direction;

    // Kiểm tra xem index có hợp lệ không
    if (newIndex < 0 || newIndex >= widget.books.length) {
      return;
    }

    // Cập nhật state của widget
    setState(() {
      currentIndex = newIndex;
      currentBook = widget.books[currentIndex];
    });

    // Ra lệnh cho Cubit đang tồn tại tải audio mới
    _playerCubit.loadAudio(currentBook.audioUrl, autoplay: true);
  }
  // ===============================================================================================

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }
}
