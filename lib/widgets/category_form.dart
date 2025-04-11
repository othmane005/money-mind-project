
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/data_service.dart';

class CategoryForm extends StatefulWidget {
  final Function? onCategoryAdded;

  const CategoryForm({super.key, this.onCategoryAdded});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final DataService _dataService = DataService();
  
  String _name = '';
  String _icon = 'category';
  Color _color = Colors.blue;
  CategoryType _type = CategoryType.expense;
  
  static final List<String> _iconOptions = [
    'home', 'shopping_cart', 'directions_car', 'restaurant', 'tv', 
    'card_giftcard', 'phone', 'book', 'money', 'trending_up', 
    'fitness_center', 'coffee', 'category'
  ];
  
  static final List<Color> _colorOptions = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.pink,
    Colors.purple,
    Colors.blueGrey,
    Colors.brown,
    Colors.cyan,
  ];
  
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final category = Category(
        name: _name,
        icon: _icon,
        color: _color,
        type: _type,
      );
      
      try {
        await _dataService.addCategory(category);
        
        // Reset form
        setState(() {
          _name = '';
          _icon = 'category';
          _color = Colors.blue;
          _type = CategoryType.expense;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catégorie ajoutée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Notify parent
        if (widget.onCategoryAdded != null) {
          widget.onCategoryAdded!();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'ajout de la catégorie'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajouter une catégorie',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              // Category Name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nom de la catégorie'),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Saisir le nom de la catégorie',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir un nom de catégorie';
                      }
                      return null;
                    },
                    onSaved: (value) => _name = value!,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Type and Icon row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Type'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<CategoryType>(
                          value: _type,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _type = value!;
                            });
                          },
                          items: const [
                            DropdownMenuItem(
                              value: CategoryType.income,
                              child: Text('Revenu'),
                            ),
                            DropdownMenuItem(
                              value: CategoryType.expense,
                              child: Text('Dépense'),
                            ),
                            DropdownMenuItem(
                              value: CategoryType.both,
                              child: Text('Les deux'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Icon
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Icône'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _icon,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _icon = value!;
                            });
                          },
                          items: _iconOptions.map((iconName) {
                            return DropdownMenuItem(
                              value: iconName,
                              child: Row(
                                children: [
                                  Icon(_getIconData(iconName)),
                                  const SizedBox(width: 8),
                                  Text(_getIconDisplayName(iconName)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Color
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Couleur'),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: _colorOptions.length,
                    itemBuilder: (context, index) {
                      final color = _colorOptions[index];
                      final isSelected = _color == color;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _color = color;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : color,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                      );
                    },
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
                    child: Text('Ajouter la catégorie'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getIconData(String iconName) {
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
  
  String _getIconDisplayName(String iconName) {
    switch (iconName) {
      case 'home':
        return 'Maison';
      case 'shopping_cart':
        return 'Courses';
      case 'directions_car':
        return 'Voiture';
      case 'restaurant':
        return 'Restaurant';
      case 'tv':
        return 'TV';
      case 'card_giftcard':
        return 'Cadeau';
      case 'phone':
        return 'Téléphone';
      case 'book':
        return 'Livre';
      case 'money':
        return 'Argent';
      case 'trending_up':
        return 'Investissement';
      case 'fitness_center':
        return 'Activité';
      case 'coffee':
        return 'Café';
      default:
        return 'Catégorie';
    }
  }
}
