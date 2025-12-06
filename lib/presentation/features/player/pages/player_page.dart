import 'package:audiobooks/domain/entities/book_entity.dart';
import 'package:audiobooks/presentation/features/player/cubit/player_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});
  // Constructor không cần nhận tham số nữa.
  // ====================================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Chỉ bọc widget Text trong BlocBuilder để nó tự cập nhật
        title: BlocBuilder<PlayerCubit, PlayerState>(
          // buildWhen để tối ưu, chỉ build lại khi sách thay đổi
          buildWhen: (previous, current) =>
              previous.currentBook != current.currentBook,
          builder: (context, state) {
            return Text(
              state.currentBook?.title ?? 'Trình phát',
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
      ),
      // body của Scaffold sẽ là một BlocBuilder để xử lý các trạng thái chính
      body: BlocBuilder<PlayerCubit, PlayerState>(
        // buildWhen để tối ưu, chỉ build lại khi status hoặc sách thay đổi
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.currentBook != current.currentBook,
        builder: (context, state) {
          final BookEntity? currentBook = state.currentBook;

          // Xử lý trạng thái dừng hoặc không có sách
          if (state.status == PlayerStatus.stopped || currentBook == null) {
            return const Center(
              child: Text(
                "Không có sách nào đang phát.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Nếu có sách, gọi hàm helper để build UI tương ứng
          return _buildPlayerUI(context, currentBook);
        },
      ),
    );
  }

  // Hàm helper để build UI chính, tránh lặp code
  Widget _buildPlayerUI(BuildContext context, BookEntity book) {
    final bool isPersonalBook = book.coverImageUrl.startsWith('assets/');

    return isPersonalBook
        ? _buildPersonalBookLayout(context, book)
        : _buildStandardBookLayout(context, book);
  }

  // / Widget này sẽ kiểm tra xem `imageUrl` là một URL http hay một đường dẫn asset
  // / và hiển thị widget tương ứng.
  Widget _buildCoverImage(BuildContext context, String imageUrl) {
    final isNetworkImage = imageUrl.startsWith('http');

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: SizedBox(
            height: 300,
            width: 300,
            // Nếu là ảnh mạng, dùng Image.network
            child: isNetworkImage
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    // Xử lý lỗi nếu URL mạng không tải được
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.book,
                        size: 100,
                        color: Colors.grey,
                      );
                    },
                  )
                // Nếu là ảnh asset, dùng Image.asset
                : Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    // Xử lý lỗi nếu đường dẫn asset sai
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey,
                      );
                    },
                  ),
          ),
        ),
        SizedBox(
          height: 300,
          width: 300,
          child: Builder(
            builder: (overlayContext) {
              return _buildSeekOverlay(context);
            },
          ),
        ),
      ],
    );
  }

  /// Layout này có phần mô tả cuộn được và các thành phần khác được cố định.
  Widget _buildPersonalBookLayout(BuildContext context, BookEntity book) {
    return Column(
      children: [
        // --- PHẦN CỐ ĐỊNH Ở TRÊN ---
        const SizedBox(height: 20),
        Text(
          book.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          book.author, // 'Tài liệu cá nhân'
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // --- PHẦN MÔ TẢ CÓ THỂ CUỘN ---
        Expanded(
          // Bọc Container trong một Stack
          child: Stack(
            children: [
              // Lớp dưới: Nội dung mô tả
              Container(
                width:
                    double.infinity, // Đảm bảo container chiếm hết chiều rộng
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    book.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                ),
              ),
              // Lớp trên: Lớp phủ GestureDetector để tua tới/lui
              // Chúng ta gọi lại hàm _buildSeekOverlay đã có sẵn
              Builder(
                builder: (overlayContext) {
                  return _buildSeekOverlay(overlayContext);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // --- PHẦN ĐIỀU KHIỂN CỐ ĐỊNH Ở DƯỚI ---
        _buildSeekBar(context),
        const SizedBox(height: 16),
        _buildPlayerControls(context),
        const SizedBox(height: 10),
      ],
    );
  }

  /// Layout này hiển thị ảnh bìa và đã được fix lỗi khoảng trống thừa.
  Widget _buildStandardBookLayout(BuildContext context, BookEntity book) {
    return SingleChildScrollView(
      child: Column(
        // Xóa mainAxisAlignment để nội dung bắt đầu từ trên cùng
        children: [
          const SizedBox(height: 20),
          _buildCoverImage(context, book.coverImageUrl),
          const SizedBox(height: 32),
          Text(
            book.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            book.author,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildSeekBar(context),
          const SizedBox(height: 16),
          _buildPlayerControls(context),
        ],
      ),
    );
  }

  /// Widget cho thanh trượt và hiển thị thời gian
  Widget _buildSeekBar(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
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
    );
  }

  /// Widget cho các nút Play/Pause, Next, Previous...
  Widget _buildPlayerControls(BuildContext context) {
    // Sử dụng BlocBuilder để rebuild widget mỗi khi state thay đổi
    return BlocBuilder<PlayerCubit, PlayerState>(
      // buildWhen có thể giúp tối ưu, chỉ rebuild khi các thuộc tính liên quan thay đổi
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.currentIndex != current.currentIndex,
      builder: (context, state) {
        // ---- Xử lý trạng thái Loading ----
        if (state.status == PlayerStatus.loading) {
          return const SizedBox(
            height: 70, // Giữ chiều cao để layout không bị "nhảy"
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // ---- Lấy các thông tin cần thiết từ state ----
        final isPlaying = state.status == PlayerStatus.playing;
        final cubit = context.read<PlayerCubit>();

        // Kiểm tra xem có thể tua tới/lui được không
        final canGoNext = state.currentIndex < state.playlist.length - 1;
        final canGoPrevious = state.currentIndex > 0;

        // ---- Build UI ----
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Nút Replay
              IconButton(
                icon: const Icon(Icons.replay, size: 28.0),
                tooltip: 'Phát lại từ đầu',
                onPressed: () => cubit.replay(),
              ),

              // Nút Previous
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 36.0),
                // Vô hiệu hóa nút nếu không thể tua lùi
                onPressed: canGoPrevious ? () => cubit.playPrevious() : null,
              ),

              // Thêm SizedBox để tạo khoảng cách
              const SizedBox(width: 16),

              // Nút Play/Pause
              IconButton(
                iconSize: 64.0,
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  if (isPlaying) {
                    cubit.pause();
                  } else {
                    cubit.play();
                  }
                },
              ),

              // Thêm SizedBox để tạo khoảng cách
              const SizedBox(width: 16),

              // Nút Next
              IconButton(
                icon: const Icon(Icons.skip_next, size: 36.0),
                // Vô hiệu hóa nút nếu không thể tua tới
                onPressed: canGoNext ? () => cubit.playNext() : null,
              ),

              // Nút Speed
              IconButton(
                icon: const Icon(Icons.speed, size: 28.0),
                tooltip: 'Thay đổi tốc độ',
                onPressed: () {
                  // `_showSpeedSelector` là một hàm trong class PlayerPage,
                  // nó cần context để hoạt động.
                  _showSpeedSelector(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Hiển thị một bottom sheet cho phép người dùng chọn tốc độ phát.
  void _showSpeedSelector(BuildContext buildContext) {
    // Lấy state hiện tại từ cubit
    final cubit = buildContext.read<PlayerCubit>();
    final currentSpeed = cubit.state.speed;
    final speedOptions = [1.0, 1.25, 1.5, 1.75, 2.0];

    showModalBottomSheet(
      context: buildContext,
      // Hình dạng bo tròn ở góc trên
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Chiều cao vừa đủ nội dung
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tốc độ phát',
                style: Theme.of(buildContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // Dùng Wrap để các lựa chọn tự động xuống hàng nếu không đủ chỗ
              Wrap(
                spacing: 12.0, // Khoảng cách ngang
                runSpacing: 12.0, // Khoảng cách dọc
                children: speedOptions.map((speed) {
                  final isSelected = currentSpeed == speed;
                  return ChoiceChip(
                    label: Text('${speed}x'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        cubit.setSpeed(speed);
                        Navigator.of(
                          sheetContext,
                        ).pop(); // Đóng bottom sheet sau khi chọn
                      }
                    },
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(buildContext).colorScheme.onPrimary
                          : Theme.of(buildContext).colorScheme.onSurface,
                    ),
                    selectedColor: Theme.of(buildContext).colorScheme.primary,
                    backgroundColor: Theme.of(
                      buildContext,
                    ).colorScheme.surfaceContainerHighest,
                    pressElevation: 5,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }
}
