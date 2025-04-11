
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/data_service.dart';

class TransactionsList extends StatefulWidget {
  final List<Transaction> transactions;
  final Function? onTransactionDeleted;

  const TransactionsList({
    super.key, 
    required this.transactions,
    this.onTransactionDeleted,
  });

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  final DataService _dataService = DataService();
  List<Category> _categories = [];
  bool _isLoading = true;
  String _searchTerm = '';
  
  Transaction? _transactionToDelete;
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }
  
  Future<void> _loadCategories() async {
    try {
      final categories = await _dataService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Map<String, Category> get _categoryMap {
    return {for (var c in _categories) c.id: c};
  }
  
  List<Transaction> get _filteredTransactions {
    if (_searchTerm.isEmpty) {
      return widget.transactions;
    }
    
    final term = _searchTerm.toLowerCase();
    return widget.transactions.where((transaction) {
      final category = _categoryMap[transaction.categoryId];
      return transaction.description.toLowerCase().contains(term) || 
             (category != null && category.name.toLowerCase().contains(term));
    }).toList();
  }
  
  void _confirmDelete(Transaction transaction) {
    setState(() {
      _transactionToDelete = transaction;
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette transaction ? Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _transactionToDelete = null;
              });
            },
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              _deleteTransaction();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteTransaction() async {
    if (_transactionToDelete == null) return;
    
    try {
      await _dataService.deleteTransaction(_transactionToDelete!.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction supprimée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      
      if (widget.onTransactionDeleted != null) {
        widget.onTransactionDeleted!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression de la transaction'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() {
      _transactionToDelete = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (widget.transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Aucune transaction trouvée. Ajoutez une transaction pour commencer.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher des transactions...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchTerm = value;
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _filteredTransactions[index];
              final category = _categoryMap[transaction.categoryId];
              
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: category?.color ?? Colors.grey,
                    child: Icon(
                      _getCategoryIcon(category?.icon),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    transaction.description.isNotEmpty
                        ? transaction.description
                        : category?.name ?? 'Non catégorisé',
                  ),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy').format(transaction.date)} ${category != null ? '• ${category.name}' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${transaction.type == TransactionType.income ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: transaction.type == TransactionType.income
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(transaction),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  IconData _getCategoryIcon(String? iconName) {
    if (iconName == null) return Icons.category;
    
    // Map string icon names to Flutter IconData
    switch (iconName) {
      case 'account_balance':
        return Icons.account_balance;
      case 'trending_up':
        return Icons.trending_up;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'directions_car':
        return Icons.directions_car;
      case 'tv':
        return Icons.tv;
      case 'restaurant':
        return Icons.restaurant;
      case 'home':
        return Icons.home;
      case 'gift':
        return Icons.card_giftcard;
      case 'phone':
        return Icons.phone;
      case 'book':
        return Icons.book;
      case 'banknote':
        return Icons.money;
      case 'activity':
        return Icons.fitness_center;
      case 'coffee':
        return Icons.coffee;
      default:
        return Icons.category;
    }
  }
}
