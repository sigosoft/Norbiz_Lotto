enum TicketStatus { pending, won, lost }

class TicketModel {
  final String id;
  final String gameName;
  final String numbers;
  final String date;
  final double betAmount;
  final double? winAmount;
  final TicketStatus status;
  final String? currency;
  final String? statusLabel;

  TicketModel({
    required this.id,
    required this.gameName,
    required this.numbers,
    required this.date,
    required this.betAmount,
    this.winAmount,
    required this.status,
    this.currency,
    this.statusLabel,
  });
}
