import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── تسجيل دخول ───────────────────────────────────────────────────────────
  /// يُعيد UserModel عند النجاح، ويرمي استثناءً برسالة واضحة عند الفشل.
  Future<UserModel?> signIn(String emailOrPhone, String password) async {
    try {
      String email = emailOrPhone;
      if (RegExp(r'^[0-9+\s]+$').hasMatch(emailOrPhone)) {
        String normalizedPhone = DatabaseService.normalizePhone(emailOrPhone);
        email = '$normalizedPhone@raindrop.jo';


        // تحقق أولاً إذا كان الرقم مسجلاً لتجاوز غموض خطأ invalid-credential
        bool registered = await isPhoneRegistered(normalizedPhone);
        if (!registered) {
          throw 'لا يوجد حساب مرتبط بهذا الرقم';
        }
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        return await getUserData(user.uid);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException in signIn: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          throw 'لا يوجد حساب مرتبط بهذا الرقم';
        case 'wrong-password':
        case 'invalid-credential':
          throw 'كلمة المرور غير صحيحة';
        case 'invalid-email':
          throw 'صيغة البريد الإلكتروني غير صحيحة';
        case 'user-disabled':
          throw 'هذا الحساب موقوف. تواصل مع الدعم';
        case 'network-request-failed':
          throw 'تحقق من اتصالك بالإنترنت وأعد المحاولة';
        case 'too-many-requests':
          throw 'محاولات كثيرة. الرجاء الانتظار قليلاً';
        default:
          throw 'فشل تسجيل الدخول: ${e.message ?? 'خطأ غير معروف'}';
      }
    } catch (e) {
      if (e is String) rethrow; // إذا كان الخطأ نصاً مرسلاً منا، قم برميه مباشرة
      debugPrint('Unknown error in signIn: $e');
      throw 'حدث خطأ غير متوقع. الرجاء المحاولة مجدداً';
    }
    return null;
  }

  // ─── تسجيل خروج ───────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─── جلب بيانات المستخدم ──────────────────────────────────────────────────
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('خطأ في جلب بيانات المستخدم: $e');
    }
    return null;
  }

  // ─── التحقق من وجود رقم الهاتف ────────────────────────────────────────────
  Future<bool> isPhoneRegistered(String phone) async {
    try {
      // [FIX M-04] توحيد الرقم قبل البحث لمنع الحسابات المكررة
      String normalized = DatabaseService.normalizePhone(phone);
      QuerySnapshot query = await _db
          .collection('users')
          .where('phone', isEqualTo: normalized)
          .get();
      return query.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        // [HELP] إذا ظهر هذا الخطأ، يجب تعديل Firestore Rules للسماح بالقراءة للمستخدمين غير المسجلين
        // أو استخدام Cloud Function للتحقق من الرقم بشكل آمن.
        debugPrint('Firestore Permission Denied: Check your Security Rules for the "users" collection.');
        throw 'حدث خطأ في صلاحيات الوصول (Permission Denied). يرجى التأكد من إعدادات قواعد بيانات Firestore.';
      }
      rethrow;
    }
  }

  // ─── التحقق من وجود البريد الإلكتروني ──────────────────────────────────────
  Future<bool> isEmailRegistered(String email) async {
    try {
      QuerySnapshot query = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return query.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint('Firestore Permission Denied: Check your Security Rules.');
        throw 'حدث خطأ في صلاحيات الوصول. يرجى التأكد من إعدادات قواعد بيانات Firestore.';
      }
      rethrow;
    } catch (e) {
      debugPrint('Error checking email: $e');
      return false;
    }
  }

  // ─── نظام OTP ─────────────────────────────────────────────────────────────

  Future<void> sendOTP({
    required String phone,
    required Function(String) onCodeSent,
    required Function(FirebaseAuthException) onFailed,
  }) async {
    String formattedPhone = phone.startsWith('+')
        ? phone
        : '+962${phone.substring(phone.startsWith('0') ? 1 : 0)}';

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: onFailed,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<bool> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      debugPrint('OTP Verification Failed: $e');
      return false;
    }
  }

  // ─── تسجيل عميل جديد بعد OTP ──────────────────────────────────────────────
  Future<UserModel?> signUpCustomer({
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      String normalizedPhone = DatabaseService.normalizePhone(phone);
      String email = '$normalizedPhone@raindrop.jo';
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);
        await currentUser.linkWithCredential(credential);
        await currentUser.updateDisplayName(name);

        UserModel newUser = UserModel(
          id: currentUser.uid,
          name: name,
          email: email,
          phone: normalizedPhone,
          role: UserRole.customer,
          balance: 0.0,
          points: 0,
        );
        await _db.collection('users').doc(currentUser.uid).set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      debugPrint('Error in signUpCustomer: $e');
      rethrow;
    }
    return null;
  }

  // ─── إضافة موظف جديد (من قبل المسؤول) ────────────────────────────────────
  // [FIX BUG-02] اسم فريد لكل تطبيق ثانوي + حذف في finally
  Future<bool> addStaffByAdmin({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final String uniqueAppName =
        'SecondaryApp_${DateTime.now().millisecondsSinceEpoch}';
    FirebaseApp? secondaryApp;

    try {
      if (await isPhoneRegistered(phone)) {
        throw 'رقم الهاتف مسجل بالفعل';
      }

      if (await isEmailRegistered(email)) {
        throw 'البريد الإلكتروني مسجل بالفعل';
      }

      secondaryApp = await Firebase.initializeApp(
        name: uniqueAppName,
        options: Firebase.app().options,
      );

      UserCredential result = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(email: email, password: password);

      if (result.user != null) {
        UserModel newStaff = UserModel(
          id: result.user!.uid,
          name: name,
          email: email,
          phone: DatabaseService.normalizePhone(phone),
          role: UserRole.staff,
          balance: 0.0,
          points: 0,
        );
        await _db
            .collection('users')
            .doc(result.user!.uid)
            .set(newStaff.toMap());
        return true;
      }
    } catch (e) {
      debugPrint('Error adding staff: $e');
      rethrow;
    } finally {
      // دائماً احذف التطبيق الثانوي سواء نجحت العملية أم فشلت
      await secondaryApp?.delete();
    }
    return false;
  }

  // [FIX #7] حُذفت deleteStaff من هنا — استخدم DatabaseService.deleteStaff فقط
  // (كانت مكررة بنفس الجسم في DatabaseService مما يكسر مبدأ DRY)

  // ─── تحديث بيانات الموظف ──────────────────────────────────────────────────
  Future<void> updateStaffProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    await _db.collection('users').doc(uid).update({
      'name': name,
      'phone': DatabaseService.normalizePhone(phone),
    });
  }

  // ─── إعادة تعيين كلمة المرور ──────────────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── تغيير كلمة المرور ───────────────────────────────────────────────────
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    User? user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw 'لم يتم العثور على مستخدم مسجل دخول';
    }

    try {
      // إعادة المصادقة مطلوبة لتغيير كلمة المرور في Firebase
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException in changePassword: ${e.code}');
      switch (e.code) {
        case 'wrong-password':
          throw 'كلمة المرور القديمة غير صحيحة';
        case 'weak-password':
          throw 'كلمة المرور الجديدة ضعيفة جداً';
        case 'requires-recent-login':
          throw 'هذه العملية حساسة وتتطلب تسجيل دخول حديث. يرجى تسجيل الخروج والدخول مرة أخرى.';
        default:
          throw 'فشل تغيير كلمة المرور: ${e.message}';
      }
    } catch (e) {
      debugPrint('Unknown error in changePassword: $e');
      throw 'حدث خطأ غير متوقع. الرجاء المحاولة مجدداً';
    }
  }

  // ─── قائمة الموظفين ───────────────────────────────────────────────────────
  Stream<List<UserModel>> getStaffList() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'staff')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList());
  }
}
