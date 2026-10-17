import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../controllers/transaction_controller.dart';
import '../../../models/transaction.dart';

/// Financial Journal card: a spending-mix donut built from this month's
/// expense categories plus the highest/lowest spending weeks of the month.
class FinancialJournalCard extends StatefulWidget {
  const FinancialJournalCard({super.key, required this.onViewAnalysis});

  final VoidCallback onViewAnalysis;

  @override
  State<FinancialJournalCard> createState() => _FinancialJournalCardState();
}

class _FinancialJournalCardState extends State<FinancialJournalCard> {
  static const _palette = [
    Color(0xFF2d6a4f),
    Color(0xFF3e6750),
    Color(0xFF95d4b3),
  ];

  final _transactions = TransactionController();

  @override
  void initState() {
    super.initState();
    _transactions.addListener(_reload);
  }

  @override
  void dispose() {
    _transactions.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final data = _buildData();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFf8f9fa), // surface-bright
        border: Border.all(color: const Color(0xFFbfc9c1)), // outline-variant
        borderRadius: BorderRadius.circular(12), // rounded-xl
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1b4332),
            blurRadius: 24,
            offset: Offset(0, 12),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _JournalHeader(),
          const SizedBox(height: 16),
          if (!data.hasData)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No spending recorded this month yet.',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 12,
                  color: Color(0xFF404943), // on-surface-variant
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _SpendingMix(slices: data.slices, total: data.total),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ExtremesSection(
                    high: data.high,
                    low: data.low,
                    total: data.total,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          _ViewAnalysisLink(onTap: widget.onViewAnalysis),
        ],
      ),
    );
  }

  _JournalData _buildData() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final expenses = _transactions
        .getAll()
        .where(
          (transaction) =>
              transaction.type == TransactionType.expense &&
              !transaction.date.isBefore(monthStart) &&
              transaction.date.isBefore(nextMonth),
        )
        .toList();
    if (expenses.isEmpty) return const _JournalData.empty();

    final total = expenses.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );
    if (total <= 0) return const _JournalData.empty();

    final categoryTotals = <TransactionCategory, double>{};
    for (final transaction in expenses) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final slices = [
      for (
        var index = 0;
        index < sorted.length && index < _palette.length;
        index++
      )
        _CategorySlice(amount: sorted[index].value, color: _palette[index]),
    ];

    final weeks = _weeklyTotals(expenses, monthStart, now);
    final high = weeks.reduce(math.max);
    final low = weeks.reduce(math.min);

    return _JournalData(slices: slices, total: total, high: high, low: low);
  }

  List<double> _weeklyTotals(
    List<Transaction> expenses,
    DateTime monthStart,
    DateTime now,
  ) {
    final weeks = <double>[];
    final lastMoment = DateTime(now.year, now.month, now.day, 23, 59, 59);
    var weekStart = monthStart;
    while (!weekStart.isAfter(lastMoment)) {
      final weekEnd = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + 6,
        23,
        59,
        59,
      );
      final amount = expenses
          .where(
            (transaction) =>
                !transaction.date.isBefore(weekStart) &&
                !transaction.date.isAfter(weekEnd),
          )
          .fold<double>(0, (sum, transaction) => sum + transaction.amount);
      weeks.add(amount);
      weekStart = DateTime(weekStart.year, weekStart.month, weekStart.day + 7);
    }
    return weeks;
  }
}

class _JournalHeader extends StatelessWidget {
  const _JournalHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Journal',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0f5238), // primary
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Weekly vs Monthly Insights',
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 12,
                color: Color(0xFF404943), // on-surface-variant
              ),
            ),
          ],
        ),
        Icon(Icons.insights, color: Color(0xFF0f5238), size: 24),
      ],
    );
  }
}

class _SpendingMix extends StatelessWidget {
  const _SpendingMix({required this.slices, required this.total});

  final List<_CategorySlice> slices;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: CustomPaint(
            painter: _DonutPainter(slices: slices, total: total),
            child: const Center(
              child: Icon(
                Icons.pie_chart_outline,
                size: 22,
                color: Color(0xFF404943), // on-surface-variant
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Spending Mix',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            color: Color(0xFF404943), // on-surface-variant
          ),
        ),
      ],
    );
  }
}

class _ExtremesSection extends StatelessWidget {
  const _ExtremesSection({
    required this.high,
    required this.low,
    required this.total,
  });

  final double high;
  final double low;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXTREMES',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            color: Color(0xFF404943), // on-surface-variant
          ),
        ),
        const SizedBox(height: 8),
        _ExtremeBar(
          label: 'High',
          progress: _share(high),
          color: const Color(0xFF0f5238), // primary
        ),
        const SizedBox(height: 8),
        _ExtremeBar(
          label: 'Low',
          progress: _share(low),
          color: const Color(0xFF3e6750), // secondary
        ),
      ],
    );
  }

  double _share(double value) =>
      total <= 0 ? 0 : (value / total).clamp(0.0, 1.0);
}

class _ExtremeBar extends StatelessWidget {
  const _ExtremeBar({
    required this.label,
    required this.progress,
    required this.color,
  });

  final String label;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFedeeef), // surface-container
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ${(progress * 100).round()}%',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ViewAnalysisLink extends StatelessWidget {
  const _ViewAnalysisLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFbfc9c1))),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'View Detailed Analysis',
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0f5238),
              ),
            ),
            Icon(Icons.arrow_forward, size: 16, color: Color(0xFF0f5238)),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.slices, required this.total});

  final List<_CategorySlice> slices;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.butt;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (slices.isEmpty || total <= 0) {
      paint.color = const Color(0xFFedeeef); // surface-container
      canvas.drawCircle(center, radius, paint);
      return;
    }

    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      final sweepAngle = slice.amount / total * 2 * math.pi;
      paint.color = slice.color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.slices != slices || oldDelegate.total != total;
}

class _CategorySlice {
  const _CategorySlice({required this.amount, required this.color});

  final double amount;
  final Color color;
}

class _JournalData {
  const _JournalData({
    required this.slices,
    required this.total,
    required this.high,
    required this.low,
  });

  const _JournalData.empty() : slices = const [], total = 0, high = 0, low = 0;

  final List<_CategorySlice> slices;
  final double total;
  final double high;
  final double low;

  bool get hasData => total > 0 && slices.isNotEmpty;
}
