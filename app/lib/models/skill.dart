class Skill {
  final String id;
  final String type; // OFERTA | DESEJO
  final String title;
  final String category;
  final String mode; // PRESENCIAL | REMOTO
  final int creditsPerHour;
  final String userName;
  final double userRating;

  Skill({
    required this.id,
    required this.type,
    required this.title,
    required this.category,
    required this.mode,
    required this.creditsPerHour,
    required this.userName,
    required this.userRating,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return Skill(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      category: json['category'] ?? '',
      mode: json['mode'],
      creditsPerHour: json['creditsPerHour'] ?? 1,
      userName: user['name'] ?? '',
      userRating: double.tryParse('${user['ratingAvg'] ?? 0}') ?? 0,
    );
  }
}
