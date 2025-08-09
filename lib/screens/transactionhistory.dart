import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:valcaretask/screens/transaction_form.dart';
import '../tracker/tracker_bloc.dart';
import '../tracker/tracker_event.dart';
import '../tracker/tracker_state.dart';
import 'dashboard_screen.dart';
class TransactionHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read<TransactionBloc>().add(LoadTransactions());
    return Scaffold(
      backgroundColor:  Color(0xFFF8F8F8),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  DashboardScreen()),
            );
          },
        ),
        title: Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Color(0xFF8E5AF7),
      ),
        floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF8E5AF7),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) =>  AddTransactionScreen()),
        ),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoaded) {
            if (state.transactions.isEmpty) {
              return  Center(
                child: Text(
                  'No transactions yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              padding:  EdgeInsets.all(12),
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final t = state.transactions[index];
                final isIncome = t.type == 'Income';
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin:  EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      t.category,
                      style:  TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${t.date.toLocal().toString().split(' ')[0]} • ${t.note ?? ''}',
                      style: TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: SizedBox(
                      width: 120,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          Text(
                            '₹${t.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:  Icon(Icons.edit, size: 20, color: Colors.blueGrey),
                                padding: EdgeInsets.zero,
                                constraints:  BoxConstraints(),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddTransactionScreen(
                                      index: index,
                                      existingTransaction: t,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 4),
                              IconButton(
                                icon:  Icon(Icons.delete, size: 20, color: Colors.redAccent),
                                padding: EdgeInsets.zero,
                                constraints:  BoxConstraints(),
                                onPressed: () {
                                  context.read<TransactionBloc>().add(DeleteTransaction(index));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  ),
                );
              },
            );
          }
          return  Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
