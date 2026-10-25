import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/pages/stats_page.dart';
import 'package:week3_todo/providers/stats_provider.dart';

class _PendingStatsNotifier extends StatsNotifier {
  _PendingStatsNotifier(this.response);

  final Completer<void> response;

  @override
  Future<void> waitForResponse() => response.future;

  @override
  bool get shouldFail => false;
}

class _FailingStatsNotifier extends StatsNotifier {
  @override
  Future<void> waitForResponse() async {}

  @override
  bool get shouldFail => true;
}

void main() {
  testWidgets('menampilkan loading lalu data statistik', (tester) async {
    final response = Completer<void>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(
            () => _PendingStatsNotifier(response),
          ),
        ],
        child: const MaterialApp(home: StatsPage()),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    response.complete();
    await tester.pumpAndSettle();

    expect(find.text('Total pengguna: 1.250'), findsOneWidget);
    expect(find.text('Pesanan hari ini: 86'), findsOneWidget);
    expect(find.text('Pendapatan bulan ini: Rp 12.500.000'), findsOneWidget);
  });

  testWidgets('menampilkan pesan error dan tombol retry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(_FailingStatsNotifier.new),
        ],
        child: const MaterialApp(home: StatsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Gagal memuat statistik: Bad state: Terjadi kesalahan saat mengambil statistik.',
      ),
      findsOneWidget,
    );
    expect(find.text('Coba lagi'), findsOneWidget);

    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Coba lagi'), findsOneWidget);
  });
}
