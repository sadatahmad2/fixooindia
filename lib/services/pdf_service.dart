import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateInvoice({
    required Map<String, dynamic> booking,
    required String customerName,
  }) async {
    final pdf = pw.Document();
    final date = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    
    // Load Logo
    final ByteData logoData = await rootBundle.load('assets/images/logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    final materials = List<Map<String, dynamic>>.from(booking['materials'] ?? []);
    final double total = double.tryParse(booking['price']?.toString() ?? '0') ?? 0.0;
    final double serviceCost = double.tryParse(booking['service_cost']?.toString() ?? '0') ?? 0.0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 50,
                        height: 50,
                        child: pw.Image(logoImage),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('FIXOOINDIA', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.cyan)),
                          pw.Text('Professional Home Services', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Booking ID: #${booking['id'].toString().substring(0, 8)}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Date: $date', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Customer & Technician Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILL TO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text(customerName, style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('SERVICE BY:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text(booking['partner_name'] ?? 'FixooIndiaIndia Technician', style: const pw.TextStyle(fontSize: 12)),
                      pw.Text(booking['service_name'] ?? 'Service', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Table Header
              pw.Container(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 3, child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 1, child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                    pw.Expanded(flex: 1, child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    pw.Expanded(flex: 1, child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                  ],
                ),
              ),

              // Service Cost Row
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 3, child: pw.Text('${booking['service_name']} (Service Charge)')),
                    pw.Expanded(flex: 1, child: pw.Text('1', textAlign: pw.TextAlign.center)),
                    pw.Expanded(flex: 1, child: pw.Text('Rs $serviceCost', textAlign: pw.TextAlign.right)),
                    pw.Expanded(flex: 1, child: pw.Text('Rs $serviceCost', textAlign: pw.TextAlign.right)),
                  ],
                ),
              ),

              // Materials Rows
              ...materials.map((m) => pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 3, child: pw.Text(m['name'] ?? 'Part')),
                    pw.Expanded(flex: 1, child: pw.Text((m['qty'] ?? 1).toString(), textAlign: pw.TextAlign.center)),
                    pw.Expanded(flex: 1, child: pw.Text('Rs ${m['price'] ?? 0}', textAlign: pw.TextAlign.right)),
                    pw.Expanded(flex: 1, child: pw.Text('Rs ${((m['price'] ?? 0) as num) * ((m['qty'] ?? 1) as num)}', textAlign: pw.TextAlign.right)),
                  ],
                ),
              )),

              pw.Divider(),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Text('Grand Total: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                          pw.Text('Rs $total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.cyan)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 100),
              pw.Center(
                child: pw.Text('Thank you for choosing FixooIndiaIndia!', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey500)),
              ),
              pw.Center(
                child: pw.Text('This is a computer generated invoice.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey300)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
