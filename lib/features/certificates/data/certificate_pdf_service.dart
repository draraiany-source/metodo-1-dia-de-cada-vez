import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../domain/certificate_models.dart';

/// Gera e compartilha o PDF de um certificado desbloqueado.
///
/// Usa cores lilás/roxo/rosa do design system (hex fixo aqui porque o
/// pacote `pdf` tem sua própria classe `PdfColor`, incompatível com
/// `Color` do Flutter).
class CertificatePdfService {
  CertificatePdfService._();

  static const _lilas = PdfColor.fromInt(0xFF9B5DE5);
  static const _roxo = PdfColor.fromInt(0xFF5A189A);
  static const _rosa = PdfColor.fromInt(0xFFF15BB5);

  static Future<void> shareCertificate({
    required CertificateDef cert,
    required String userName,
  }) async {
    final doc = pw.Document();
    final agora = DateTime.now();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [_roxo, _lilas],
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
              ),
            ),
            child: pw.Center(
              child: pw.Container(
                margin: const pw.EdgeInsets.all(28),
                padding: const pw.EdgeInsets.all(36),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(16),
                  border: pw.Border.all(color: _rosa, width: 3),
                ),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text('MÉTODO 1 DIA DE CADA VEZ',
                        style: pw.TextStyle(
                            fontSize: 14,
                            color: _roxo,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 24),
                    pw.Text(cert.emoji, style: const pw.TextStyle(fontSize: 48)),
                    pw.SizedBox(height: 16),
                    pw.Text('Certificado de Conquista',
                        style: pw.TextStyle(
                            fontSize: 22,
                            color: PdfColors.grey700,
                            fontStyle: pw.FontStyle.italic)),
                    pw.SizedBox(height: 20),
                    pw.Text(cert.title,
                        style: pw.TextStyle(
                            fontSize: 32,
                            color: _rosa,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 16),
                    pw.Text('Certificamos que',
                        style: const pw.TextStyle(
                            fontSize: 14, color: PdfColors.grey600)),
                    pw.SizedBox(height: 6),
                    pw.Text(userName,
                        style: pw.TextStyle(
                            fontSize: 26,
                            color: _roxo,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 16),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 60),
                      child: pw.Text(cert.description,
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(
                              fontSize: 13, color: PdfColors.grey700)),
                    ),
                    pw.SizedBox(height: 28),
                    pw.Text(
                        '${agora.day.toString().padLeft(2, '0')}/'
                        '${agora.month.toString().padLeft(2, '0')}/${agora.year}',
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey500)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'certificado_${cert.id}.pdf',
    );
  }
}
