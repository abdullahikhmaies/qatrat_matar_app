import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../services/database_service.dart';
import '../models/transaction_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('سجل العمليات', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: dbService.getCustomerHistory(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد عمليات سابقة'));
          }

          var transactions = snapshot.data!;
          double totalLitersMonth = transactions
              .where((tx) => tx.type == 'refill' && tx.timestamp.month == DateTime.now().month)
              .fold(0, (sum, tx) => sum + tx.liters);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildSummaryCard(totalLitersMonth),
                const SizedBox(height: 32),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('العمليات السابقة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryItem(transactions[index]);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(double liters) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('استهلاكك هذا الشهر', style: TextStyle(color: Colors.grey, fontSize: 12)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${liters.toInt()}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const SizedBox(width: 4),
              const Text('لتر', style: TextStyle(color: AppTheme.secondary)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (liters / 100).clamp(0, 1), // افتراض هدف 100 لتر
              minHeight: 8,
              backgroundColor: const Color(0xFFF0F3FF),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(TransactionModel tx) {
    bool isRefill = tx.type == 'refill';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isRefill ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(isRefill ? Icons.water_drop : Icons.add_card, color: isRefill ? AppTheme.primary : Colors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isRefill ? 'تعبئة ${tx.liters} لتر' : 'شحن رصيد', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(tx.timestamp.toString().substring(0, 16), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${isRefill ? "-" : "+"}${tx.amount.toStringAsFixed(3)} د.أ', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: isRefill ? AppTheme.primary : Colors.green)),
              const Text('ناجحة', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
