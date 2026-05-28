import 'package:flutter/material.dart';
import 'package:finance/services/dollar_api_service.dart';

class CurrencyProvider with ChangeNotifier {
  double _dollarCourse = 0.0;
  bool _isLoading = true;

  double get dollarCourse => _dollarCourse;
  bool get isLoading => _isLoading;

  Future<void> fetchCurrency() async {
    if (_dollarCourse != 0.0 && _dollarCourse != 89.0) return;
    _isLoading = true;
    notifyListeners();

    try {
      final apiService = DollarApiService();
      _dollarCourse = await apiService.getDollarCourse();
      print("Currency updated successfully: $_dollarCourse");
    } catch (e) {
      print("Используем резервный курс, так как API недоступен: $e");
    // значение на  случай, чтобы не ломалось,
    // когда лимит в месяц на сайте fx.kg закончился и данные не приходят
      if (_dollarCourse == 0.0) _dollarCourse = 89.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double convertToUsd(double kgsAmount) {
    if (_dollarCourse <= 0) return 0.0;
    return kgsAmount / _dollarCourse;
  }
}
