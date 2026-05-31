enum AccountType { cash, debit, credit, savings }

class Account {
  final int? id;
  final String name;
  final double balance;
  final AccountType type;
  final String icon;

  Account({
    this.id,
    required this.name,
    required this.balance,
    required this.type,
    this.icon = 'account_balance_wallet',
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'balance': balance,
    'type': type.name,
    'icon': icon,
  };

  factory Account.fromMap(Map<String, dynamic> map) => Account(
    id: map['id'] as int?,
    name: map['name'] as String,
    balance: (map['balance'] as num).toDouble(),
    type: AccountType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => AccountType.cash,
    ),
    icon: map['icon'] as String? ?? 'account_balance_wallet',
  );
}
