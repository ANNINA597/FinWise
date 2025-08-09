import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:valcaretask/splash_screen.dart';
import 'models/transaction_model.dart';
import 'tracker/tracker_bloc.dart';
import 'tracker/tracker_event.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter());
  await Hive.openBox<TransactionModel>('transactions');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionBox = Hive.box<TransactionModel>('transactions');
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>(
          create: (_) => TransactionBloc(transactionBox)..add(LoadTransactions()),
        ),
      ],
      child: MaterialApp(
        title: 'FinWise',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
