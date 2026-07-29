class AppTransaction {
  final String id;
  final String status;
  final int creditsAgreed;
  final String requesterId;
  final String providerId;
  final String requesterName;
  final String providerName;
  final String skillTitle;
  final DateTime? requesterConfirmedAt;
  final DateTime? providerConfirmedAt;

  AppTransaction({
    required this.id,
    required this.status,
    required this.creditsAgreed,
    required this.requesterId,
    required this.providerId,
    required this.requesterName,
    required this.providerName,
    required this.skillTitle,
    required this.requesterConfirmedAt,
    required this.providerConfirmedAt,
  });

  factory AppTransaction.fromJson(Map<String, dynamic> json) {
    return AppTransaction(
      id: json['id'],
      status: json['status'],
      creditsAgreed: json['creditsAgreed'] ?? 1,
      requesterId: json['requesterId'],
      providerId: json['providerId'],
      requesterName: json['requester']?['name'] ?? '',
      providerName: json['provider']?['name'] ?? '',
      skillTitle: json['skill']?['title'] ?? '',
      requesterConfirmedAt: json['requesterConfirmedAt'] != null
          ? DateTime.tryParse(json['requesterConfirmedAt'])
          : null,
      providerConfirmedAt: json['providerConfirmedAt'] != null
          ? DateTime.tryParse(json['providerConfirmedAt'])
          : null,
    );
  }
}
