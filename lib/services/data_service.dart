
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import 'package:flutter/material.dart';

class DataService {
  static const String _transactionsKey = 'transactions';
  static const String _categoriesKey = 'categories';

  // Initial categories
  static final List<Category> _initialCategories = [
    Category(
      id: "cat1",
      name: "Salaire",
      icon: "account_balance",
      color: Colors.green,
      type: CategoryType.income,
    ),
    Category(
      id: "cat2",
      name: "Investissements",
      icon: "trending_up",
      color: Colors.blue,
      type: CategoryType.income,
    ),
    Category(
      id: "cat3",
      name: "Courses",
      icon: "shopping_cart",
      color: Colors.orange,
      type: CategoryType.expense,
    ),
    Category(
      id: "cat4",
      name: "Transport",
      icon: "directions_car",
      color: Colors.blueGrey,
      type: CategoryType.expense,
    ),
    Category(
      id: "cat5",
      name: "Divertissement",
      icon: "tv",
      color: Colors.purple,
      type: CategoryType.expense,
    ),
    Category(
      id: "cat6",
      name: "Restauration",
      icon: "restaurant",
      color: Colors.pink,
      type: CategoryType.expense,
    ),
  ];

  // Initial transactions
  static final List<Transaction> _initialTransactions = [
    Transaction(
      id: "t1",
      amount: 3000,
      type: TransactionType.income,
      categoryId: "cat1",
      description: "Salaire mensuel",
      date: DateTime(2025, 4, 1),
    ),
    Transaction(
      id: "t2",
      amount: 500,
      type: TransactionType.income,
      categoryId: "cat2",
      description: "Dividendes",
      date: DateTime(2025, 4, 5),
    ),
    Transaction(
      id: "t3",
      amount: 150,
      type: TransactionType.expense,
      categoryId: "cat3",
      description: "Courses hebdomadaires",
      date: DateTime(2025, 4, 7),
    ),
    Transaction(
      id: "t4",
      amount: 45,
      type: TransactionType.expense,
      categoryId: "cat4",
      description: "Essence",
      date: DateTime(2025, 4, 8),
    ),
    Transaction(
      id: "t5",
      amount: 30,
      type: TransactionType.expense,
      categoryId: "cat5",
      description: "Billets de cinéma",
      date: DateTime(2025, 4, 9),
    ),
    Transaction(
      id: "t6",
      amount: 75,
      type: TransactionType.expense,
      categoryId: "cat6",
      description: "Dîner avec des amis",
      date: DateTime(2025, 4, 10),
    ),
  ];

  // Get all transactions
  Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsJson = prefs.getString(_transactionsKey);
    
    if (transactionsJson == null) {
      // Save initial data if nothing exists
      await saveData(_transactionsKey, _initialTransactions);
      return _initialTransactions;
    }
    
    List<dynamic> decoded = jsonDecode(transactionsJson);
    return decoded.map((item) => Transaction.fromJson(item)).toList();
  }

  // Get all categories
  Future<List<Category>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? categoriesJson = prefs.getString(_categoriesKey);
    
    if (categoriesJson == null) {
      // Save initial data if nothing exists
      await saveData(_categoriesKey, _initialCategories);
      return _initialCategories;
    }
    
    List<dynamic> decoded = jsonDecode(categoriesJson);
    return decoded.map((item) => Category.fromJson(item)).toList();
  }

  // Generic save data method
  Future<void> saveData<T>(String key, List<T> data) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      data.map((item) => (item as dynamic).toJson()).toList()
    );
    await prefs.setString(key, encodedData);
  }

  // Add a new transaction
  Future<Transaction> addTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await saveData(_transactionsKey, transactions);
    return transaction;
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    final transactions = await getTransactions();
    final updatedTransactions = transactions.where((t) => t.id != id).toList();
    await saveData(_transactionsKey, updatedTransactions);
  }

  // Add a new category
  Future<Category> addCategory(Category category) async {
    final categories = await getCategories();
    categories.add(category);
    await saveData(_categoriesKey, categories);
    return category;
  }

  // Update a category
  Future<Category> updateCategory(Category updatedCategory) async {
    final categories = await getCategories();
    final updatedCategories = categories.map((category) => 
      category.id == updatedCategory.id ? updatedCategory : category
    ).toList();
    
    await saveData(_categoriesKey, updatedCategories);
    return updatedCategory;
  }

  // Delete a category
  Future<void> deleteCategory(String id) async {
    final categories = await getCategories();
    final updatedCategories = categories.where((c) => c.id != id).toList();
    await saveData(_categoriesKey, updatedCategories);
    
    // Also remove any transactions with this category
    final transactions = await getTransactions();
    final updatedTransactions = transactions.where((t) => t.categoryId != id).toList();
    await saveData(_transactionsKey, updatedTransactions);
  }

  // Get transaction summary
  Future<Map<String, double>> getTransactionSummary() async {
    final transactions = await getTransactions();
    
    final double totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (total, t) => total + t.amount);
        
    final double totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (total, t) => total + t.amount);
        
    final double balance = totalIncome - totalExpense;
    
    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance
    };
  }

  // Get category summary
  Future<List<Map<String, dynamic>>> getCategorySummary(TransactionType type) async {
    final transactions = await getTransactions();
    final categories = await getCategories();
    
    // Filter by transaction type
    final filteredTransactions = transactions.where((t) => t.type == type).toList();
    
    // Group by category
    final categorySummary = categories
        .where((c) => 
            c.type == (type == TransactionType.income 
              ? CategoryType.income 
              : CategoryType.expense) || 
            c.type == CategoryType.both)
        .map((category) {
          final categoryTransactions = filteredTransactions
              .where((t) => t.categoryId == category.id)
              .toList();
          
          final double total = categoryTransactions.fold(
              0, (sum, t) => sum + t.amount);
          
          return {
            'category': category,
            'total': total,
            'count': categoryTransactions.length
          };
        })
        .where((summary) => summary['count'] > 0)
        .toList();
    
    // Sort by total amount (descending)
    categorySummary.sort((a, b) => (b['total'] as double).compareTo(a['total'] as double));
        
    return categorySummary;
  }
}
