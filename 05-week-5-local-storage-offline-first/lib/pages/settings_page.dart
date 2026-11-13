import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final lastOpenedAsync = ref.watch(lastOpenedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        children: [
          // --- Tema ---
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Mode Gelap'),
            subtitle: const Text('Ubah tema aplikasi'),
            trailing: darkModeAsync.when(
              data: (isDark) => Switch(
                value: isDark,
                onChanged: (_) =>
                    ref.read(darkModeProvider.notifier).toggle(),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => const Icon(Icons.error),
            ),
          ),
          const Divider(),
          // --- Terakhir dibuka ---
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Terakhir Dibuka'),
            subtitle: lastOpenedAsync.when(
              data: (dt) => dt == null
                  ? const Text('Belum pernah dibuka')
                  : Text(
                      DateFormat('dd MMM yyyy, HH:mm:ss').format(dt.toLocal()),
                    ),
              loading: () => const Text('Memuat...'),
              error: (e, st) => const Text('Error'),
            ),
          ),
          const Divider(),
          // --- Info storage ---
          const ListTile(
            leading: Icon(Icons.storage_outlined),
            title: Text('Penyimpanan'),
            subtitle: Text(
              'SharedPreferences: preferensi (tema, waktu)\n'
              'SQLite (sqflite): catatan offline',
            ),
            isThreeLine: true,
          ),
          const Divider(),
          // --- Tentang ---
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Tentang Aplikasi'),
            subtitle: Text(
              'Week 5 — Local Storage & Offline First\n'
              'Rani Miftahus Saadah — 244107020057',
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}
