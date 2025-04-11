
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/data_service.dart';

class TransactionForm extends StatefulWidget {
  final Function? onTransactionAdded;

  const TransactionForm({super.key, this.onTransactionAdded});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final DataService _dataService = DataService();
  
  TransactionType _transactionType = TransactionType.expense;
  String _amount = '';
  String? _categoryId;
  String _description = '';
  DateTime _date = DateTime.now();
  
  List<Category> _categories = [];
  bool _isLoading = true;
  
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
  
  List<Category> get _filteredCategories {
    final categoryType = _transactionType == TransactionType.income 
        ? CategoryType.income 
        : CategoryType.expense;
    
    return _categories.where((c) => 
        c.type == categoryType || c.type == CategoryType.both).toList();
  }
  
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final transaction = Transaction(
        amount: double.parse(_amount),
        type: _transactionType,
        categoryId: _categoryId!,
        description: _description,
        date: _date,
      );
      
      try {
        await _dataService.addTransaction(transaction);
        
        // Reset form
        setState(() {
          _amount = '';
          _categoryId = null;
          _description = '';
          _date = DateTime.now();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction ajoutée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Notify parent
        if (widget.onTransactionAdded != null) {
          widget.onTransactionAdded!();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'ajout de la transaction'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajouter une transaction',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              // Type and Amount row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Type'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<TransactionType>(
                          value: _transactionType,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _transactionType = value!;
                              // Clear category when type changes
                              _categoryId = null;
                            });
                          },
                          items: const [
                            DropdownMenuItem(
                              value: TransactionType.income,
                              child: Text('Revenu'),
                            ),
                            DropdownMenuItem(
                              value: TransactionType.expense,
                              child: Text('Dépense'),
                            ),
                          ],
                          validator: (value) => value == null 
                              ? 'Veuillez sélectionner un type' 
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Montant (€)'),
                        const SizedBox(height: 8),
                        TextFormField(
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '0.00',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un montant';
                            }
                            
                            if (double.tryParse(value) == null) {
                              return 'Veuillez entrer un nombre valide';
                            }
                            
                            if (double.parse(value) <= 0) {
                              return 'Le montant doit être supérieur à 0';
                            }
                            
                            return null;
                          },
                          onSaved: (value) => _amount = value!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Category and Date row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Catégorie'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _categoryId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Sélectionner une catégorie'),
                          onChanged: (value) {
                            setState(() {
                              _categoryId = value;
                            });
                          },
                          items: _filteredCategories.map((category) {
                            return DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          validator: (value) => value == null 
                              ? 'Veuillez sélectionner une catégorie' 
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(_date),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Description'),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Description de la transaction',
                    ),
                    maxLines: 2,
                    onSaved: (value) => _description = value ?? '',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Ajouter la transaction'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
