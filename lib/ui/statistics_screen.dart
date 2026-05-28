import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:finance/components/my_gradient.dart';
import 'package:finance/models/model_transaction.dart';
import 'package:finance/river_states/local_sum_provider.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<LocalSumProvider>();
    final box = Hive.box<Model_Transaction>('history');
    final transactions = box.values.toList();
    List<FlSpot> incomeSpots = [];
    List<FlSpot> outflowSpots = [];
    List<FlSpot> balanceSpots = [];
    double runningBalance = 0;
    DateTime thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    for (var tx in transactions) {
      if (tx.date.isBefore(thirtyDaysAgo)) {
        runningBalance += tx.type == 'income' ? tx.amount : -tx.amount;
      }
    }
    for (int i = 30; i >= 0; i--) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      double dayIncome = 0;
      double dayOutflow = 0;
      for (var tx in transactions) {
        if (tx.date.day == date.day &&
            tx.date.year == date.year &&
            tx.date.month == date.month) {
          if (tx.type == 'income') {
            dayIncome += tx.amount;
          } else if (tx.type == 'outcome') {
            dayOutflow += tx.amount;
          }
        }
      }
      runningBalance += (dayIncome - dayOutflow);
      double x = (30 - i).toDouble();
      incomeSpots.add(FlSpot(x, dayIncome));
      outflowSpots.add(FlSpot(x, dayOutflow));
      balanceSpots.add(FlSpot(x, runningBalance));
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Statistics"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: myGradient),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Доходы и расходы (30 дней)",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 40),
                child: SizedBox(
                  height: 300,
                  child: LineChart(
                    _baseChartData([
                      _lineData(incomeSpots, Colors.green),
                      _lineData(outflowSpots, Colors.red),
                    ], context),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildLegend([
                legendItem("Доходы", Colors.green, context),
                legendItem("Расходы", Colors.red, context),
              ]),
              const SizedBox(height: 20),
              Text(
                "Баланс (30 дней)",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  height: 300,
                  child: LineChart(
                    _baseChartData([
                      _lineData(balanceSpots, Colors.greenAccent, isBald: true),
                    ], context),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildLegend([legendItem("Общий баланс", Colors.greenAccent, context)]),
            ],
          ),
        ),
      ),
    );
  }

  LineChartData _baseChartData(List<LineChartBarData> lines, BuildContext context) {
    return LineChartData(
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: true,
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            interval: _calculateIntercal(lines),
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  _formatYAxis(value),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: lines,
    );
  }

  double _calculateIntercal(List<LineChartBarData> lines) {
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    for (var line in lines) {
      for (var spot in line.spots) {
        if (spot.y < minY) minY = spot.y;
        if (spot.y > maxY) maxY = spot.y;
      }
    }
    if (minY == double.infinity || maxY == double.negativeInfinity) return 10.0;
    double range = maxY - minY;
    if (range <= 0) return 10.0;
    return range / 5;
  }

  String _formatYAxis(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  LineChartBarData _lineData(
      List<FlSpot> spots,
      Color color, {
        bool isBald = false,
      }) {
    return LineChartBarData(
      spots: spots,
      isCurved: !isBald,
      color: color,
      barWidth: isBald ? 4 : 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildLegend(List<Widget> items) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: items);
  }

  Widget legendItem(String title, Color color, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}

