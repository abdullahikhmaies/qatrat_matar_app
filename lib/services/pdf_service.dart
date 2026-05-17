import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/transaction_model.dart';

class PdfService {
  // [FIX BUG-05] تحقق من طول customerId قبل substring لمنع RangeError
  static String _shortId(String id) {
    if (id.length <= 5) return id;
    return '${id.substring(0, 5)}...';
  }

  static Future<void> generateSalesReport(
      List<TransactionModel> transactions) async {
    final pdf = pw.Document();

    final headers = ['Date', 'Type', 'Customer ID', 'Liters', 'Amount (JOD)'];
    final data = transactions.map((t) {
      return [
        t.timestamp.toString().substring(0, 16),
        t.type == 'refill' ? 'Refill' : 'Top-up',
        _shortId(t.customerId), // آمن الآن
        t.liters.toStringAsFixed(1),
        t.amount.toStringAsFixed(3),
      ];
    }).toList();

    final double totalSales = transactions
        .where((t) => t.type == 'refill')
        .fold(0.0, (sum, t) => sum + t.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Qatrat Matar - Sales Report',
              style: pw.TextStyle(
                  fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data,
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.center,
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total Sales: JOD ${totalSales.toStringAsFixed(3)}',
              style: pw.TextStyle(
                  fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
