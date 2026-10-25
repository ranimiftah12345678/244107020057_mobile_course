import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// REFACTOR 3: breakpoint hanya didefinisikan satu kali.
const double kWideBreakpoint = 700;

void main() => runApp(const DashboardApp());

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.indigo),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Overview'),
        actions: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              ),
              const SizedBox(width: 4),
              Semantics(
                label: 'Mode gelap',
                child: CupertinoSwitch(
                  value: isDark,
                  onChanged: onDarkChanged,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // REFACTOR 3: memakai konstanta, bukan angka 700 langsung.
          final columns = constraints.maxWidth >= kWideBreakpoint ? 2 : 1;

          return Column(
            children: [
              const ProfileHeader(),
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.6,
                  children: const [
                    // REFACTOR 1: DashboardCard diganti InfoCard.
                    InfoCard(title: 'Assignments', value: '8'),
                    InfoCard(title: 'Attendance', value: '92%'),
                    InfoCard(title: 'Portfolio', value: 'Ready'),
                    InfoCard(title: 'Current week', value: '02'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // REFACTOR 2: warna dan gaya teks diambil dari tema.
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Semantics(
      container: true,
      label:
          'Profil mahasiswa: Rani Miftahus Saadah, NIM 244107020057, Teknik Informatika',
      child: ExcludeSemantics(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                child: const Icon(Icons.person),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rani Miftahus Saadah',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '244107020057 | Teknik Informatika',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// REFACTOR 1: widget reusable yang menerima title dan value.
class InfoCard extends StatelessWidget {
  const InfoCard({required this.title, required this.value, super.key});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: '$title: $value',
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Expanded(child: Text(title, style: textTheme.bodyLarge)),
              Text(value, style: textTheme.headlineSmall),
            ]),
          ),
        ),
      ),
    );
  }
}