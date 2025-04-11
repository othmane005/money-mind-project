
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../services/data_service.dart';

class Charts extends StatefulWidget {
  const Charts({super.key});

  @override
  State<Charts> createState() => _ChartsState();
}

class _ChartsState extends State<Charts> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DataService _dataService = DataService();
  bool _isLoading = true;
  
  List<Map<String, dynamic>> _expenseSummary = [];
  List<Map<String, dynamic>> _incomeSummary = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    try {
      final expenseSummary = await _dataService.getCategorySummary(TransactionType.expense);
      final incomeSummary = await _dataService.getCategorySummary(TransactionType.income);
      
      setState(() {
        _expenseSummary = expenseSummary;
        _incomeSummary = incomeSummary;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading chart data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aperçu financier',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Dépenses'),
                Tab(text: 'Revenus'),
                Tab(text: 'Comparaison'),
              ],
              labelColor: Theme.of(context).primaryColor,
            ),
            
            SizedBox(
              height: 300,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildExpensePieChart(),
                        _buildIncomePieChart(),
                        _buildCategoryBarChart(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExpensePieChart() {
    if (_expenseSummary.isEmpty) {
      return const Center(
        child: Text(
          'Pas de données de dépenses à afficher',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChart(
        PieChartData(
          sections: _expenseSummary.map((data) {
            final category = data['category'];
            final total = data['total'] as double;
            final totalExpense = _expenseSummary.fold(
                0.0, (sum, item) => sum + (item['total'] as double));
            final percentage = total / totalExpense;
            
            return PieChartSectionData(
              color: category.color,
              value: total,
              title: '${(percentage * 100).toStringAsFixed(0)}%',
              radius: 100,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 0,
        ),
      ),
    );
  }
  
  Widget _buildIncomePieChart() {
    if (_incomeSummary.isEmpty) {
      return const Center(
        child: Text(
          'Pas de données de revenus à afficher',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChart(
        PieChartData(
          sections: _incomeSummary.map((data) {
            final category = data['category'];
            final total = data['total'] as double;
            final totalIncome = _incomeSummary.fold(
                0.0, (sum, item) => sum + (item['total'] as double));
            final percentage = total / totalIncome;
            
            return PieChartSectionData(
              color: category.color,
              value: total,
              title: '${(percentage * 100).toStringAsFixed(0)}%',
              radius: 100,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 0,
        ),
      ),
    );
  }
  
  Widget _buildCategoryBarChart() {
    if (_expenseSummary.isEmpty && _incomeSummary.isEmpty) {
      return const Center(
        child: Text(
          'Pas de données à afficher',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    // Combine all category names
    final Set<String> allCategoryNames = {};
    
    for (var item in _expenseSummary) {
      allCategoryNames.add(item['category'].name);
    }
    
    for (var item in _incomeSummary) {
      allCategoryNames.add(item['category'].name);
    }
    
    final List<String> categoryNames = allCategoryNames.toList();
    
    // Calculate max y value for scaling
    double maxValue = 0;
    for (var name in categoryNames) {
      double expenseVal = 0;
      double incomeVal = 0;
      
      final expenseItem = _expenseSummary.firstWhere(
        (item) => item['category'].name == name,
        orElse: () => {'total': 0.0},
      );
      
      final incomeItem = _incomeSummary.firstWhere(
        (item) => item['category'].name == name,
        orElse: () => {'total': 0.0},
      );
      
      expenseVal = expenseItem['total'] is double ? expenseItem['total'] : 0.0;
      incomeVal = incomeItem['total'] is double ? incomeItem['total'] : 0.0;
      
      maxValue = [maxValue, expenseVal, incomeVal].reduce((curr, next) => curr > next ? curr : next);
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue * 1.2, // Add 20% padding at the top
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= categoryNames.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      categoryNames[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()} €',
                    style: const TextStyle(fontSize: 10),
                  );
                },
                reservedSize: 40,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups: List.generate(categoryNames.length, (index) {
            final name = categoryNames[index];
            
            double expenseVal = 0;
            double incomeVal = 0;
            
            final expenseItem = _expenseSummary.firstWhere(
              (item) => item['category'].name == name,
              orElse: () => {'total': 0.0},
            );
            
            final incomeItem = _incomeSummary.firstWhere(
              (item) => item['category'].name == name,
              orElse: () => {'total': 0.0},
            );
            
            expenseVal = expenseItem['total'] is double ? expenseItem['total'] : 0.0;
            incomeVal = incomeItem['total'] is double ? incomeItem['total'] : 0.0;
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: incomeVal,
                  color: Colors.green,
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: expenseVal,
                  color: Colors.red,
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.white,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = rodIndex == 0 ? 'Revenu' : 'Dépense';
                return BarTooltipItem(
                  '$label: ${rod.toY.toStringAsFixed(2)} €',
                  const TextStyle(color: Colors.black),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
