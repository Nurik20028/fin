import 'package:flutter/material.dart';
import 'package:finance/models/model_category.dart';
import 'package:finance/models/model_transaction.dart';
import 'package:finance/components/item_transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finance/components/my_gradient.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late List<Model_Category> allCategories;
  
  // Filter states
  String _searchQuery = '';
  String? _selectedType; // 'income', 'outcome', or null for All
  DateTimeRange? _selectedDateRange;
  final Set<String> _selectedCategoryNames = {};
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allCategories = [
      ...Model_Category.getRedCategories(),
      ...Model_Category.getGreenCategories(),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _selectedType = null;
      _selectedDateRange = null;
      _selectedCategoryNames.clear();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Filters"),
        centerTitle: true,
        backgroundColor: Colors.grey,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: myGradient),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Сбросить фильтры',
            onPressed: _resetFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterControls(),
          const Divider(height: 1),
          Expanded(
            child: _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Search Query
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск по комментарию...',
              prefixIcon: const Icon(Icons.search, color: Colors.indigo),
              suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear), 
                      onPressed: () {
                        _searchController.clear();
                        setState(() { _searchQuery = ''; });
                      }
                    ) 
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 12),

          // 2. Date Range
          OutlinedButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.calendar_month, color: Colors.indigo),
            label: Text(
              _selectedDateRange == null 
                  ? 'Выбрать период (Все время)' 
                  : '${_selectedDateRange!.start.day.toString().padLeft(2, '0')}.${_selectedDateRange!.start.month.toString().padLeft(2, '0')}.${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day.toString().padLeft(2, '0')}.${_selectedDateRange!.end.month.toString().padLeft(2, '0')}.${_selectedDateRange!.end.year}',
              style: const TextStyle(color: Colors.black87),
            ),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),

          // 3. Type (Income / Expense)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Все'),
                  selected: _selectedType == null,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = null);
                  },
                  selectedColor: Colors.indigo.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Доходы'),
                  selected: _selectedType == 'income',
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = 'income');
                  },
                  selectedColor: Colors.green.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Расходы'),
                  selected: _selectedType == 'outcome',
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = 'outcome');
                  },
                  selectedColor: Colors.red.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 4. Categories
          Text('Категории:', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: allCategories.map((cat) {
                final isSelected = _selectedCategoryNames.contains(cat.name);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat.name),
                    avatar: Icon(cat.icon.icon, size: 18, color: cat.color),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategoryNames.add(cat.name);
                        } else {
                          _selectedCategoryNames.remove(cat.name);
                        }
                      });
                    },
                    selectedColor: cat.color.withValues(alpha: 0.2),
                    checkmarkColor: cat.color,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (!Hive.isBoxOpen('history')) {
      return const Center(child: Text("Загрузка данных..."));
    }

    return ValueListenableBuilder(
      valueListenable: Hive.box<Model_Transaction>('history').listenable(),
      builder: (context, Box<Model_Transaction> box, _) {
        final allTransactions = box.values.toList().reversed.toList();
        
        final filteredTransactions = allTransactions.where((tx) {
          // 1. Filter by Search Query (Comment)
          if (_searchQuery.isNotEmpty) {
            final comment = tx.comment.toLowerCase();
            if (!comment.contains(_searchQuery)) {
              return false;
            }
          }

          // 2. Filter by Date Range
          if (_selectedDateRange != null) {
            // Include boundaries properly (start of day to end of day)
            final start = _selectedDateRange!.start;
            final end = _selectedDateRange!.end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
            if (tx.date.isBefore(start) || tx.date.isAfter(end)) {
              return false;
            }
          }

          // 3. Filter by Type
          if (_selectedType != null) {
            if (tx.type != _selectedType) {
              return false;
            }
          }

          // 4. Filter by Category
          if (_selectedCategoryNames.isNotEmpty) {
            if (!_selectedCategoryNames.contains(tx.category)) {
              return false;
            }
          }

          return true;
        }).toList();

        if (filteredTransactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "По вашему запросу ничего не найдено",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: filteredTransactions.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ItemTransaction(transaction: filteredTransactions[index]),
                const Divider(indent: 20, endIndent: 20),
              ],
            );
          },
        );
      },
    );
  }
}
