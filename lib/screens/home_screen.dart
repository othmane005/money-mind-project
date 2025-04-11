
import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/transaction.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/transaction_form.dart';
import '../widgets/transactions_list.dart';
import '../widgets/charts.dart';
import '../widgets/bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataService _dataService = DataService();
  List<Transaction> _recentTransactions = [];
  bool _isLoading = true;
  bool _showForm = false;
  
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }
  
  Future<void> _loadTransactions() async {
    try {
      final transactions = await _dataService.getTransactions();
      
      // Sort by date (descending) and get only recent 5
      transactions.sort((a, b) => b.date.compareTo(a.date));
      final recentTransactions = transactions.take(5).toList();
      
      setState(() {
        _recentTransactions = recentTransactions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.credit_card, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'MoneyMind',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                background: Paint()
                  ..shader = const LinearGradient(
                    colors: [Colors.green, Colors.blue],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [Colors.green, Colors.blue],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadTransactions();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Tableau de bord',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  const DashboardSummary(),
                  const SizedBox(height: 24),
                  
                  if (_showForm) ...[
                    TransactionForm(
                      onTransactionAdded: () {
                        _loadTransactions();
                        setState(() {
                          _showForm = false;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showForm = true;
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter une transaction'),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  const Charts(),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Transactions récentes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  
                  SizedBox(
                    height: 300,
                    child: TransactionsList(
                      transactions: _recentTransactions,
                      onTransactionDeleted: _loadTransactions,
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 0),
    );
  }
}
