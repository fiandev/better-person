import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final data = _buildData(colorScheme);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No spending recorded this month yet.',
                style: textTheme.labelSmall?.copyWith(
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant,
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

  _JournalData _buildData(ColorScheme colorScheme) {
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

    final palette = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
    ];

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
        index < sorted.length && index < palette.length;
        index++
      )
        _CategorySlice(amount: sorted[index].value, color: palette[index]),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Journal',
              style: textTheme.headlineMedium?.copyWith(
                fontFamily: 'Manrope',
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Weekly vs Monthly Insights',
              style: textTheme.labelSmall?.copyWith(
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Icon(Icons.insights, color: colorScheme.primary, size: 24),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Column(
      children: [
        SizedBox(
          width: 88,
          height: 88,
          child: CustomPaint(
            painter: _DonutPainter(
              slices: slices,
              total: total,
              trackColor: colorScheme.surfaceContainer,
            ),
            child: Center(
              child: Icon(
                Icons.pie_chart_outline,
                size: 22,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Spending Mix',
          style: textTheme.labelSmall?.copyWith(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            letterSpacing: 1.2,
            color: colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXTREMES',
          style: textTheme.labelSmall?.copyWith(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            letterSpacing: 1.2,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        _ExtremeBar(
          label: 'High',
          progress: _share(high),
          color: colorScheme.primary,
        ),
        const SizedBox(height: 8),
        _ExtremeBar(
          label: 'Low',
          progress: _share(low),
          color: colorScheme.secondary,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
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
          style: textTheme.labelSmall?.copyWith(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'View Detailed Analysis',
              style: textTheme.labelSmall?.copyWith(
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            Icon(Icons.arrow_forward, size: 16, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.slices,
    required this.total,
    required this.trackColor,
  });

  final List<_CategorySlice> slices;
  final double total;
  final Color trackColor;

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
      paint.color = trackColor;
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
      oldDelegate.slices != slices ||
      oldDelegate.total != total ||
      oldDelegate.trackColor != trackColor;
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
