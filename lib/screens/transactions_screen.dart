
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../models/transaction.dart';
import '../widgets/transaction_form.dart';
import '../widgets/transactions_list.dart';
import '../widgets/bottom_navigation.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final DataService _dataService = DataService();
  List<Transaction> _allTransactions = [];
  bool _isLoading = true;
  bool _showForm = false;
  
  // Filters
  String _filterType = 'all';
  DateTime? _dateFrom;
  DateTime? _dateTo;
  
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }
  
  Future<void> _loadTransactions() async {
    try {
      final transactions = await _dataService.getTransactions();
      
      // Apply filters
      final filteredTransactions = _applyFilters(transactions);
      
      // Sort by date (descending)
      filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
      
      setState(() {
        _allTransactions = filteredTransactions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  List<Transaction> _applyFilters(List<Transaction> transactions) {
    return transactions.where((transaction) {
      // Filter by type
      if (_filterType != 'all') {
        final filterTypeEnum = _filterType == 'income' 
            ? TransactionType.income 
            : TransactionType.expense;
        
        if (transaction.type != filterTypeEnum) {
          return false;
        }
      }
      
      // Filter by date range
      if (_dateFrom != null && transaction.date.isBefore(_dateFrom!)) {
        return false;
      }
      
      if (_dateTo != null) {
        // Add one day to include the end date
        final adjustedDateTo = _dateTo!.add(const Duration(days: 1));
        
        if (transaction.date.isAfter(adjustedDateTo)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }
  
  void _resetFilters() {
    setState(() {
      _filterType = 'all';
      _dateFrom = null;
      _dateTo = null;
    });
    
    _loadTransactions();
  }
  
  Future<void> _selectDateFrom() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        _dateFrom = picked;
      });
      
      _loadTransactions();
    }
  }
  
  Future<void> _selectDateTo() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        _dateTo = picked;
      });
      
      _loadTransactions();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transactions',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showForm = !_showForm;
                              });
                            },
                            child: Text(_showForm ? 'Masquer' : 'Ajouter'),
                          ),
                        ],
                      ),
                      
                      if (_showForm) ...[
                        const SizedBox(height: 16),
                        TransactionForm(
                          onTransactionAdded: () {
                            _loadTransactions();
                            setState(() {
                              _showForm = false;
                            });
                          },
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Filters
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.filter_list),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Filtres:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  
                                  if (_filterType != 'all' || _dateFrom != null || _dateTo != null) ...[
                                    const Spacer(),
                                    TextButton(
                                      onPressed: _resetFilters,
                                      child: const Text('Réinitialiser'),
                                    ),
                                  ]
                                ],
                              ),
                              const SizedBox(height: 8),
                              
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  // Type filter
                                  DropdownButton<String>(
                                    value: _filterType,
                                    onChanged: (value) {
                                      setState(() {
                                        _filterType = value!;
                                      });
                                      _loadTransactions();
                                    },
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'all',
                                        child: Text('Tous les types'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'income',
                                        child: Text('Revenus'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'expense',
                                        child: Text('Dépenses'),
                                      ),
                                    ],
                                  ),
                                  
                                  // Date from
                                  OutlinedButton.icon(
                                    onPressed: _selectDateFrom,
                                    icon: const Icon(Icons.calendar_today, size: 16),
                                    label: Text(
                                      _dateFrom != null 
                                          ? 'De: ${DateFormat('dd/MM/yyyy').format(_dateFrom!)}'
                                          : 'Date de début',
                                    ),
                                  ),
                                  
                                  // Date to
                                  OutlinedButton.icon(
                                    onPressed: _selectDateTo,
                                    icon: const Icon(Icons.calendar_today, size: 16),
                                    label: Text(
                                      _dateTo != null 
                                          ? 'À: ${DateFormat('dd/MM/yyyy').format(_dateTo!)}'
                                          : 'Date de fin',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: TransactionsList(
                    transactions: _allTransactions,
                    onTransactionDeleted: _loadTransactions,
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }
}
