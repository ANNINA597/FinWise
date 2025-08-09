import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/transaction_model.dart';
import '../tracker/tracker_bloc.dart';
import '../tracker/tracker_event.dart';
import 'dashboard_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  final int? index;
  final TransactionModel? existingTransaction;
  const AddTransactionScreen({this.index, this.existingTransaction, super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedType = 'Income';
  String _selectedCategory = 'Salary';
  DateTime _selectedDate = DateTime.now();
  final _incomeCategories = ['Salary','Misc'];
  final _expenseCategories = ['Food','Transport','Bills','Rent','Misc'];

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      final t = widget.existingTransaction!;
      _amountController.text = t.amount.toString();
      _noteController.text = t.note ?? '';
      _selectedType = t.type;
      _selectedCategory = t.category;
      _selectedDate = t.date;
    }
  }

  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      final transaction = TransactionModel(
        amount: double.parse(_amountController.text),
        type: _selectedType,
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteController.text,
      );
      final bloc = context.read<TransactionBloc>();
      if (widget.index != null) {
        bloc.add(UpdateTransaction(widget.index!, transaction));
      }
      else
      {
        bloc.add(AddTransaction(transaction));
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == 'Income' ? _incomeCategories : _expenseCategories;
    return Scaffold(
      backgroundColor: Color(0xFFF7F1FF),
      appBar: AppBar(
        backgroundColor: Color(0xFF8E5AF7),
        title: Text(
          widget.index != null ? 'Edit Transaction' : 'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => DashboardScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixIcon:  Icon(Icons.attach_money, color: Color(0xFF8E5AF7)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Enter amount' : null,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      prefixIcon:  Icon(Icons.swap_vert, color: Color(0xFF8E5AF7)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['Income', 'Expense']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                        _selectedCategory = (_selectedType == 'Income')
                            ? _incomeCategories[0]
                            : _expenseCategories[0];
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon:  Icon(Icons.category, color: Color(0xFF8E5AF7)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: categories
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading:  Icon(Icons.calendar_today, color: Color(0xFF8E5AF7)),
                    title: Text(
                      'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                      style:  TextStyle(fontSize: 16),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Note (optional)',
                      prefixIcon:  Icon(Icons.note, color: Color(0xFF8E5AF7)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  Color(0xFF8E5AF7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        widget.index != null ? 'Update Transaction' : 'Add Transaction',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
