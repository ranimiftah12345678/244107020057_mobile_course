class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;

  static Announcement fromJson(Map<String, dynamic> json) => Announcement(
        id: json['id']?.toString() ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );
}

// Daftar pengumuman mock (meniru data dari API)
const kMockAnnouncements = [
  Announcement(
    id: '1',
    title: 'Jadwal kuliah berubah',
    body: 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
  ),
  Announcement(
    id: '2',
    title: 'Pengumuman UTS',
    body: 'UTS dilaksanakan minggu depan. Siapkan materi dari minggu 1-7.',
  ),
  Announcement(
    id: '3',
    title: 'Pembayaran SPP',
    body: 'Batas akhir pembayaran SPP semester ini tanggal 30 November 2026.',
  ),
];
