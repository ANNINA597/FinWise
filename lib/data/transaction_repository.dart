import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final Box<TransactionModel> _transactionBox;
  TransactionRepository(this._transactionBox);

  List<TransactionModel> getAllTransactions() {
    return _transactionBox.values.toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionBox.add(transaction);
  }

  Future<void> updateTransaction(int index, TransactionModel transaction) async {
    await _transactionBox.putAt(index, transaction);
  }

  Future<void> deleteTransaction(int index) async {
    await _transactionBox.deleteAt(index);
  }

  TransactionModel? getTransaction(int index) {
    return _transactionBox.getAt(index);
  }

  Future<void> clearTransactions() async {
    await _transactionBox.clear();
  }
}
