import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../evolution/providers/weight_history_providers.dart';
import '../../running/data/running_repository.dart';

class ReportSection {
  const ReportSection(this.id, this.label);
  final String id;
  final String label;
}

const kReportSections = [
  ReportSection('peso', 'Evolução do peso & IMC'),
  ReportSection('agua', 'Hidratação'),
  ReportSection('calorias', 'Alimentação'),
  ReportSection('corridas', 'Corridas'),
  ReportSection('habitos', 'Hábitos & calendário'),
];

class ReportPdfService {
  ReportPdfService._();

  static const _roxo = PdfColor.fromInt(0xFF5A189A);
  static const _lilas = PdfColor.fromInt(0xFF9B5DE5);

  static Future<void> generateAndShare({
    required String userName,
    required Set<String> sections,
    required List<WeightEntry> pesoHist,
    required Map<DateTime, int> aguaHist,
    required Map<DateTime, int> kcalHist,
    required List<RunningSession> corridas,
    required double taxaHabitos,
    required int periodDays,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Relatório — Método 1 Dia de Cada Vez',
                style: pw.TextStyle(
                    fontSize: 18, color: _roxo, fontWeight: pw.FontWeight.bold)),
            pw.Text('$userName · últimos $periodDays dias',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
            pw.Divider(color: _lilas),
          ],
        ),
        build: (context) {
          final widgets = <pw.Widget>[];

          if (sections.contains('peso')) {
            widgets.add(_sectionTitle('Evolução do peso & IMC'));
            if (pesoHist.isEmpty) {
              widgets.add(_empty('Nenhum peso registrado no período.'));
            } else {
              widgets.add(_table(
                headers: ['Data', 'Peso (kg)'],
                rows: pesoHist
                    .map((e) => [_fmtDate(e.date), e.weight.toStringAsFixed(1)])
                    .toList(),
              ));
            }
            widgets.add(pw.SizedBox(height: 16));
          }

          if (sections.contains('agua')) {
            widgets.add(_sectionTitle('Hidratação'));
            if (aguaHist.isEmpty) {
              widgets.add(_empty('Sem registros de água no período.'));
            } else {
              final media = aguaHist.values.reduce((a, b) => a + b) /
                  aguaHist.length;
              widgets.add(pw.Text(
                  'Média de ${media.toStringAsFixed(1)} copos/dia',
                  style: const pw.TextStyle(fontSize: 11)));
            }
            widgets.add(pw.SizedBox(height: 16));
          }

          if (sections.contains('calorias')) {
            widgets.add(_sectionTitle('Alimentação'));
            if (kcalHist.isEmpty || kcalHist.values.every((v) => v == 0)) {
              widgets.add(_empty('Sem registros de calorias no período.'));
            } else {
              final media =
                  kcalHist.values.reduce((a, b) => a + b) / kcalHist.length;
              widgets.add(pw.Text(
                  'Média de ${media.toStringAsFixed(0)} kcal/dia',
                  style: const pw.TextStyle(fontSize: 11)));
            }
            widgets.add(pw.SizedBox(height: 16));
          }

          if (sections.contains('corridas')) {
            widgets.add(_sectionTitle('Corridas'));
            if (corridas.isEmpty) {
              widgets.add(_empty('Nenhuma corrida no período.'));
            } else {
              final totalKm =
                  corridas.fold<double>(0, (s, r) => s + r.distanceKm);
              widgets.add(pw.Text(
                  '${corridas.length} corridas · ${totalKm.toStringAsFixed(1)} km totais',
                  style: const pw.TextStyle(fontSize: 11)));
              widgets.add(pw.SizedBox(height: 8));
              widgets.add(_table(
                headers: ['Data', 'Km', 'Duração', 'Kcal'],
                rows: corridas
                    .map((r) => [
                          _fmtDate(r.date),
                          r.distanceKm.toStringAsFixed(2),
                          '${(r.durationSeconds / 60).toStringAsFixed(0)} min',
                          '${r.kcal}',
                        ])
                    .toList(),
              ));
            }
            widgets.add(pw.SizedBox(height: 16));
          }

          if (sections.contains('habitos')) {
            widgets.add(_sectionTitle('Hábitos & calendário'));
            widgets.add(pw.Text(
                '${(taxaHabitos * 100).toStringAsFixed(0)}% de conclusão nos últimos 30 dias',
                style: const pw.TextStyle(fontSize: 11)));
          }

          return widgets;
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'relatorio_metodo1dia.pdf',
    );
  }

  static pw.Widget _sectionTitle(String title) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(title,
            style: pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold, color: _roxo)),
      );

  static pw.Widget _empty(String text) => pw.Text(text,
      style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey500));

  static pw.Widget _table(
      {required List<String> headers, required List<List<String>> rows}) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: _roxo),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
