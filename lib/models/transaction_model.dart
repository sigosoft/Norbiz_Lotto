enum TransactionType { deposit, withdrawal }
enum TransactionStatus { completed, processing, failed }

class TransactionModel {
  final String id;
  final TransactionType type;
  final String title;
  final String date;
  final double amount;
  final TransactionStatus status;

  TransactionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
  });
}
