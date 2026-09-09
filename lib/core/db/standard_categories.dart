/// The 10 standard categories seeded into the database (SRS §4: ids 1–10;
/// emoji & colors per `DESIGN.md` §2).
library;

final class StandardCategory {
  const StandardCategory(this.id, this.name, this.emoji, this.colorHex);

  final int id;
  final String name;
  final String emoji;
  final String colorHex;
}

const List<StandardCategory> standardCategories = [
  StandardCategory(1, 'Maintenance', '🔧', '#FB6F3D'),
  StandardCategory(2, 'Rumah', '🏠', '#C49A00'),
  StandardCategory(3, 'Perawatan', '💆', '#E63946'),
  StandardCategory(4, 'Kesehatan', '💊', '#2DC653'),
  StandardCategory(5, 'Keuangan', '💰', '#2D6CDB'),
  StandardCategory(6, 'Digital', '💻', '#7B61FF'),
  StandardCategory(7, 'Sosial', '👥', '#FF6B6B'),
  StandardCategory(8, 'Admin', '📋', '#4A4A4A'),
  StandardCategory(9, 'Kendaraan', '🚗', '#27AE60'),
  StandardCategory(10, 'Lainnya', '📌', '#888888'),
];

/// Safety-critical (SRS §3.2): the Kesehatan category locks the reminder
/// tone to `SUPORTIF` — sarcastic tones are disabled in the form.
const int kHealthCategoryId = 4;
