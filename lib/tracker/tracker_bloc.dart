import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:valcaretask/tracker/tracker_event.dart';
import 'package:valcaretask/tracker/tracker_state.dart';
import '../../models/transaction_model.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final Box<TransactionModel> transactionBox;

  TransactionBloc(this.transactionBox) : super(TransactionInitial()) {
    on<LoadTransactions>((event, emit) {
      final transactions = transactionBox.values.toList();
      emit(TransactionLoaded(transactions));
    });

    on<AddTransaction>((event, emit) async {
      await transactionBox.add(event.transaction);
      final updatedList = transactionBox.values.toList();
      emit(TransactionLoaded(updatedList));
    });

    on<UpdateTransaction>((event, emit) async {
      await transactionBox.putAt(event.index, event.transaction);
      final updatedList = transactionBox.values.toList();
      emit(TransactionLoaded(updatedList));
    });

    on<DeleteTransaction>((event, emit) async {
      await transactionBox.deleteAt(event.index);
      final updatedList = transactionBox.values.toList();
      emit(TransactionLoaded(updatedList));
    });
  }
}
