
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'transaction.dart';

enum CategoryType { income, expense, both }

class Category {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final CategoryType type;

  Category({
    String? id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color.value,
      'type': type.toString().split('.').last,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: Color(json['color']),
      type: _getCategoryTypeFromString(json['type']),
    );
  }

  static CategoryType _getCategoryTypeFromString(String typeStr) {
    switch (typeStr) {
      case 'income':
        return CategoryType.income;
      case 'expense':
        return CategoryType.expense;
      case 'both':
        return CategoryType.both;
      default:
        return CategoryType.expense;
    }
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    Color? color,
    CategoryType? type,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }
}
