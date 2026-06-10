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
import 'number_to_words_spanish.dart';

import '../../data/services/finance_service.dart';

class ReceiptPdfUtils {
  static Future<void> generateAndShareReceipt({
    required BuildContext context,
    required PaymentModel payment,
    required UserModel admin,
    required String residentUnit,
  }) async {
    // 0. Obtener el perfil del tesorero para la firma
    final financeService = FinanceService();
    final treasurer = await financeService.getTreasurerProfile();

    pw.Font? customFont;
    pw.Font? customFontBold;
    pw.Font? customFontItalic;
    
    try {
      customFont = await PdfGoogleFonts.notoSansRegular();
      customFontBold = await PdfGoogleFonts.notoSansBold();
      customFontItalic = await PdfGoogleFonts.notoSansItalic();
    } catch (e) {
      debugPrint('Error cargando fuentes: $e');
    }

    final pdf = pw.Document();

    pw.ImageProvider? signatureImage;
    if (treasurer?.signatureUrl != null && treasurer!.signatureUrl!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(treasurer.signatureUrl!));
        if (response.statusCode == 200) {
          signatureImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        debugPrint('Error cargando firma: $e');
      }
    }

    // Colores Elegantes
    const primaryNavy = PdfColor.fromInt(0xFF1A237E); // Navy Blue
    const secondaryGrey = PdfColor.fromInt(0xFF546E7A); // Slate Grey
    const accentGold = PdfColor.fromInt(0xFFBDB183); // Subtle Gold
    const lightBackground = PdfColor.fromInt(0xFFF9FAFB);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5.landscape,
        margin: const pw.EdgeInsets.all(30),
        theme: pw.ThemeData.withFont(
          base: customFont,
          bold: customFontBold,
          italic: customFontItalic,
        ),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Borde decorativo lateral
              pw.Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: pw.Container(width: 4, color: accentGold),
              ),
              
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                      // Encabezado
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('RECIBO DE PAGO', 
                              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: primaryNavy, letterSpacing: 1.2)),
                            pw.Text('Asociación de colonos de la prolongación de la calle Acacias A.C.', 
                              style: pw.TextStyle(fontSize: 8, color: secondaryGrey, letterSpacing: 0.5)),
                          ],
                        ),
                        // Folio eliminado por solicitud del usuario
                      ],
                    ),
                    
                    pw.SizedBox(height: 10),
                    pw.Divider(color: accentGold, thickness: 0.5),
                    pw.SizedBox(height: 15),

                    // Bloque de Información Principal
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('RECIBIMOS DE:', style: pw.TextStyle(fontSize: 7, color: secondaryGrey, fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 4),
                              pw.Text(payment.residentName?.toUpperCase() ?? 'N/A', 
                                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                              pw.SizedBox(height: 2),
                              pw.Text('Unidad Residencial: $residentUnit', style: const pw.TextStyle(fontSize: 9, color: secondaryGrey)),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(10),
                            decoration: pw.BoxDecoration(
                              color: lightBackground,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                            ),
                            child: pw.Column(
                              children: [
                                pw.Text('MONTO TOTAL', style: pw.TextStyle(fontSize: 7, color: secondaryGrey)),
                                pw.SizedBox(height: 2),
                                pw.Text('\$${payment.amount.toStringAsFixed(2)}', 
                                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: primaryNavy)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 20),

                    // Cantidad en Letra
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(left: pw.BorderSide(color: accentGold, width: 2)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('CANTIDAD CON LETRA', style: pw.TextStyle(fontSize: 7, color: secondaryGrey, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text(NumberToWordsSpanish.convert(payment.amount), 
                            style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.black)),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 20),

                    // Concepto
                    pw.Text('POR CONCEPTO DE:', style: pw.TextStyle(fontSize: 7, color: secondaryGrey, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Servicios de portería del mes de ${payment.month} del ${payment.year}.\nAsociación de colonos de la prolongación de la calle Acacias A.C.',
                      style: const pw.TextStyle(fontSize: 10, lineSpacing: 4),
                    ),

                    pw.Spacer(),

                    // Pie de página con Firma y Fecha
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('FECHA DE EMISIÓN', style: pw.TextStyle(fontSize: 7, color: secondaryGrey)),
                            pw.Text('${payment.createdAt.day} de ${payment.month} de ${payment.year}', 
                              style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              if (signatureImage != null)
                                pw.Image(signatureImage, height: 40)
                              else
                                pw.SizedBox(height: 40),
                              pw.Container(width: 140, height: 0.5, color: secondaryGrey),
                              pw.SizedBox(height: 4),
                              pw.Text('TESORERÍA', style: pw.TextStyle(fontSize: 7, color: secondaryGrey, fontWeight: pw.FontWeight.bold)),
                              pw.Text(treasurer?.fullName.toUpperCase() ?? 'PENDIENTE DE ASIGNAR', 
                                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 100),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final fileName = "Recibo_${payment.month}_${payment.year}_CuotaMensual.pdf";
    final file = File("${output.path}/$fileName");
    await file.writeAsBytes(await pdf.save());

    final String message = "RECIBO DE PAGO CUOTA MENSUAL ${payment.month.toUpperCase()} ${payment.year}";

    await Share.shareXFiles(
      [XFile(file.path, name: fileName)],
      text: message,
    );
  }
}


