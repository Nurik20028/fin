import 'package:flutter/material.dart';
import 'package:finance/models/model_transaction.dart';
import 'package:hive/hive.dart';

class LocalSumProvider with ChangeNotifier {
  final Box<Model_Transaction> _historyBox = Hive.box<Model_Transaction>(
      'history',
  );

  double get realTotalBalance {
    try {

      print("Items in history box: ${_historyBox.length}");

      double total = 0.0;
      for (var item in _historyBox.values) {
        if (item.type == 'income') {
          total += item.amount;
        } else {
          total -= item.amount;
        }
      }
      return total;
    } catch (e) {
      print("Error in balance calculation: $e");
      return 0.0;
    }
  }

  List<Model_Transaction> sortCategoryListTransactions(String categoryName) {
    return _historyBox.values.where((item) => item.category == categoryName).toList();
  }

  List<Model_Transaction> sortDateListTransactions(DateTime date) {
    return _historyBox.values
    .where(
        (item) =>
        item.date.day == date.day &&
            item.date.month == date.month &&
            item.date.year == date.year,
    )
    .toList();
  }

  List<Model_Transaction> sortTypeTransactions(String type) {
    return _historyBox.values.where((item) => item.type == type).toList();
  }

  List<Model_Transaction> querySearchListCommentTransactions(String query) {
    if (query.isEmpty) return _historyBox.values.toList();

    return _historyBox.values
    .where(
        (item) => item.comment.toLowerCase().contains(query.toLowerCase()),
    )
    .toList();
  }

  bool canAfford(double amount) {
    return realTotalBalance >= amount;
  }

  void refresh() {
    notifyListeners();
  }
}

