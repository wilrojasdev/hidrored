import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/extensions/formato.dart';
import '../../../domain/enums.dart';
import 'estado_cuenta_data.dart';

/// Genera el PDF del estado de cuenta detallado de un cliente.
class EstadoCuentaPdfBuilder {
  const EstadoCuentaPdfBuilder._();

  static Future<Uint8List> build(EstadoCuentaData data) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (context) => _header(data),
        footer: (context) => _footer(context),
        build: (context) => [
          _datosCliente(data),
          pw.SizedBox(height: 16),
          _resumen(data),
          pw.SizedBox(height: 16),
          _facturasTabla(data),
          pw.SizedBox(height: 16),
          _pagosTabla(data),
        ],
      ),
    );
    return doc.save();
  }

  // ---------- secciones ----------

  static pw.Widget _header(EstadoCuentaData d) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                d.tenant.nombre.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (d.tenant.nit != null)
                pw.Text(
                  'NIT: ${d.tenant.nit}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'ESTADO DE CUENTA',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Corte: ${formatFecha(d.fechaCorte)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer(pw.Context context) => pw.Container(
    alignment: pw.Alignment.centerRight,
    padding: const pw.EdgeInsets.only(top: 8),
    child: pw.Text(
      'Página ${context.pageNumber} de ${context.pagesCount}',
      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
    ),
  );

  static pw.Widget _datosCliente(EstadoCuentaData d) {
    final s = d.cliente;
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _campo('Cliente', s.nombre),
                _campo('Cédula', s.cedula),
                _campo('Código', '${s.codigo}'),
              ],
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _campo('Dirección', s.direccion ?? '-'),
                _campo('Teléfono', s.telefono ?? '-'),
                _campo('Estado', s.estado.label),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _resumen(EstadoCuentaData d) {
    final pendientes = d.facturas.where(
      (f) => f.estado == EstadoFactura.pendiente,
    );
    final pagadas = d.facturas.where((f) => f.estado == EstadoFactura.pagada);
    final totalPendiente = pendientes.fold<int>(0, (s, f) => s + f.total);
    final totalPagado = d.pagos.fold<int>(0, (s, p) => s + p.valor);

    return pw.Row(
      children: [
        pw.Expanded(
          child: _resumenCard(
            'Facturas pendientes',
            '${pendientes.length}',
            formatPesos(totalPendiente),
            color: PdfColors.red700,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _resumenCard(
            'Facturas pagadas',
            '${pagadas.length}',
            formatPesos(pagadas.fold<int>(0, (s, f) => s + f.total)),
            color: PdfColors.green700,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _resumenCard(
            'Pagos recibidos',
            '${d.pagos.length}',
            formatPesos(totalPagado),
            color: PdfColors.blue700,
          ),
        ),
      ],
    );
  }

  static pw.Widget _resumenCard(
    String label,
    String count,
    String monto, {
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            count,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            monto,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _facturasTabla(EstadoCuentaData d) {
    if (d.facturas.isEmpty) {
      return pw.Text(
        'Sin facturas registradas.',
        style: const pw.TextStyle(fontSize: 10),
      );
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'FACTURAS',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(width: 0.4, color: PdfColors.grey400),
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(2),
            4: pw.FlexColumnWidth(2),
            5: pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _th('Recibo'),
                _th('Periodo'),
                _th('Emisión'),
                _th('Vence'),
                _th('Estado'),
                _th('Total', alignRight: true),
              ],
            ),
            for (final f in d.facturas)
              pw.TableRow(
                children: [
                  _td(f.numero),
                  _td(formatPeriodo(f.periodo)),
                  _td(formatFecha(f.fechaEmision)),
                  _td(formatFecha(f.fechaVencimiento)),
                  _td(f.estado.label, color: _colorEstado(f.estado)),
                  _td(formatPesos(f.total), alignRight: true, bold: true),
                ],
              ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _pagosTabla(EstadoCuentaData d) {
    if (d.pagos.isEmpty) {
      return pw.Text(
        'Sin pagos registrados.',
        style: const pw.TextStyle(fontSize: 10),
      );
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PAGOS',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(width: 0.4, color: PdfColors.grey400),
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(3),
            3: pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _th('Fecha'),
                _th('Método'),
                _th('Referencia'),
                _th('Valor', alignRight: true),
              ],
            ),
            for (final p in d.pagos)
              pw.TableRow(
                children: [
                  _td(formatFecha(p.fecha)),
                  _td(p.metodo.label),
                  _td(p.referencia ?? '-'),
                  _td(formatPesos(p.valor), alignRight: true, bold: true),
                ],
              ),
          ],
        ),
      ],
    );
  }

  // ---------- helpers ----------

  static pw.Widget _campo(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 56,
            child: pw.Text(
              '$label:',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _th(String text, {bool alignRight = false}) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
    ),
  );

  static pw.Widget _td(
    String text, {
    bool alignRight = false,
    bool bold = false,
    PdfColor? color,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color,
      ),
      textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
    ),
  );

  static PdfColor _colorEstado(EstadoFactura e) => switch (e) {
    EstadoFactura.pendiente => PdfColors.orange700,
    EstadoFactura.pagada => PdfColors.green700,
    EstadoFactura.anulada => PdfColors.grey600,
    EstadoFactura.refacturada => PdfColors.blue700,
  };
}
