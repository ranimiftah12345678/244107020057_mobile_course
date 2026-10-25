import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/stats_page.dart';

void main() => runApp(
      ProviderScope(
        child: MaterialApp(
          title: 'Statistik',
          theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
          home: const StatsPage(),
        ),
      ),
    );