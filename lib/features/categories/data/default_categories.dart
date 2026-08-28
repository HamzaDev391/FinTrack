import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

final defaultCategories = [
  CategoriesCompanion.insert(
    name: 'Food',
    type: 'expense',
    icon: 'restaurant',
    isDefault: const Value(true),
  ),
  CategoriesCompanion.insert(
    name: 'Transport',
    type: 'expense',
    icon: 'directions_car',
    isDefault: const Value(true),
  ),
  CategoriesCompanion.insert(
    name: 'Shopping',
    type: 'expense',
    icon: 'shopping_bag',
    isDefault: const Value(true),
  ),
  CategoriesCompanion.insert(
    name: 'Bills',
    type: 'expense',
    icon: 'receipt_long',
    isDefault: const Value(true),
  ),
  CategoriesCompanion.insert(
    name: 'Entertainment',
    type: 'expense',
    icon: 'movie',
    isDefault: const Value(true),
  ),
  CategoriesCompanion.insert(
    name: 'Health',
    type: 'expense',
    icon: 'favorite',
    isDefault: const Value(true),
  ),
  CategoriesCompanion.insert(
    name: 'Education',
    type: 'expense',
    icon: 'school',
    isDefault: const Value(true),
  ),
  CategoriesCompanion.insert(
    name: 'Other',
    type: 'expense',
    icon: 'more_horiz',
    isDefault: const Value(true),
  ),
  CategoriesCompanion.insert(
    name: 'Salary',
    type: 'income',
    icon: 'work',
    isDefault: const Value(true),
  ),
  CategoriesCompanion.insert(
    name: 'Freelance',
    type: 'income',
    icon: 'laptop',
    isDefault: const Value(true),
  ),
  CategoriesCompanion.insert(
    name: 'Business',
    type: 'income',
    icon: 'business',
    isDefault: const Value(true),
  ),
  CategoriesCompanion.insert(
    name: 'Gift',
    type: 'income',
    icon: 'card_giftcard',
    isDefault: const Value(true),
  ),
  CategoriesCompanion.insert(
    name: 'Investment',
    type: 'income',
    icon: 'trending_up',
    isDefault: const Value(true),
  ),
  CategoriesCompanion.insert(
    name: 'Other',
    type: 'income',
    icon: 'more_horiz',
    isDefault: const Value(true),
  ),
];
