
import 'package:flutter/material.dart';
import '../services/data_service.dart';

class DashboardSummary extends StatefulWidget {
  const DashboardSummary({super.key});

  @override
  State<DashboardSummary> createState() => _DashboardSummaryState();
}

class _DashboardSummaryState extends State<DashboardSummary> {
  final DataService _dataService = DataService();
  Map<String, double> _summary = {
    'totalIncome': 0,
    'totalExpense': 0,
    'balance': 0
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final summary = await _dataService.getTransactionSummary();
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading summary: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.count(
      crossAxisCount: 1,
      childAspectRatio: 3.5,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _SummaryCard(
          title: 'Revenus',
          amount: _summary['totalIncome']!,
          icon: Icons.arrow_upward,
          iconColor: Colors.green,
          borderColor: Colors.green,
          tooltipText: 'Total des revenus de toutes sources',
        ),
        _SummaryCard(
          title: 'Dépenses',
          amount: _summary['totalExpense']!,
          icon: Icons.arrow_downward,
          iconColor: Colors.red,
          borderColor: Colors.red,
          tooltipText: 'Total des dépenses de toutes catégories',
        ),
        _SummaryCard(
          title: 'Solde',
          amount: _summary['balance']!,
          borderColor: _summary['balance']! >= 0 ? Colors.blue : Colors.orange,
          highlightAmount: true,
          tooltipText: 'Votre solde actuel (Revenus - Dépenses)',
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData? icon;
  final Color? iconColor;
  final Color borderColor;
  final String? tooltipText;
  final bool highlightAmount;

  const _SummaryCard({
    required this.title,
    required this.amount,
    this.icon,
    this.iconColor,
    required this.borderColor,
    this.tooltipText,
    this.highlightAmount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (tooltipText != null) ...[
                      const SizedBox(width: 4),
                      Tooltip(
                        message: tooltipText!,
                        child: const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                if (icon != null)
                  Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${amount.toStringAsFixed(2)} €',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: highlightAmount
                    ? (amount >= 0 ? Colors.blue : Colors.orange)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
