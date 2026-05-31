class GoalContribution {
  final int? id;
  final int goalId;
  final double amount;
  final DateTime date;

  GoalContribution({
    this.id,
    required this.goalId,
    required this.amount,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'goalId': goalId,
    'amount': amount,
    'date': date.toIso8601String(),
  };

  factory GoalContribution.fromMap(Map<String, dynamic> map) => GoalContribution(
    id: map['id'] as int?,
    goalId: map['goalId'] as int,
    amount: (map['amount'] as num).toDouble(),
    date: DateTime.parse(map['date'] as String),
  );
}

class Goal {
  final int? id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final String deadline;
  final String icon;
  final String colorHex;

  Goal({
    this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.deadline,
    this.icon = 'flight_takeoff',
    this.colorHex = '0xFF000000',
  });

  double get progress => targetAmount > 0
      ? (savedAmount / targetAmount).clamp(0.0, 1.0)
      : 0.0;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'savedAmount': savedAmount,
    'deadline': deadline,
    'icon': icon,
    'colorHex': colorHex,
  };

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
    id: map['id'] as int?,
    title: map['title'] as String,
    targetAmount: (map['targetAmount'] as num).toDouble(),
    savedAmount: (map['savedAmount'] as num).toDouble(),
    deadline: map['deadline'] as String,
    icon: map['icon'] as String? ?? 'flight_takeoff',
    colorHex: map['colorHex'] as String? ?? '0xFF000000',
  );

  Goal copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? savedAmount,
    String? deadline,
    String? icon,
    String? colorHex,
  }) => Goal(
    id: id ?? this.id,
    title: title ?? this.title,
    targetAmount: targetAmount ?? this.targetAmount,
    savedAmount: savedAmount ?? this.savedAmount,
    deadline: deadline ?? this.deadline,
    icon: icon ?? this.icon,
    colorHex: colorHex ?? this.colorHex,
  );
}
