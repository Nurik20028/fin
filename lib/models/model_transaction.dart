import 'package:hive/hive.dart';

part 'model_transaction.g.dart';

@HiveType(typeId: 0)
class Model_Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String category;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String comment;

  @HiveField(6)
  double dollarSum;

  @HiveField(7)
  double? balanceAtPoint;

  Model_Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    required this.comment,
    required this.dollarSum,
    this.balanceAtPoint,
  });
  Model_Transaction copyWith({
    String? id,
    String? type,
    double? amount,
    String? category,
    DateTime? date,
    String? comment,
    double? dollarSum,
    double? balanceAtPoint,
  }) {
    return Model_Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      comment: comment ?? this.comment,
      dollarSum: dollarSum ?? this.dollarSum,
      balanceAtPoint: balanceAtPoint ?? this.balanceAtPoint,
    );
  }
}
