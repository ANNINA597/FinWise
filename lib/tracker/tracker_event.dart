import 'package:equatable/equatable.dart';
import '../../models/transaction_model.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final TransactionModel transaction;

  const AddTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransaction extends TransactionEvent {
  final int index;
  final TransactionModel transaction;

  const UpdateTransaction(this.index, this.transaction);

  @override
  List<Object?> get props => [index, transaction];
}

class DeleteTransaction extends TransactionEvent {
  final int index;

  const DeleteTransaction(this.index);

  @override
  List<Object?> get props => [index];
}
