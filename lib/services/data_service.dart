
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference get _transactionsCollection => _firestore.collection('transactions');
  CollectionReference get _categoriesCollection => _firestore.collection('categories');

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

  // Initialize Firestore with default data if empty
  Future<void> initializeFirestoreData() async {
    // Check if categories collection is empty
    final categoriesSnapshot = await _categoriesCollection.get();
    if (categoriesSnapshot.docs.isEmpty) {
      // Add initial categories
      for (var category in _initialCategories) {
        await _categoriesCollection.doc(category.id).set(category.toJson());
      }
    }
    
    // Check if transactions collection is empty
    final transactionsSnapshot = await _transactionsCollection.get();
    if (transactionsSnapshot.docs.isEmpty) {
      // Add initial transactions
      for (var transaction in _initialTransactions) {
        await _transactionsCollection.doc(transaction.id).set(transaction.toJson());
      }
    }
  }

  // Get all transactions
  Future<List<Transaction>> getTransactions() async {
    await initializeFirestoreData();
    
    final snapshot = await _transactionsCollection.get();
    return snapshot.docs.map((doc) => 
      Transaction.fromJson(doc.data() as Map<String, dynamic>)
    ).toList();
  }

  // Get all categories
  Future<List<Category>> getCategories() async {
    await initializeFirestoreData();
    
    final snapshot = await _categoriesCollection.get();
    return snapshot.docs.map((doc) => 
      Category.fromJson(doc.data() as Map<String, dynamic>)
    ).toList();
  }

  // Add a new transaction
  Future<Transaction> addTransaction(Transaction transaction) async {
    await _transactionsCollection.doc(transaction.id).set(transaction.toJson());
    return transaction;
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    await _transactionsCollection.doc(id).delete();
  }

  // Add a new category
  Future<Category> addCategory(Category category) async {
    await _categoriesCollection.doc(category.id).set(category.toJson());
    return category;
  }

  // Update a category
  Future<Category> updateCategory(Category updatedCategory) async {
    await _categoriesCollection.doc(updatedCategory.id).set(updatedCategory.toJson());
    return updatedCategory;
  }

  // Delete a category
  Future<void> deleteCategory(String id) async {
    // Delete the category
    await _categoriesCollection.doc(id).delete();
    
    // Find and delete all transactions with this category
    final snapshot = await _transactionsCollection
        .where('categoryId', isEqualTo: id)
        .get();
    
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
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
