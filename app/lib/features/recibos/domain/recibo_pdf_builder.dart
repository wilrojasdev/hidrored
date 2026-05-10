import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/extensions/formato.dart';
import '../../../domain/entities/tenant.dart';
import 'recibo_data.dart';

/// Construye los PDFs de recibo (uno por cliente) para imprimir o
/// compartir. Replica la maqueta del recibo en papel del cliente.
class ReciboPdfBuilder {
  const ReciboPdfBuilder._();

  /// PDF de un solo recibo, ocupando una pagina completa.
  static Future<Uint8List> buildIndividual(ReciboData data) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => _reciboWidget(data, escala: 1.0),
      ),
    );
    return doc.save();
  }

  /// PDF con multiples recibos, 4 por pagina (2x2).
  static Future<Uint8List> buildLote(List<ReciboData> recibos) async {
    final doc = pw.Document();
    if (recibos.isEmpty) return doc.save();

    for (var i = 0; i < recibos.length; i += 4) {
      final lote = recibos.skip(i).take(4).toList();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(18),
          build: (context) => _quadGrid(lote),
        ),
      );
    }
    return doc.save();
  }

  // ---------- privado ----------

  static pw.Widget _quadGrid(List<ReciboData> recibos) {
    return pw.Column(
      children: [
        pw.Expanded(
          child: pw.Row(
            children: [
              pw.Expanded(child: _cuadrante(recibos.elementAtOrNull(0))),
              pw.SizedBox(width: 8),
              pw.Expanded(child: _cuadrante(recibos.elementAtOrNull(1))),
            ],
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Expanded(
          child: pw.Row(
            children: [
              pw.Expanded(child: _cuadrante(recibos.elementAtOrNull(2))),
              pw.SizedBox(width: 8),
              pw.Expanded(child: _cuadrante(recibos.elementAtOrNull(3))),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _cuadrante(ReciboData? data) {
    if (data == null) return pw.Container();
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: _reciboWidget(data, escala: 0.7),
    );
  }

  static pw.Widget _reciboWidget(ReciboData d, {required double escala}) {
    final f = d.factura;
    final t = d.tenant;
    final s = d.cliente;

    final fontTitulo = pw.TextStyle(
      fontSize: 12 * escala,
      fontWeight: pw.FontWeight.bold,
    );
    final fontTexto = pw.TextStyle(fontSize: 9 * escala);
    final fontPequeno = pw.TextStyle(fontSize: 8 * escala);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Header
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(t.nombre.toUpperCase(), style: fontTitulo),
                if (t.nit != null) pw.Text('NIT: ${t.nit}', style: fontPequeno),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
              child: pw.Text(f.numero, style: fontPequeno),
            ),
          ],
        ),
        if (t.representanteLegal != null) ...[
          pw.SizedBox(height: 4 * escala),
          pw.Text(
            'REPRESENTANTE LEGAL ${t.representanteLegal!.toUpperCase()}',
            style: fontPequeno,
            textAlign: pw.TextAlign.center,
          ),
        ],
        pw.SizedBox(height: 8 * escala),
        // Datos del usuario
        _row('USUARIO:', s.nombre.toUpperCase(), fontTexto, fontPequeno),
        if (s.direccion != null)
          _row('DIRECCIÓN:', s.direccion!, fontTexto, fontPequeno),
        if (s.cedula.isNotEmpty)
          _row('CÉDULA:', s.cedula, fontTexto, fontPequeno),
        pw.SizedBox(height: 4 * escala),
        pw.Text(
          'EL USUARIO TIENE DERECHO A CINCO (5) DÍAS HÁBILES PARA SU PAGO',
          style: fontPequeno,
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 6 * escala),
        // Tablita de fecha + usuario + zona
        pw.Row(
          children: [
            pw.Expanded(
              child: _miniTabla(
                ['DÍA', 'MES', 'AÑO'],
                [
                  '${f.fechaEmision.day}',
                  '${f.fechaEmision.month}',
                  '${f.fechaEmision.year}',
                ],
                fontPequeno,
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Expanded(
              child: _miniTabla(
                ['# USUARIO', '# ZONA'],
                ['${s.codigo}', s.zona ?? ''],
                fontPequeno,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6 * escala),
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          color: PdfColors.grey200,
          child: pw.Text(
            'EL ATRASO DE DOS FACTURAS GENERA LA SUSPENSIÓN DEL SERVICIO',
            style: fontPequeno,
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 6 * escala),
        // Tabla de conceptos
        _tablaConceptos(d, fontPequeno),
        pw.SizedBox(height: 4 * escala),
        // Total
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text('TOTAL: ', style: fontTitulo),
            pw.Text(
              formatPesos(d.totalReciboCobrar),
              style: fontTitulo.copyWith(
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ],
        ),
        if (s.sector != null) ...[
          pw.SizedBox(height: 4 * escala),
          pw.Text('SECTOR: ${s.sector}', style: fontPequeno),
        ],
        pw.Spacer(),
        // Footer
        pw.Container(
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(width: 0.5)),
          ),
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Text(
            _footerPago(t),
            style: fontPequeno,
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    );
  }

  static pw.Widget _row(
    String label,
    String value,
    pw.TextStyle fontTexto,
    pw.TextStyle fontPequeno,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 60, child: pw.Text(label, style: fontPequeno)),
          pw.Expanded(
            child: pw.Text(
              value,
              style: fontTexto.copyWith(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _miniTabla(
    List<String> headers,
    List<String> values,
    pw.TextStyle font,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      children: [
        pw.TableRow(
          children: [
            for (final h in headers)
              pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(
                  h,
                  style: font.copyWith(fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
              ),
          ],
        ),
        pw.TableRow(
          children: [
            for (final v in values)
              pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(v, style: font, textAlign: pw.TextAlign.center),
              ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _tablaConceptos(ReciboData d, pw.TextStyle font) {
    final filas = <_FilaConcepto>[];

    if (d.cantidadAtrasos > 0) {
      filas.add(
        _FilaConcepto(
          concepto: 'FACTURAS ATRASADAS',
          cantidad: d.cantidadAtrasos,
          valor: d.totalAtrasos,
        ),
      );
    }
    for (final l in d.lineas) {
      filas.add(
        _FilaConcepto(
          concepto: l.descripcion.toUpperCase(),
          cantidad: l.cantidad,
          valor: l.subtotal,
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _cell('CONCEPTO', font, bold: true),
            _cell('CANT.', font, bold: true, center: true),
            _cell('VALOR', font, bold: true, right: true),
          ],
        ),
        for (final f in filas)
          pw.TableRow(
            children: [
              _cell(f.concepto, font),
              _cell('${f.cantidad}', font, center: true),
              _cell(formatPesos(f.valor), font, right: true),
            ],
          ),
      ],
    );
  }

  static pw.Widget _cell(
    String text,
    pw.TextStyle font, {
    bool bold = false,
    bool center = false,
    bool right = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: pw.Text(
        text,
        style: bold ? font.copyWith(fontWeight: pw.FontWeight.bold) : font,
        textAlign: right
            ? pw.TextAlign.right
            : center
            ? pw.TextAlign.center
            : pw.TextAlign.left,
      ),
    );
  }

  static String _footerPago(Tenant t) {
    final partes = <String>[];
    if (t.cuentaBancolombia != null) {
      partes.add('Bancolombia ${t.cuentaBancolombia}');
    }
    if (t.cuentaNequi != null) {
      partes.add('Nequi ${t.cuentaNequi}');
    }
    if (partes.isEmpty) return 'Pague oportunamente.';
    return 'PAGUE OPORTUNAMENTE: ${partes.join(' o ')}';
  }
}

class _FilaConcepto {
  _FilaConcepto({
    required this.concepto,
    required this.cantidad,
    required this.valor,
  });
  final String concepto;
  final int cantidad;
  final int valor;
}
