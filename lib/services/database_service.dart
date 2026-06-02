import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Operations ---
  
  Future<UserModel?> getUserById(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // دالة توحيد أرقام الهواتف (مركزية لضمان الأمان وعدم التكرار)
  static String normalizePhone(String phone) {
    String normalized = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.startsWith('962')) {
      normalized = normalized.substring(3);
    }
    if (normalized.startsWith('0')) {
      normalized = normalized.substring(1);
    }
    return normalized; // تعيد الرقم بدون 0 أو +962 (مثلاً 79xxxxxxxx)
  }

  // البحث عن عميل برقم الهاتف
  Future<UserModel?> getUserByPhone(String phone) async {
    String normalized = normalizePhone(phone);
    
    QuerySnapshot query = await _db.collection('users')
        .where('phone', isEqualTo: normalized)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      return UserModel.fromMap(query.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  // --- Financial Operations ---

  // إضافة عملية تعبئة جديدة (Refill)
  Future<void> addTransaction(TransactionModel transaction) async {
    DocumentReference customerRef = _db.collection('users').doc(transaction.customerId);
    
    await _db.runTransaction((tx) async {
      DocumentSnapshot snapshot = await tx.get(customerRef);
      if (!snapshot.exists) throw "العميل غير موجود";

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      double currentBalance = (data['balance'] ?? 0.0).toDouble();
      
      if (currentBalance < transaction.amount) {
        throw "عذراً، الرصيد غير كافٍ لإتمام هذه العملية";
      }

      int currentPoints = data['points'] ?? 0;
      
      tx.set(_db.collection('transactions').doc(transaction.id), transaction.toMap());
      
      tx.update(customerRef, {
        'balance': currentBalance - transaction.amount,
        'points': currentPoints + (transaction.liters * 1).toInt(),
      });

      // تحديث المخزون
      DocumentReference tankRef = _db.collection('inventory').doc('main_tank');
      DocumentSnapshot tankSnap = await tx.get(tankRef);
      double tankCurrent = tankSnap.exists ? (tankSnap.get('current_liters') ?? 5000.0).toDouble() : 5000.0;
      tx.set(tankRef, {'current_liters': tankCurrent - transaction.liters}, SetOptions(merge: true));
    });
  }

  // جلب حالة المخزون
  Stream<DocumentSnapshot> getInventoryStatus() {
    return _db.collection('inventory').doc('main_tank').snapshots();
  }

  // إعادة تعبئة المخزون (للمسؤول)
  Future<void> refillInventory(double liters) async {
    DocumentReference tankRef = _db.collection('inventory').doc('main_tank');
    await _db.runTransaction((tx) async {
      DocumentSnapshot snap = await tx.get(tankRef);
      double current = snap.exists ? (snap.get('current_liters') ?? 0.0).toDouble() : 0.0;
      tx.set(tankRef, {'current_liters': current + liters}, SetOptions(merge: true));
    });
  }

  // --- Task System ---

  Future<void> createTask(String title, String desc) async {
    await _db.collection('tasks').add({
      'title': title,
      'description': desc,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getTasks() {
    return _db.collection('tasks').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    await _db.collection('tasks').doc(taskId).update({'status': status});
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  // استبدال النقاط بتعبئة مجانية
  Future<void> redeemPoints(String customerId, double liters, int pointsToDeduct, String staffId) async {
    DocumentReference customerRef = _db.collection('users').doc(customerId);
    
    String tid = "REDEEM_${DateTime.now().millisecondsSinceEpoch}";
    TransactionModel redeemTx = TransactionModel(
      id: tid,
      customerId: customerId,
      staffId: staffId,
      amount: 0, // مجانية
      liters: liters,
      timestamp: DateTime.now(),
      type: 'refill',
      status: 'redeemed_points'
    );

    await _db.runTransaction((tx) async {
      DocumentSnapshot snapshot = await tx.get(customerRef);
      if (!snapshot.exists) throw "العميل غير موجود";

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      int currentPoints = data['points'] ?? 0;
      if (currentPoints < pointsToDeduct) {
        throw "نقاط العميل غير كافية للمكافأة";
      }
      
      tx.set(_db.collection('transactions').doc(tid), redeemTx.toMap());
      tx.update(customerRef, {
        'points': currentPoints - pointsToDeduct,
      });

      // تحديث المخزون حتى في التعبئة المجانية لضمان دقة الجرد
      DocumentReference tankRef = _db.collection('inventory').doc('main_tank');
      DocumentSnapshot tankSnap = await tx.get(tankRef);
      double tankCurrent = tankSnap.exists ? (tankSnap.get('current_liters') ?? 5000.0).toDouble() : 5000.0;
      tx.set(tankRef, {'current_liters': tankCurrent - liters}, SetOptions(merge: true));
    });
  }

  // شحن رصيد لعميل (Top-up)
  Future<void> topUpBalance(String customerId, double amount, String staffId) async {
    DocumentReference customerRef = _db.collection('users').doc(customerId);
    
    String tid = "TOP_${DateTime.now().millisecondsSinceEpoch}";
    TransactionModel topUpTx = TransactionModel(
      id: tid,
      customerId: customerId,
      staffId: staffId,
      amount: amount,
      liters: 0,
      timestamp: DateTime.now(),
      type: 'topup'
    );

    await _db.runTransaction((tx) async {
      DocumentSnapshot snapshot = await tx.get(customerRef);
      if (!snapshot.exists) throw "العميل غير موجود";

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      double currentBalance = (data['balance'] ?? 0.0).toDouble();
      
      tx.set(_db.collection('transactions').doc(tid), topUpTx.toMap());
      tx.update(customerRef, {
        'balance': currentBalance + amount,
      });
    });
  }

  // --- Statistics & Settings ---


  // جلب إعدادات التطبيق (مثل سعر اللتر)
  Stream<DocumentSnapshot> getAppSettings() {
    return _db.collection('settings').doc('global').snapshots();
  }

  Future<void> updatePrice(double newPrice) async {
    await _db.collection('settings').doc('global').set({
      'price_per_liter': newPrice,
    }, SetOptions(merge: true));
  }

  Future<void> deleteStaff(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // --- History ---
  
  Stream<List<TransactionModel>> getCustomerHistory(String customerId) {
    return _db
        .collection('transactions')
        .where('customerId', isEqualTo: customerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data()))
            .toList());
  }

  // [FIX #10] limit(50) موجود بالفعل — يمنع قراءة آلاف السجلات من Firestore
  Stream<List<TransactionModel>> getAllTransactions() {
    return _db
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data()))
            .toList());
  }

}
