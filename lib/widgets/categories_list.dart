
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/data_service.dart';

class CategoriesList extends StatefulWidget {
  final List<Category> categories;
  final Function? onCategoryDeleted;

  const CategoriesList({
    super.key, 
    required this.categories,
    this.onCategoryDeleted,
  });

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  final DataService _dataService = DataService();
  bool _isLoading = false;
  Category? _categoryToDelete;
  
  Future<int> _getCategoryUsageCount(String categoryId) async {
    final transactions = await _dataService.getTransactions();
    return transactions.where((t) => t.categoryId == categoryId).length;
  }
  
  void _confirmDelete(Category category) async {
    setState(() {
      _isLoading = true;
      _categoryToDelete = category;
    });
    
    final usageCount = await _getCategoryUsageCount(category.id);
    
    setState(() {
      _isLoading = false;
    });
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: usageCount > 0
            ? Text(
                'Cette catégorie est utilisée dans $usageCount transactions. La suppression entraînera également la suppression de ces transactions. Cette action ne peut pas être annulée.',
              )
            : const Text(
                'Êtes-vous sûr de vouloir supprimer cette catégorie ? Cette action ne peut pas être annulée.',
              ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _categoryToDelete = null;
              });
            },
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              _deleteCategory();
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
  
  Future<void> _deleteCategory() async {
    if (_categoryToDelete == null) return;
    
    try {
      await _dataService.deleteCategory(_categoryToDelete!.id);
      
      final usageCount = await _getCategoryUsageCount(_categoryToDelete!.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usageCount > 0
                ? 'Catégorie et $usageCount transactions associées supprimées avec succès'
                : 'Catégorie supprimée avec succès',
          ),
          backgroundColor: Colors.green,
        ),
      );
      
      if (widget.onCategoryDeleted != null) {
        widget.onCategoryDeleted!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression de la catégorie'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() {
      _categoryToDelete = null;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (widget.categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Aucune catégorie trouvée. Ajoutez une catégorie pour commencer.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: widget.categories.length,
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        
        return FutureBuilder<int>(
          future: _getCategoryUsageCount(category.id),
          builder: (context, snapshot) {
            final usageCount = snapshot.data ?? 0;
            
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: category.color,
                  child: Icon(
                    _getCategoryIcon(category.icon),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getCategoryTypeChip(category.type),
                    const SizedBox(height: 4),
                    Text(
                      usageCount > 0 
                          ? '$usageCount transactions' 
                          : 'Non utilisé',
                      style: TextStyle(
                        color: usageCount > 0 ? null : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(category),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _getCategoryTypeChip(CategoryType type) {
    Color chipColor;
    String label;
    
    switch (type) {
      case CategoryType.income:
        chipColor = Colors.green.shade100;
        label = 'Revenu';
        break;
      case CategoryType.expense:
        chipColor = Colors.red.shade100;
        label = 'Dépense';
        break;
      case CategoryType.both:
        chipColor = Colors.purple.shade100;
        label = 'Les deux';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: chipColor.withAlpha(255),
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon(String iconName) {
    // Map string icon names to Flutter IconData
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'directions_car':
        return Icons.directions_car;
      case 'restaurant':
        return Icons.restaurant;
      case 'tv':
        return Icons.tv;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'phone':
        return Icons.phone;
      case 'book':
        return Icons.book;
      case 'money':
        return Icons.money;
      case 'trending_up':
        return Icons.trending_up;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'coffee':
        return Icons.coffee;
      default:
        return Icons.category;
    }
  }
}
