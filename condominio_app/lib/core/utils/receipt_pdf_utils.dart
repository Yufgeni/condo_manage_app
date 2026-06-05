import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/user_model.dart';

class ReceiptPdfUtils {
  static Future<void> generateAndShareReceipt({
    required BuildContext context,
    required PaymentModel payment,
    required UserModel admin,
    required String residentUnit,
  }) async {
    // 1. Cargar fuentes profesionales para evitar crashes por archivos dañados
    pw.Font? customFont;
    pw.Font? customFontBold;
    
    try {
      customFont = await PdfGoogleFonts.notoSansRegular();
      customFontBold = await PdfGoogleFonts.notoSansBold();
    } catch (e) {
      debugPrint('Error cargando fuentes de Google: $e. Se usará fuente estándar.');
    }

    final pdf = pw.Document();

    // Cargar firma si existe
    pw.ImageProvider? signatureImage;
    if (admin.signatureUrl != null && admin.signatureUrl!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(admin.signatureUrl!));
        if (response.statusCode == 200) {
          signatureImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        debugPrint('Error cargando firma para PDF: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        theme: pw.ThemeData.withFont(
          base: customFont,
          bold: customFontBold,
        ),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('RECIBO DE PAGO', 
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text('No. ${payment.id.length > 8 ? payment.id.substring(0, 8).toUpperCase() : payment.id}', 
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                  ],
                ),
                pw.Divider(thickness: 2, color: PdfColors.blue900),
                pw.SizedBox(height: 20),
                
                _buildInfoRow('Fecha:', '${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}'),
                _buildInfoRow('Residente:', payment.residentName ?? 'N/A'),
                _buildInfoRow('Casa:', residentUnit),
                _buildInfoRow('Concepto:', '${payment.description ?? "Mantenimiento"} (${payment.month} ${payment.year})'),
                
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  color: PdfColors.grey100,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('TOTAL PAGADO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('\$${payment.amount.toStringAsFixed(2)}', 
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                    ],
                  ),
                ),
                
                pw.Spacer(),
                
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (signatureImage != null)
                      pw.Image(signatureImage, height: 60, width: 120)
                    else
                      pw.SizedBox(height: 60, child: pw.Center(child: pw.Text('Firma pendiente', style: const pw.TextStyle(color: PdfColors.grey400, fontSize: 10)))),
                    
                    pw.Container(width: 150, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 4),
                    pw.Text('Administración', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text(admin.fullName, style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text('Gracias por su pago puntual', 
                    style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600)),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Guardar archivo temporal
    final output = await getTemporaryDirectory();
    final fileName = "Recibo_${payment.month}_${payment.year}_CuotaMensual.pdf";
    final file = File("${output.path}/$fileName");
    await file.writeAsBytes(await pdf.save());

    final String message = "RECIBO DE PAGO CUOTA MENSUAL ${payment.month.toUpperCase()} ${payment.year}";

    // --- FLUJO ESTÁNDAR DE COMPARTIR ---
    // Simplemente abrimos el menú estándar de compartir del sistema.
    // Esto es lo más familiar para todos los usuarios.
    await Share.shareXFiles(
      [XFile(file.path, name: fileName)],
      text: message,
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 80, child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}
