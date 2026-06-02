import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../services/database_service.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

// [FIX #5] تحويل إلى StatefulWidget لمنع إنشاء stream subscription جديدة في كل rebuild
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // [FIX #5] يُنشأ مرة واحدة فقط
  final DatabaseService _dbService = DatabaseService();
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'سجل العمليات',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: _dbService.getCustomerHistory(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          }

          // [FIX #5] نسخة جديدة بدون mutation لـ snapshot.data المباشر
          final transactions = List<TransactionModel>.from(snapshot.data!)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          
          final double totalLitersMonth = transactions
              .where((tx) => tx.type == 'refill' && tx.timestamp.month == DateTime.now().month && tx.timestamp.year == DateTime.now().year)
              .fold(0, (sum, tx) => sum + tx.liters);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(context, totalLitersMonth),
                const SizedBox(height: 32),
                Text(
                  'العمليات السابقة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildHistoryItem(context, transactions[index]);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history, size: 64, color: AppTheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد عمليات سابقة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بإجراء تعبئة أو شحن رصيد لتظهر هنا',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, double liters) {
    // Goal of 100 liters for example
    double goal = 100.0;
    double progress = (liters / goal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.walletGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'استهلاكك هذا الشهر',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${liters.toInt()}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'لتر',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الهدف: ${goal.toInt()} لتر',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, TransactionModel tx) {
    bool isRefill = tx.type == 'refill';
    
    // Format date properly
    String formattedDate = DateFormat('dd MMM yyyy - hh:mm a', 'ar').format(tx.timestamp);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceContainerHighest, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isRefill ? AppTheme.primaryFixed : AppTheme.success.withValues(alpha: 0.15), // Light green for charge
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isRefill ? Icons.water_drop_rounded : Icons.account_balance_wallet_rounded,
              color: isRefill ? AppTheme.primary : AppTheme.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRefill ? 'تعبئة مياه' : 'شحن رصيد',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.outline,
                  ),
                ),
                if (isRefill) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.opacity, size: 12, color: AppTheme.info),
                      const SizedBox(width: 4),
                      Text(
                        '${tx.liters} لتر',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isRefill ? "-" : "+"}${tx.amount.toStringAsFixed(2)} د.أ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isRefill ? AppTheme.onSurface : AppTheme.success,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ناجحة',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
