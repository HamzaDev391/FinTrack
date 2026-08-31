import '../../../core/database/app_database.dart';

class BudgetDetails {
  const BudgetDetails({
    required this.budget,
    required this.categoryName,
    required this.spent,
  });

  final Budget budget;
  final String categoryName;
  final int spent;

  int get remaining => budget.amount - spent;

  double get progress {
    if (budget.amount <= 0) {
      return 0.0;
    }

    return spent / budget.amount;
  }

  bool get isOverBudget => spent > budget.amount;
}
