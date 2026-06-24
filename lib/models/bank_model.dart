class BankAccountModel {
  final String id;
  final String accountHolder;
  final String accountNumber;
  final String bankName;
  final String? branchName;
  final String? currency;

  BankAccountModel({
    required this.id,
    required this.accountHolder,
    required this.accountNumber,
    required this.bankName,
    this.branchName = '',
    this.currency = 'USD',
  });
}
