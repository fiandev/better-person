enum TransactionType {
  income,
  expense,
  transfer,
}

enum TransactionCategory {
  // Expense categories
  foodAndDrink,
  transport,
  groceries,
  shopping,
  utilities,
  entertainment,
  healthcare,
  education,
  other,
  
  // Income categories
  salary,
  freelance,
  investment,
  gift,
  refund,
  
  // Transfer category
  transfer,
}

class Transaction {
  final String id;
  final String walletId;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  
  // For transfers between wallets
  final String? toWalletId;
  final String? fromWalletId;

  Transaction({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    required this.createdAt,
    this.toWalletId,
    this.fromWalletId,
  });

  String getCategoryLabel() {
    switch (category) {
      case TransactionCategory.foodAndDrink:
        return 'Food & Drink';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.groceries:
        return 'Groceries';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.healthcare:
        return 'Healthcare';
      case TransactionCategory.education:
        return 'Education';
      case TransactionCategory.salary:
        return 'Salary';
      case TransactionCategory.freelance:
        return 'Freelance';
      case TransactionCategory.investment:
        return 'Investment';
      case TransactionCategory.gift:
        return 'Gift';
      case TransactionCategory.refund:
        return 'Refund';
      case TransactionCategory.transfer:
        return 'Transfer';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  String getCategoryIcon() {
    switch (category) {
      case TransactionCategory.foodAndDrink:
        return 'restaurant';
      case TransactionCategory.transport:
        return 'directions_car';
      case TransactionCategory.groceries:
        return 'shopping_cart';
      case TransactionCategory.shopping:
        return 'shopping_bag';
      case TransactionCategory.utilities:
        return 'bolt';
      case TransactionCategory.entertainment:
        return 'movie';
      case TransactionCategory.healthcare:
        return 'medical_services';
      case TransactionCategory.education:
        return 'school';
      case TransactionCategory.salary:
        return 'payments';
      case TransactionCategory.freelance:
        return 'work';
      case TransactionCategory.investment:
        return 'trending_up';
      case TransactionCategory.gift:
        return 'card_giftcard';
      case TransactionCategory.refund:
        return 'receipt_long';
      case TransactionCategory.transfer:
        return 'swap_horiz';
      case TransactionCategory.other:
        return 'more_horiz';
    }
  }

  Transaction copyWith({
    String? id,
    String? walletId,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    String? toWalletId,
    String? fromWalletId,
  }) {
    return Transaction(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      toWalletId: toWalletId ?? this.toWalletId,
      fromWalletId: fromWalletId ?? this.fromWalletId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'toWalletId': toWalletId,
      'fromWalletId': fromWalletId,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      walletId: json['walletId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TransactionCategory.other,
      ),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      toWalletId: json['toWalletId'] as String?,
      fromWalletId: json['fromWalletId'] as String?,
    );
  }
}
