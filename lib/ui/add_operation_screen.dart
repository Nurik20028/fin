import 'package:flutter/material.dart';
import 'package:finance/components/my_gradient.dart';
import 'package:finance/models/model_category.dart';
import 'package:finance/models/model_transaction.dart';
import 'package:finance/river_states/currency_provider.dart';
import 'package:finance/river_states/local_sum_provider.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddOperationScreen extends StatefulWidget {
  const AddOperationScreen({super.key});

  @override
  State<AddOperationScreen> createState() => _AddOperationScreenState();
}

class _AddOperationScreenState extends State<AddOperationScreen> {
  final TextEditingController _sumController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  late List<Model_Category> redCategories;
  late List<Model_Category> greenCategories;

  String _selectedType = 'income';
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _sumController.text = "";
    redCategories = Model_Category.getRedCategories();
    greenCategories = Model_Category.getGreenCategories();
    Future.microtask(() {
      context.read<CurrencyProvider>().fetchCurrency();
    });
    _sumController.addListener(() {
      setState(() {});
    });
    _commentController.addListener(() {
      setState(() {});
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  void makeTransaction() {
    final double enteredAmount = double.tryParse(_sumController.text) ?? 0.0;
    final sumProvider = Provider.of<LocalSumProvider>(context, listen: false);
    final currencyProv = Provider.of<CurrencyProvider>(context, listen: false);
    
    if (_selectedCategory == '') {
      _showSnackBar('Выберите категорию!');
      return;
    }
    if (enteredAmount <= 0) {
      _showSnackBar('Введите корректную сумму');
      return;
    }
    
    if (_selectedType == 'outcome' && sumProvider.realTotalBalance < enteredAmount) {
      _showSnackBar('Недостаточно средств на балансе!');
      return;
    }

    double newBalance = sumProvider.realTotalBalance +
        (_selectedType == 'income' ? enteredAmount : -enteredAmount);
        
    double finalTodayUsd = currencyProv.convertToUsd(enteredAmount);

    final transactionForList = Model_Transaction(
      id: const Uuid().v4(),
      type: _selectedType,
      amount: enteredAmount,
      category: _selectedCategory,
      date: DateTime.now(),
      comment: _commentController.text,
      dollarSum: finalTodayUsd,
      balanceAtPoint: newBalance,
    );
    
    final transactionForHistory = transactionForList.copyWith();

    Hive.box<Model_Transaction>('transactions').add(transactionForList);
    Hive.box<Model_Transaction>('history').add(transactionForHistory);
    sumProvider.refresh();
    
    Navigator.pop(context);
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = 'income'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedType == 'income' ? Colors.green.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: _selectedType == 'income' 
                      ? Border.all(color: Colors.green.withValues(alpha: 0.5), width: 1.5)
                      : Border.all(color: Colors.transparent, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_downward, 
                         color: _selectedType == 'income' ? Colors.green[700] : Colors.grey[400], 
                         size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Доход',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _selectedType == 'income' ? Colors.green[700] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = 'outcome'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedType == 'outcome' ? Colors.red.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: _selectedType == 'outcome' 
                      ? Border.all(color: Colors.red.withValues(alpha: 0.5), width: 1.5)
                      : Border.all(color: Colors.transparent, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_upward, 
                         color: _selectedType == 'outcome' ? Colors.red[700] : Colors.grey[400], 
                         size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Расход',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _selectedType == 'outcome' ? Colors.red[700] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<Model_Category> categories, Color themeColor) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = categories[index];
          final isSelected = item.name == _selectedCategory;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = item.name;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 60 : 54,
                  height: isSelected ? 60 : 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? themeColor.withValues(alpha: 0.15) : Theme.of(context).cardColor,
                    boxShadow: [
                      if (!isSelected) 
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                    ],
                    border: Border.all(
                      color: isSelected ? themeColor : Colors.transparent,
                      width: isSelected ? 2.5 : 0,
                    ),
                  ),
                  child: Icon(
                    item.icon.icon,
                    color: isSelected ? themeColor : Colors.grey[600],
                    size: isSelected ? 28 : 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.name, 
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? themeColor : Colors.grey[600]
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  @override
  void dispose() {
    _sumController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyProv = context.watch<CurrencyProvider>();
    final sumProvider = context.watch<LocalSumProvider>();

    double kgs = double.tryParse(_sumController.text) ?? 0.0;
    double displayUsd = currencyProv.convertToUsd(kgs);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: currencyProv.isLoading
            ? const Text("Fetching currency...", style: TextStyle(fontSize: 14))
            : Text(
          "USD currency: ${currencyProv.dollarCourse.toStringAsFixed(2)} KGS",
          style: const TextStyle(fontSize: 14),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: myGradient),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.indigo[300], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Доступный баланс',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${sumProvider.realTotalBalance.toStringAsFixed(2)} KGS',
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Type Selector
            _buildTypeSelector(),
            
            const SizedBox(height: 32),
            
            // Amount Inputs
            Text(
              "Сумма транзакции",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 12),
            _buildInputCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('KGS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _sumController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // USD display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text('USD эквивалент:', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                  const Spacer(),
                  currencyProv.isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          "\$${displayUsd.toStringAsFixed(2)}",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Comment
            Text(
              "Описание (необязательно)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 12),
            _buildInputCard(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: _selectedType == 'income' ? 'Источник дохода' : 'На что потратили?',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),

            const SizedBox(height: 32),
            
            // Category
            Text(
              "Выберите категорию",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 16),
            _selectedType == 'income'
                ? _buildCategoryList(greenCategories, Colors.green)
                : _buildCategoryList(redCategories, Colors.red),

            const SizedBox(height: 48),

            // Save Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: myGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: makeTransaction,
                child: const Text(
                  "СОХРАНИТЬ",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
