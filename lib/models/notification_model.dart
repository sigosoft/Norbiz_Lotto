class NotificationModel {
  final int id;
  final String type;
  final String titleEn;
  final String titleFr;
  final String titleHt;
  final String bodyEn;
  final String bodyFr;
  final String bodyHt;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.titleEn,
    required this.titleFr,
    required this.titleHt,
    required this.bodyEn,
    required this.bodyFr,
    required this.bodyHt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      type: json['type']?.toString() ?? '',
      titleEn: json['title_en']?.toString() ?? '',
      titleFr: json['title_fr']?.toString() ?? '',
      titleHt: json['title_ht']?.toString() ?? '',
      bodyEn: json['body_en']?.toString() ?? '',
      bodyFr: json['body_fr']?.toString() ?? '',
      bodyHt: json['body_ht']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
