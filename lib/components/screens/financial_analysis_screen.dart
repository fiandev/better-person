import 'package:material_ui/material_ui.dart';

import '../../controllers/transaction_controller.dart';
import '../../controllers/setting_controller.dart';
import '../../models/transaction.dart';
import '../../routes/route_shell.dart';

class FinancialAnalysisScreen extends StatefulWidget {
  const FinancialAnalysisScreen({super.key});

  @override
  State<FinancialAnalysisScreen> createState() =>
      _FinancialAnalysisScreenState();
}

class _FinancialAnalysisScreenState extends State<FinancialAnalysisScreen> {
  final _transactionController = TransactionController();

  DateTime _selectedMonth = DateTime.now();
  List<Transaction> _monthTransactions = [];
  double _totalExpenses = 0.0;
  Map<TransactionCategory, double> _categoryTotals = {};
  List<_WeeklyData> _weeklyData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
      23,
      59,
      59,
    );

    final transactions = _transactionController.getByDateRange(
      startOfMonth,
      endOfMonth,
    );
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    double totalExp = 0;
    final catTotals = <TransactionCategory, double>{};

    for (final t in expenses) {
      totalExp += t.amount;
      catTotals[t.category] = (catTotals[t.category] ?? 0) + t.amount;
    }

    final weeklyData = _calculateWeeklyData(expenses, startOfMonth, endOfMonth);

    setState(() {
      _monthTransactions = transactions;
      _totalExpenses = totalExp;
      _categoryTotals = catTotals;
      _weeklyData = weeklyData;
    });
  }

  List<_WeeklyData> _calculateWeeklyData(
    List<Transaction> expenses,
    DateTime startOfMonth,
    DateTime endOfMonth,
  ) {
    final weeks = <_WeeklyData>[];
    final now = DateTime.now();

    DateTime weekStart = startOfMonth;
    int weekNum = 1;

    while (weekStart.isBefore(endOfMonth)) {
      DateTime weekEnd = weekStart.add(const Duration(days: 6));
      if (weekEnd.isAfter(endOfMonth)) weekEnd = endOfMonth;

      final weekExpenses = expenses.where((t) {
        return !t.date.isBefore(weekStart) && !t.date.isAfter(weekEnd);
      }).toList();

      double total = 0;
      for (final t in weekExpenses) {
        total += t.amount;
      }

      final isCurrentWeek =
          now.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          now.isBefore(weekEnd.add(const Duration(days: 1)));

      weeks.add(
        _WeeklyData(
          label: 'Mg $weekNum',
          amount: total,
          isCurrentWeek: isCurrentWeek,
        ),
      );

      weekStart = weekEnd.add(const Duration(days: 1));
      weekNum++;
    }

    return weeks;
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _loadData();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    _loadData();
  }

  String _getMonthLabel() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}';
  }

  IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.foodAndDrink:
        return Icons.restaurant;
      case TransactionCategory.transport:
        return Icons.directions_car;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.utilities:
        return Icons.receipt_long;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.healthcare:
        return Icons.medical_services;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.groceries:
        return Icons.shopping_cart;
      default:
        return Icons.category;
    }
  }

  List<Color> _categoryPalette(ColorScheme colorScheme) => [
    colorScheme.primary,
    colorScheme.secondary,
    colorScheme.tertiary,
    colorScheme.primaryContainer,
    colorScheme.secondaryContainer,
    colorScheme.tertiaryContainer,
  ];

  Color _getCategoryColor(
    TransactionCategory category,
    int index,
    ColorScheme colorScheme,
  ) {
    final colors = _categoryPalette(colorScheme);
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final sortedCategories = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: colorScheme.onSurfaceVariant,
        ),
        title: Text(
          'Analisis Keuangan',
          style: textTheme.headlineMedium?.copyWith(
            fontFamily: 'Manrope',
            color: colorScheme.primary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeAndSummary(colorScheme, textTheme),
            const SizedBox(height: 32),
            _buildChartsSection(colorScheme, textTheme),
            const SizedBox(height: 32),
            _buildCategoryBreakdown(sortedCategories, colorScheme, textTheme),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 3),
    );
  }

  Widget _buildDateRangeAndSummary(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: _previousMonth,
              icon: const Icon(Icons.chevron_left),
            ),
            InkWell(
              onTap: () => _showMonthPicker(),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getMonthLabel(),
                      style: textTheme.labelLarge?.copyWith(
                        fontFamily: 'JetBrains Mono',
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.expand_more,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: _nextMonth,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${_monthTransactions.length} transactions this month',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Pengeluaran',
                style: textTheme.labelLarge?.copyWith(
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${SettingController().getCurrentSetting().defaultCurrencyFormat} ${_totalExpenses.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                style: textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) => _MonthPickerDialog(
        selectedMonth: _selectedMonth,
        onMonthSelected: (date) {
          setState(() => _selectedMonth = date);
          _loadData();
        },
      ),
    );
  }

  Widget _buildChartsSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: double.infinity,
          child: _buildPieChartCard(colorScheme, textTheme),
        ),
        SizedBox(
          width: double.infinity,
          child: _buildBarChartCard(colorScheme, textTheme),
        ),
      ],
    );
  }

  Widget _buildPieChartCard(ColorScheme colorScheme, TextTheme textTheme) {
    final sortedCategories = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategory = sortedCategories.isNotEmpty
        ? sortedCategories.first.key
        : null;
    final topLabel = topCategory != null
        ? Transaction(
            category: topCategory,
            id: '',
            walletId: '',
            amount: 0,
            type: TransactionType.expense,
            date: DateTime.now(),
            createdAt: DateTime.now(),
          ).getCategoryLabel()
        : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart, color: colorScheme.secondary, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Komposisi Pengeluaran',
                  style: textTheme.titleMedium?.copyWith(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _PieChartPainter(
                  categoryTotals: _categoryTotals,
                  totalExpenses: _totalExpenses,
                  palette: _categoryPalette(colorScheme),
                  trackColor: colorScheme.surfaceContainerHighest,
                  centerColor: colorScheme.surfaceContainerLowest,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Top',
                        style: textTheme.labelSmall?.copyWith(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 9,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        topLabel,
                        style: textTheme.labelSmall?.copyWith(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...sortedCategories.take(4).map((entry) {
            final percent = _totalExpenses > 0
                ? (entry.value / _totalExpenses * 100).round()
                : 0;
            final index = sortedCategories.indexOf(entry);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            entry.key,
                            index,
                            colorScheme,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Transaction(
                          category: entry.key,
                          id: '',
                          walletId: '',
                          amount: 0,
                          type: TransactionType.expense,
                          date: DateTime.now(),
                          createdAt: DateTime.now(),
                        ).getCategoryLabel(),
                        style: textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Work Sans',
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$percent%',
                    style: textTheme.labelLarge?.copyWith(
                      fontFamily: 'JetBrains Mono',
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBarChartCard(ColorScheme colorScheme, TextTheme textTheme) {
    final maxAmount = _weeklyData.isNotEmpty
        ? _weeklyData.map((w) => w.amount).reduce((a, b) => a > b ? a : b)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: colorScheme.secondary, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Tren Pengeluaran Mingguan',
                  style: textTheme.titleMedium?.copyWith(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: _weeklyData.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada data',
                      style: textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Work Sans',
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatCurrency(maxAmount),
                              style: textTheme.labelSmall?.copyWith(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _formatCurrency(maxAmount * 0.5),
                              style: textTheme.labelSmall?.copyWith(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '0',
                              style: textTheme.labelSmall?.copyWith(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  CustomPaint(
                                    size: Size.infinite,
                                    painter: _GridPainter(
                                      lineColor: colorScheme.outlineVariant
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  CustomPaint(
                                    size: Size.infinite,
                                    painter: _BarChartPainter(
                                      weeklyData: _weeklyData,
                                      maxAmount: maxAmount,
                                      activeColor: colorScheme.primary,
                                      inactiveColor: colorScheme.primary
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: _weeklyData.map((w) {
                                return Text(
                                  w.label,
                                  style: textTheme.labelSmall?.copyWith(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 10,
                                    fontWeight: w.isCurrentWeek
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: w.isCurrentWeek
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Widget _buildCategoryBreakdown(
    List<MapEntry<TransactionCategory, double>> sortedCategories,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: colorScheme.secondary, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Rincian per Kategori',
                  style: textTheme.titleMedium?.copyWith(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (sortedCategories.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Belum ada transaksi',
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Work Sans',
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...sortedCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final catEntry = entry.value;
              final percent = _totalExpenses > 0
                  ? (catEntry.value / _totalExpenses * 100).round()
                  : 0;
              final color = _getCategoryColor(
                catEntry.key,
                index,
                colorScheme,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(catEntry.key),
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  Transaction(
                                    category: catEntry.key,
                                    id: '',
                                    walletId: '',
                                    amount: 0,
                                    type: TransactionType.expense,
                                    date: DateTime.now(),
                                    createdAt: DateTime.now(),
                                  ).getCategoryLabel(),
                                  style: textTheme.labelLarge?.copyWith(
                                    fontFamily: 'Work Sans',
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${SettingController().getCurrentSetting().defaultCurrencyFormat} ${catEntry.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                style: textTheme.labelLarge?.copyWith(
                                  fontFamily: 'JetBrains Mono',
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percent / 100,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _WeeklyData {
  final String label;
  final double amount;
  final bool isCurrentWeek;

  _WeeklyData({
    required this.label,
    required this.amount,
    required this.isCurrentWeek,
  });
}

class _PieChartPainter extends CustomPainter {
  final Map<TransactionCategory, double> categoryTotals;
  final double totalExpenses;
  final List<Color> palette;
  final Color trackColor;
  final Color centerColor;

  _PieChartPainter({
    required this.categoryTotals,
    required this.totalExpenses,
    required this.palette,
    required this.trackColor,
    required this.centerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.6;

    if (totalExpenses == 0 || categoryTotals.isEmpty) {
      final paint = Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 32;
      canvas.drawCircle(center, radius - 16, paint);
      return;
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    double startAngle = -3.14159 / 2;
    int colorIndex = 0;

    for (final entry in sortedEntries) {
      final sweepAngle = (entry.value / totalExpenses) * 2 * 3.14159;
      final paint = Paint()
        ..color = palette[colorIndex % palette.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 32
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 16),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
      colorIndex++;
    }

    // Inner circle (donut hole)
    final innerPaint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.categoryTotals != categoryTotals ||
      oldDelegate.totalExpenses != totalExpenses ||
      oldDelegate.palette != palette ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.centerColor != centerColor;
}

class _GridPainter extends CustomPainter {
  final Color lineColor;

  _GridPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}

class _BarChartPainter extends CustomPainter {
  final List<_WeeklyData> weeklyData;
  final double maxAmount;
  final Color activeColor;
  final Color inactiveColor;

  _BarChartPainter({
    required this.weeklyData,
    required this.maxAmount,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weeklyData.isEmpty || maxAmount == 0) return;

    final barCount = weeklyData.length;
    final totalSpacing = (barCount - 1) * 8.0;
    final barWidth = (size.width - totalSpacing) / barCount;
    final maxHeight = size.height;

    for (int i = 0; i < barCount; i++) {
      final data = weeklyData[i];
      final barHeight = maxAmount > 0
          ? (data.amount / maxAmount) * maxHeight
          : 0.0;

      final x = i * (barWidth + 8);
      final y = maxHeight - barHeight;

      final paint = Paint()
        ..color = data.isCurrentWeek ? activeColor : inactiveColor
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.weeklyData != weeklyData ||
      oldDelegate.maxAmount != maxAmount ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.inactiveColor != inactiveColor;
}

class _MonthPickerDialog extends StatefulWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthSelected;

  const _MonthPickerDialog({
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late DateTime _currentYear;

  @override
  void initState() {
    super.initState();
    _currentYear = DateTime(widget.selectedMonth.year);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return Dialog(
      backgroundColor: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => setState(
                    () => _currentYear = DateTime(_currentYear.year - 1),
                  ),
                ),
                Text(
                  '${_currentYear.year}',
                  style: textTheme.titleLarge?.copyWith(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => setState(
                    () => _currentYear = DateTime(_currentYear.year + 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected =
                    widget.selectedMonth.year == _currentYear.year &&
                    widget.selectedMonth.month == month;
                final isFuture =
                    _currentYear.year > DateTime.now().year ||
                    (_currentYear.year == DateTime.now().year &&
                        month > DateTime.now().month);

                return InkWell(
                  onTap: isFuture
                      ? null
                      : () {
                          widget.onMonthSelected(
                            DateTime(_currentYear.year, month),
                          );
                          Navigator.pop(context);
                        },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : isFuture
                          ? colorScheme.surfaceContainer
                          : colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      months[index],
                      style: textTheme.labelLarge?.copyWith(
                        fontFamily: 'Work Sans',
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isFuture
                            ? colorScheme.outline
                            : isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
