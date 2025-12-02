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
    // Kiểm tra xem đây có phải là sách cá nhân không dựa vào đường dẫn ảnh
    final bool isPersonalBook = currentBook.coverImageUrl.startsWith('assets/');
    // ======================= THAY ĐỔI 3: DÙNG BLOCPROVIDER.VALUE =======================
    // Chúng ta không `create` cubit mới nữa, mà `cung cấp` (provide)
    // cubit mà chúng ta đã tạo trong initState.
    return BlocProvider.value(
      value: _playerCubit,
      // ====================================================================================
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(currentBook.title, overflow: TextOverflow.ellipsis),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            // Dựa vào loại sách để build layout tương ứng
            child: isPersonalBook
                ? _buildPersonalBookLayout(context) // Layout cho sách cá nhân
                : _buildStandardBookLayout(context), // Layout cho sách có sẵn
          ),
        ),
      ),
    );
  }

  // / Widget này sẽ kiểm tra xem `imageUrl` là một URL http hay một đường dẫn asset
  // / và hiển thị widget tương ứng.
  Widget _buildCoverImage(String imageUrl) {
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
              return _buildSeekOverlay(overlayContext);
            },
          ),
        ),
      ],
    );
  }

  /// Layout này có phần mô tả cuộn được và các thành phần khác được cố định.
  Widget _buildPersonalBookLayout(BuildContext context) {
    return Column(
      children: [
        // --- PHẦN CỐ ĐỊNH Ở TRÊN ---
        const SizedBox(height: 20),
        Text(
          currentBook.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          currentBook.author, // 'Tài liệu cá nhân'
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
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    currentBook.description,
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
  Widget _buildStandardBookLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        // Xóa mainAxisAlignment để nội dung bắt đầu từ trên cùng
        children: [
          const SizedBox(height: 20),
          _buildCoverImage(currentBook.coverImageUrl),
          const SizedBox(height: 32),
          Text(
            currentBook.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            currentBook.author,
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
                _playerCubit.seek(Duration(seconds: value.toInt()));
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
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        if (state.status == PlayerStatus.loading ||
            state.status == PlayerStatus.loaded) {
          return const SizedBox(
            height: 70,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final isPlaying = state.status == PlayerStatus.playing;
        // ... trong hàm _buildPlayerControls ...
        return FittedBox(
          // ======================= THAY ĐỔI 1: BỌC ROW TRONG FITTEDBOX =======================
          // FittedBox sẽ đảm bảo Row và các nút bên trong không bao giờ bị overflow.
          // Nó sẽ tự động scale nhỏ mọi thứ lại nếu cần.
          fit: BoxFit.scaleDown, // Đảm bảo nó chỉ scale nhỏ, không phóng to
          // =================================================================================
          child: Row(
            // Sử dụng MainAxisAlignment.center và SizedBox để kiểm soát khoảng cách chính xác
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Nút Replay
              IconButton(
                icon: const Icon(Icons.replay, size: 28.0),
                tooltip: 'Phát lại từ đầu',
                onPressed: () => _playerCubit.replay(),
              ),

              // Nút Previous
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 36.0),
                onPressed: currentIndex > 0 ? () => _changeTrack(-1) : null,
              ),

              // Thêm SizedBox để tạo khoảng cách
              const SizedBox(width: 16),

              // Nút Play/Pause
              IconButton(
                iconSize: 64.0, // Đặt kích thước ở đây
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  if (isPlaying) {
                    _playerCubit.pause();
                  } else {
                    _playerCubit.play();
                  }
                },
              ),

              // Thêm SizedBox để tạo khoảng cách
              const SizedBox(width: 16),

              // Nút Next
              IconButton(
                icon: const Icon(Icons.skip_next, size: 36.0),
                onPressed: currentIndex < widget.books.length - 1
                    ? () => _changeTrack(1)
                    : null,
              ),

              // Nút Speed
              IconButton(
                icon: const Icon(Icons.speed, size: 28.0),
                tooltip: 'Thay đổi tốc độ',
                onPressed: () {
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
                    ).colorScheme.surfaceVariant,
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
