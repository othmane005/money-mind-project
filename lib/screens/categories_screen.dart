
import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/category.dart';
import '../widgets/category_form.dart';
import '../widgets/categories_list.dart';
import '../widgets/bottom_navigation.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final DataService _dataService = DataService();
  List<Category> _categories = [];
  bool _isLoading = true;
  bool _showForm = false;
  
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Catégories',
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
                ),
                
                if (_showForm)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CategoryForm(
                      onCategoryAdded: () {
                        _loadCategories();
                        setState(() {
                          _showForm = false;
                        });
                      },
                    ),
                  ),
                
                Expanded(
                  child: CategoriesList(
                    categories: _categories,
                    onCategoryDeleted: _loadCategories,
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
    );
  }
}
