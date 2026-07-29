import 'skill.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String? bio;
  final int creditBalance;
  final double ratingAvg;
  final List<Skill> skills;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.bio,
    required this.creditBalance,
    required this.ratingAvg,
    required this.skills,
  });

  List<Skill> get oferece => skills.where((s) => s.type == 'OFERTA').toList();
  List<Skill> get quer => skills.where((s) => s.type == 'DESEJO').toList();

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      bio: json['bio'],
      creditBalance: json['creditBalance'] ?? 0,
      ratingAvg: double.tryParse('${json['ratingAvg'] ?? 0}') ?? 0,
      skills: ((json['skills'] as List?) ?? [])
          .map((s) => Skill.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
