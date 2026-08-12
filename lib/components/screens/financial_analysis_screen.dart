import 'package:flutter/material.dart';

import '../../controllers/transaction_controller.dart';
import '../../models/transaction.dart';
import '../../routes/route_shell.dart';

class FinancialAnalysisScreen extends StatefulWidget {
  const FinancialAnalysisScreen({super.key});

  @override
  State<FinancialAnalysisScreen> createState() => _FinancialAnalysisScreenState();
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
    final endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);
    
    final transactions = _transactionController.getByDateRange(startOfMonth, endOfMonth);
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    
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
      
      final isCurrentWeek = now.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          now.isBefore(weekEnd.add(const Duration(days: 1)));
      
      weeks.add(_WeeklyData(
        label: 'Mg $weekNum',
        amount: total,
        isCurrentWeek: isCurrentWeek,
      ));
      
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
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
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

  Color _getCategoryColor(TransactionCategory category, int index) {
    const colors = [
      Color(0xFF2d6a4f), // primary-container
      Color(0xFF3e6750), // secondary
      Color(0xFF95d4b3), // inverse-primary
      Color(0xFFbdeacd), // secondary-container
      Color(0xFF3f6754), // tertiary-container
      Color(0xFF0f5238), // primary
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final sortedCategories = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf8f9fa),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: const Color(0xFF404943),
        ),
        title: const Text(
          'Analisis Keuangan',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0f5238),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeAndSummary(),
            const SizedBox(height: 32),
            _buildChartsSection(),
            const SizedBox(height: 32),
            _buildCategoryBreakdown(sortedCategories),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: RouteShell.bottomNav(context, currentIndex: 3),
    );
  }

  Widget _buildDateRangeAndSummary() {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => _showMonthPicker(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFffffff),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A1b4332),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFbfc9c1).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Color(0xFF0f5238),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getMonthLabel(),
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF191c1d),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.expand_more,
                      color: Color(0xFF707973),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2d6a4f),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A1b4332),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Pengeluaran',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 14,
                  color: Color(0xFFa8e7c5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp ${_totalExpenses.toStringAsFixed(0).replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (m) => '${m[1]}.',
                )}',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Colors.white,
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

  Widget _buildChartsSection() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: 300,
          child: _buildPieChartCard(),
        ),
        SizedBox(
          width: 300,
          child: _buildBarChartCard(),
        ),
      ],
    );
  }

  Widget _buildPieChartCard() {
    final sortedCategories = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topCategory = sortedCategories.isNotEmpty ? sortedCategories.first.key : null;
    final topLabel = topCategory != null ? Transaction(category: topCategory, id: '', walletId: '', amount: 0, type: TransactionType.expense, date: DateTime.now(), createdAt: DateTime.now()).getCategoryLabel() : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFffffff),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1b4332),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFbfc9c1).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart, color: Color(0xFF3e6750), size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Komposisi Pengeluaran',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191c1d),
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
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Top',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          color: Color(0xFF707973),
                        ),
                      ),
                      Text(
                        topLabel,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0f5238),
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
            final percent = _totalExpenses > 0 ? (entry.value / _totalExpenses * 100).round() : 0;
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
                          color: _getCategoryColor(entry.key, index),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Transaction(category: entry.key, id: '', walletId: '', amount: 0, type: TransactionType.expense, date: DateTime.now(), createdAt: DateTime.now()).getCategoryLabel(),
                        style: const TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 14,
                          color: Color(0xFF191c1d),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF191c1d),
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

  Widget _buildBarChartCard() {
    final maxAmount = _weeklyData.isNotEmpty
        ? _weeklyData.map((w) => w.amount).reduce((a, b) => a > b ? a : b)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFffffff),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1b4332),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFbfc9c1).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Color(0xFF3e6750), size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Tren Pengeluaran Mingguan',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191c1d),
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
                ? const Center(
                    child: Text(
                      'Belum ada data',
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 14,
                        color: Color(0xFF707973),
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
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                color: Color(0xFF707973),
                              ),
                            ),
                            Text(
                              _formatCurrency(maxAmount * 0.5),
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                color: Color(0xFF707973),
                              ),
                            ),
                            const Text(
                              '0',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                color: Color(0xFF707973),
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
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: _GridPainter(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: _weeklyData.map((w) {
                                return Text(
                                  w.label,
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 10,
                                    fontWeight: w.isCurrentWeek ? FontWeight.bold : FontWeight.normal,
                                    color: w.isCurrentWeek
                                        ? const Color(0xFF0f5238)
                                        : const Color(0xFF404943),
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

  Widget _buildCategoryBreakdown(List<MapEntry<TransactionCategory, double>> sortedCategories) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFffffff),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1b4332),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFbfc9c1).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt, color: Color(0xFF3e6750), size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Rincian per Kategori',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191c1d),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (sortedCategories.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Belum ada transaksi',
                  style: TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 14,
                    color: Color(0xFF707973),
                  ),
                ),
              ),
            )
          else
            ...sortedCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final catEntry = entry.value;
              final percent = _totalExpenses > 0 ? (catEntry.value / _totalExpenses * 100).round() : 0;
              final color = _getCategoryColor(catEntry.key, index);
              
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
                                  Transaction(category: catEntry.key, id: '', walletId: '', amount: 0, type: TransactionType.expense, date: DateTime.now(), createdAt: DateTime.now()).getCategoryLabel(),
                                  style: const TextStyle(
                                    fontFamily: 'Work Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF191c1d),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rp ${catEntry.value.toStringAsFixed(0).replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (m) => '${m[1]}.',
                                )}',
                                style: const TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF191c1d),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percent / 100,
                              backgroundColor: const Color(0xFFe1e3e4),
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

  _PieChartPainter({
    required this.categoryTotals,
    required this.totalExpenses,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.6;

    if (totalExpenses == 0 || categoryTotals.isEmpty) {
      final paint = Paint()
        ..color = const Color(0xFFe1e3e4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 32;
      canvas.drawCircle(center, radius - 16, paint);
      return;
    }

    const colors = [
      Color(0xFF2d6a4f),
      Color(0xFF3e6750),
      Color(0xFF95d4b3),
      Color(0xFFbdeacd),
      Color(0xFF3f6754),
      Color(0xFF0f5238),
    ];

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    double startAngle = -3.14159 / 2;
    int colorIndex = 0;

    for (final entry in sortedEntries) {
      final sweepAngle = (entry.value / totalExpenses) * 2 * 3.14159;
      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
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
      ..color = const Color(0xFFffffff)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFbfc9c1).withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];

    return Dialog(
      backgroundColor: const Color(0xFFffffff),
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
                  icon: const Icon(Icons.chevron_left, color: Color(0xFF404943)),
                  onPressed: () => setState(() => _currentYear = DateTime(_currentYear.year - 1)),
                ),
                Text(
                  '${_currentYear.year}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191c1d),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Color(0xFF404943)),
                  onPressed: () => setState(() => _currentYear = DateTime(_currentYear.year + 1)),
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
                final isSelected = widget.selectedMonth.year == _currentYear.year &&
                    widget.selectedMonth.month == month;
                final isFuture = _currentYear.year > DateTime.now().year ||
                    (_currentYear.year == DateTime.now().year && month > DateTime.now().month);

                return GestureDetector(
                  onTap: isFuture
                      ? null
                      : () {
                          widget.onMonthSelected(DateTime(_currentYear.year, month));
                          Navigator.pop(context);
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0f5238)
                          : isFuture
                              ? const Color(0xFFf8f9fa)
                              : const Color(0xFFffffff),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0f5238)
                            : const Color(0xFFbfc9c1),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      months[index],
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isFuture
                            ? const Color(0xFFbfc9c1)
                            : isSelected
                                ? Colors.white
                                : const Color(0xFF191c1d),
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
