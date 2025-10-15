import 'package:audiobooks/presentation/features/auth/view/login_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:audiobooks/presentation/features/home/pages/home_page.dart';
import 'package:audiobooks/presentation/shell/main_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/login',
              builder: (context, state) => const LoginPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/page2',
              builder: (context, state) => Scaffold(
                appBar: AppBar(title: Text('Page 2')),
                body: Center(child: Text('Welcome to Page 2!')),
              ),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/page3',
              builder: (context, state) => Scaffold(
                appBar: AppBar(title: Text('Page 3')),
                body: Center(child: Text('Welcome to Page 3!')),
              ),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/page4',
              builder: (context, state) => Scaffold(
                appBar: AppBar(title: Text('Page 4')),
                body: Center(child: Text('Welcome to Page 4!')),
              ),
            ),
          ],
        ),
      ],
    ),

    // GoRoute(
    //   path: '/introduction',
    //   builder: (context, state) => const IntroductionPage(),
    // ),
  ],
);
