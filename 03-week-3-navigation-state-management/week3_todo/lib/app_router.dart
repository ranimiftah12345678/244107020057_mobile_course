import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/stats_page.dart';
import 'pages/todo_detail_page.dart';
import 'pages/todo_page.dart';

// Router menjaga kedua halaman dalam branch agar state navigasinya tetap terpisah.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: navigationShell.goBranch,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.checklist),
              label: 'ToDo',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart),
              label: 'Statistik',
            ),
          ],
        ),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const TodoPage(),
              routes: [
                GoRoute(
                  path: 'todo/:index',
                  builder: (context, state) => TodoDetailPage(
                    index: int.tryParse(state.pathParameters['index'] ?? ''),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
