import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valcaretask/screens/login_screen.dart';
import 'package:valcaretask/screens/transaction_form.dart';
import 'package:valcaretask/screens/transactionhistory.dart';
import '../models/transaction_model.dart';
import '../tracker/tracker_bloc.dart';
import '../tracker/tracker_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return AddTransactionScreen();
      case 2:
        return TransactionHistory();
      default:
        return _buildDashboard();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('FinWise'),
        centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Logout'),
                    content:  Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child:  Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child:  Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  _logout();
                }
              },
              child: Text('Logout', style: TextStyle(color: Colors.black),),
            )
          ]
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items:  [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return  Center(child: CircularProgressIndicator());
        } else if (state is TransactionLoaded) {
          final transactions = state.transactions;

          final incomeTransactions =
          transactions.where((tx) => tx.type == 'Income').toList();
          final expenseTransactions =
          transactions.where((tx) => tx.type == 'Expense').toList();

          final totalIncome = incomeTransactions.fold<double>(0,
                (sum, tx) => sum + tx.amount,
          );

          final totalExpense = expenseTransactions.fold<double>(0,
                (sum, tx) => sum + tx.amount,
          );
          final balance = totalIncome - totalExpense;
          final Map<String, List<TransactionModel>> transactionsByMonth = {};
          for (var tx in transactions) {
            String key = DateFormat('yyyy-MM').format(tx.date);
            transactionsByMonth.putIfAbsent(key, () => []).add(tx);
          }
          final months =
          transactionsByMonth.isEmpty ? 1 : transactionsByMonth.length;
          final avgIncome = totalIncome / months;
          final avgExpense = totalExpense / months;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard('Total Income', totalIncome, Colors.green),
                SizedBox(height: 10),
                _buildSummaryCard('Total Expense', totalExpense, Colors.red),
                 SizedBox(height: 10),
                _buildSummaryCard('Balance', balance, Colors.blue),
                SizedBox(height: 10),
                _buildSummaryCard(
                    'Avg. Monthly Income', avgIncome, Colors.green.shade700),
                SizedBox(height: 10),
                _buildSummaryCard(
                    'Avg. Monthly Expense', avgExpense, Colors.red.shade700),
                SizedBox(height: 15),
                Text('Expense Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                _buildPieChart(totalIncome, totalExpense),
              ],
            ),
          );
        }
        else
        {
          return  Center(child: Text('Failed to load transactions.'));
        }
      },
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Icon(Icons.account_balance_wallet, color: color),
        title: Text(title),
        trailing: Text(
          '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(double income, double expense) {
    final total = income + expense;
    if (total == 0) {
      return  Center(child: Text('No data to display.'));
    }
    return AspectRatio(
      aspectRatio: 1.2,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: income,
              color: Colors.green,
              title: 'Income\n${((income / total) * 100).toStringAsFixed(1)}%',
              radius: 60,
              titleStyle:  TextStyle(color: Colors.white, fontSize: 12),
            ),
            PieChartSectionData(
              value: expense,
              color: Colors.red,
              title: 'Expense\n${((expense / total) * 100).toStringAsFixed(1)}%',
              radius: 60,
              titleStyle:  TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
          sectionsSpace: 4,
          centerSpaceRadius: 30,
        ),
      ),
    );
  }
}
