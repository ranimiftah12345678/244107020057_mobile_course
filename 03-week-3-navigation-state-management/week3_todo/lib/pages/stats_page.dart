import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';

// ConsumerWidget memungkinkan halaman membaca state dari Riverpod.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pantau provider agar tampilan diperbarui saat loading, error, atau sukses.
    final statsAsync = ref.watch(statsProvider);

    // Scaffold menyediakan kerangka layar dan when menangani tiap status async.
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: statsAsync.when(
        // Tampilkan spinner selama data sedang dimuat.
        loading: () => const Center(child: CircularProgressIndicator()),
        // Tampilkan pesan error dan tombol untuk mengulang permintaan.
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat statistik: $error'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(statsProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        // Tampilkan setiap statistik sebagai baris di dalam daftar.
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.bar_chart),
            title: Text(stats[index]),
          ),
        ),
      ),
    );
  }
}
