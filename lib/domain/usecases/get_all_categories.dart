// lib/domain/usecases/get_all_categories.dart

import 'package:flossy/domain/entities/category.dart';
import 'package:flossy/domain/repositories/transaction_repository.dart'; // We can reuse the transaction repository for this

class GetAllCategories {
  final TransactionRepository repository;

  GetAllCategories(this.repository);

  Future<List<Category>> call() {
    // This assumes your TransactionRepository has a method to get categories.
    // We will add this method to the repository interface now.
    return repository.getAllCategories();
  }
}
