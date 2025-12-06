import 'package:audiobooks/presentation/widgets/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// ===============================================================

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({required this.navigationShell, super.key});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      resizeToAvoidBottomInset: false,
      // ======================= THAY ĐỔI LỚN TẠI ĐÂY =======================
      // Thay thế BottomAppBar bằng một Column chứa MiniPlayer và BottomAppBar.
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize
            .min, // Cực kỳ quan trọng, để Column chỉ chiếm chiều cao cần thiết
        children: [
          // Lớp trên: Mini Player sẽ hiển thị ở đây
          const MiniPlayer(),

          // Lớp dưới: BottomAppBar của bạn giữ nguyên
          BottomAppBar(
            height: 60,
            color: Colors.transparent,
            // Thêm padding bằng 0 để loại bỏ khoảng trống thừa (nếu có)
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
                _buildNavItem(
                  Icons.create_outlined,
                  Icons.create,
                  'Creator',
                  1,
                ),
                _buildNavItem(
                  Icons.library_books_outlined,
                  Icons.library_books,
                  'Library',
                  2,
                ),
                _buildNavItem(
                  Icons.person_outline,
                  Icons.person,
                  'Profile',
                  3,
                ), // Đổi tên 'Page 4' thành 'Profile' cho rõ nghĩa
              ],
            ),
          ),
        ],
      ),
      // ====================================================================
    );
  }

  // Hàm _buildNavItem không có gì thay đổi
  Widget _buildNavItem(
    IconData icon,
    IconData selectedIcon,
    String label,
    int index,
  ) {
    final isSelected = navigationShell.currentIndex == index;
    return Expanded(
      child: IconButton(
        icon: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? Colors.blue : Colors.black, // Ví dụ thêm màu
        ),
        onPressed: () => _onTap(index),
      ),
    );
  }
}
