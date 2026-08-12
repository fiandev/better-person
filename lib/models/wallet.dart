enum WalletType {
  checking,
  savings,
  travel,
  home,
  vehicle,
  general,
}

enum WalletIcon {
  wallet,
  savings,
  flight,
  home,
  car,
  bank,
}

class Wallet {
  final String id;
  final String name;
  final WalletType type;
  final WalletIcon icon;
  final double initialBalance;
  final double currentBalance;
  final String accountNumber; // Last 4 digits or full masked number
  final DateTime createdAt;

  Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.initialBalance,
    required this.currentBalance,
    required this.accountNumber,
    required this.createdAt,
  });

  String getIconName() {
    switch (icon) {
      case WalletIcon.wallet:
        return 'account_balance_wallet';
      case WalletIcon.savings:
        return 'savings';
      case WalletIcon.flight:
        return 'flight_takeoff';
      case WalletIcon.home:
        return 'home_work';
      case WalletIcon.car:
        return 'directions_car';
      case WalletIcon.bank:
        return 'account_balance';
    }
  }

  String getTypeName() {
    switch (type) {
      case WalletType.checking:
        return 'Checking';
      case WalletType.savings:
        return 'Savings';
      case WalletType.travel:
        return 'Travel';
      case WalletType.home:
        return 'Home';
      case WalletType.vehicle:
        return 'Vehicle';
      case WalletType.general:
        return 'General';
    }
  }

  Wallet copyWith({
    String? id,
    String? name,
    WalletType? type,
    WalletIcon? icon,
    double? initialBalance,
    double? currentBalance,
    String? accountNumber,
    DateTime? createdAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      accountNumber: accountNumber ?? this.accountNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'icon': icon.name,
      'initialBalance': initialBalance,
      'currentBalance': currentBalance,
      'accountNumber': accountNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      name: json['name'] as String,
      type: WalletType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WalletType.general,
      ),
      icon: WalletIcon.values.firstWhere(
        (e) => e.name == json['icon'],
        orElse: () => WalletIcon.wallet,
      ),
      initialBalance: (json['initialBalance'] as num).toDouble(),
      currentBalance: (json['currentBalance'] as num).toDouble(),
      accountNumber: json['accountNumber'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
