import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: Container(
      //   height: 56,
      //   width: 56,
      //   decoration: BoxDecoration(
      //     shape: BoxShape.circle,
      //     gradient: LinearGradient(
      //       colors: [PrimaryColors.shade600, PrimaryColors.shade500],
      //       begin: Alignment.topCenter,
      //       end: Alignment.bottomCenter,
      //     ),
      //   ),
      //   child: FloatingActionButton(
      //     onPressed: () {},
      //     backgroundColor: Colors.transparent,
      //     splashColor: Colors.transparent,
      //     highlightElevation: 0,
      //     focusColor: Colors.transparent,
      //     hoverColor: Colors.transparent,
      //     foregroundColor: Colors.transparent,
      //     elevation: 0,
      //     shape: const CircleBorder(),
      //     child: const Icon(Icons.add_rounded, color: Colors.white, size: 50),
      //   ),
      // ),

      // BottomAppBar
      bottomNavigationBar: BottomAppBar(
        //shape: const CircularNotchedRectangle(),
        //notchMargin: 8.0,
        color: Colors.white,
        child: Row(
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
            _buildNavItem(Icons.search, Icons.search, 'Page 2', 1),
            // const SizedBox(width: 40),
            _buildNavItem(Icons.bookmark_border, Icons.bookmark, 'Page 3', 2),
            _buildNavItem(Icons.person_outline, Icons.person, 'Page 4', 3),
          ],
        ),
      ),
    );
  }

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
          // color: isSelected ? PrimaryColors.shade600 : NeutralColors.shade300,
        ),
        onPressed: () => _onTap(index),
      ),
    );
  }
}
