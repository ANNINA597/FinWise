import 'package:hive/hive.dart';
part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final double amount;
  @HiveField(1)
  final String type;
  @HiveField(2)
  final String category;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final String? note;
  TransactionModel({
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });
}


