import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo/app_router.dart';
import 'package:week3_todo/main.dart';
import 'package:week3_todo/providers/stats_provider.dart';

class _ImmediateStatsNotifier extends StatsNotifier {
  @override
  Future<void> waitForResponse() async {}

  @override
  bool get shouldFail => false;
}

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(_ImmediateStatsNotifier.new),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    expect(find.text('Tidak ada tugas yang belum selesai'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle(); // PENYESUAIAN 3: tunggu dialog selesai menutup

    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);

    await tester.tap(find.text('Kerjakan PR minggu 3'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Tugas'), findsOneWidget);
    expect(find.text('Belum selesai'), findsOneWidget);

    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);

    appRouter.go('/todo/0');
    await tester.pumpAndSettle();
    expect(find.text('Detail Tugas'), findsOneWidget);

    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Statistik'));
    await tester.pumpAndSettle();
    expect(find.text('Total pengguna: 1.250'), findsOneWidget);

    await tester.tap(find.text('ToDo'));
    await tester.pump();
    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });
}