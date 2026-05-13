import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/extensions/formato.dart';
import '../../../domain/entities/factura.dart';
import '../../../domain/entities/tenant.dart';
import 'recibo_data.dart';

/// Construye los PDFs de recibo (uno por cliente) para imprimir o
/// compartir. Maquetación clara, marca en azul y bloque destacado de pago.
class ReciboPdfBuilder {
  const ReciboPdfBuilder._();

  /// Azul principal (alineado con identidad acueducto / logo por defecto).
  static const PdfColor _brand = PdfColor(0.01, 0.53, 0.82);
  static const PdfColor _brandDark = PdfColor(0.0, 0.34, 0.55);
  static const PdfColor _surface = PdfColor(0.90, 0.96, 1.0);
  static const PdfColor _surfaceStrong = PdfColor(0.78, 0.91, 0.99);

  static Future<Uint8List?>? _logoFuture;

  static Future<Uint8List?> _logoPorDefecto() {
    _logoFuture ??= () async {
      try {
        final data = await rootBundle.load(
          'assets/images/tenant_default_logo.png',
        );
        return data.buffer.asUint8List();
      } catch (_) {
        return null;
      }
    }();
    return _logoFuture!;
  }

  /// PDF de un solo recibo, ocupando una pagina completa.
  static Future<Uint8List> buildIndividual(ReciboData data) async {
    final logo = await _logoPorDefecto();
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => _reciboWidget(data, escala: 1.0, logoBytes: logo),
      ),
    );
    return doc.save();
  }

  /// PDF con multiples recibos, 4 por pagina (2x2).
  static Future<Uint8List> buildLote(List<ReciboData> recibos) async {
    final doc = pw.Document();
    if (recibos.isEmpty) return doc.save();

    final logo = await _logoPorDefecto();
    for (var i = 0; i < recibos.length; i += 4) {
      final lote = recibos.skip(i).take(4).toList();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(16),
          build: (context) => _quadGrid(lote, logoBytes: logo),
        ),
      );
    }
    return doc.save();
  }

  // ---------- privado ----------

  static pw.Widget _quadGrid(
    List<ReciboData> recibos, {
    required Uint8List? logoBytes,
  }) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _cuadrante(recibos.elementAtOrNull(0), logoBytes),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _cuadrante(recibos.elementAtOrNull(1), logoBytes),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _cuadrante(recibos.elementAtOrNull(2), logoBytes),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _cuadrante(recibos.elementAtOrNull(3), logoBytes),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _cuadrante(ReciboData? data, Uint8List? logoBytes) {
    if (data == null) return pw.Container();
    return pw.Container(
      alignment: pw.Alignment.topCenter,
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: _brand, width: 0.75),
      ),
      padding: const pw.EdgeInsets.all(4),
      // El recibo completo supera la mitad de A4; sin escala global el PDF
      // recorta por abajo y desaparecen total y medios de pago.
      // [FittedBox] debe envolver un hijo con ancho finito: si no, los
      // [Row]+[Expanded] del recibo reciben ancho ilimitado y falla el layout.
      child: pw.LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints?.maxWidth;
          final w = (maxW != null && maxW.isFinite && maxW > 0) ? maxW : 260.0;
          return pw.FittedBox(
            fit: pw.BoxFit.contain,
            alignment: pw.Alignment.topCenter,
            child: pw.SizedBox(
              width: w,
              child: _reciboWidget(
                data,
                escala: 0.72,
                logoBytes: logoBytes,
                compactoLote: true,
              ),
            ),
          );
        },
      ),
    );
  }

  static pw.Widget _reciboWidget(
    ReciboData d, {
    required double escala,
    required Uint8List? logoBytes,

    /// En cuadrícula 2×2 el [pw.Spacer] dentro de columnas anidadas puede
    /// dejar sin espacio visible al bloque de medios de pago; aquí se evita.
    bool compactoLote = false,
  }) {
    final f = d.factura;
    final t = d.tenant;
    final s = d.cliente;

    final fontTitulo = pw.TextStyle(
      fontSize: 13 * escala,
      fontWeight: pw.FontWeight.bold,
      color: _brandDark,
    );
    final fontSubtitulo = pw.TextStyle(
      fontSize: 10 * escala,
      fontWeight: pw.FontWeight.bold,
      color: _brandDark,
    );
    final fontTexto = pw.TextStyle(
      fontSize: 9 * escala,
      color: PdfColors.grey800,
    );
    final fontPequeno = pw.TextStyle(
      fontSize: 8 * escala,
      color: PdfColors.grey700,
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _cabecera(t, f, fontTitulo, fontPequeno, escala, logoBytes),
        if (t.representanteLegal != null) ...[
          pw.SizedBox(height: 4 * escala),
          pw.Text(
            'Representante legal: ${t.representanteLegal}',
            style: fontPequeno.copyWith(fontStyle: pw.FontStyle.italic),
            textAlign: pw.TextAlign.center,
          ),
        ],
        pw.SizedBox(height: 8 * escala),
        pw.Container(
          padding: pw.EdgeInsets.all(8 * escala),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: pw.BorderRadius.circular(4),
            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _row('Usuario', s.nombre.toUpperCase(), fontTexto, fontPequeno),
              if (s.direccion != null)
                _row('Dirección', s.direccion!, fontTexto, fontPequeno),
              if (s.cedula.isNotEmpty)
                _row('Cédula', formatCedula(s.cedula), fontTexto, fontPequeno),
            ],
          ),
        ),
        pw.SizedBox(height: 6 * escala),
        pw.Text(
          'El usuario tiene derecho a ${t.diasHabilesPago} días hábiles para su pago.',
          style: fontPequeno,
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 6 * escala),
        pw.Row(
          children: [
            pw.Expanded(
              child: _miniTabla(
                ['Día', 'Mes', 'Año'],
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
                ['# Usuario', '# Zona'],
                ['${s.codigo}', s.zona ?? '—'],
                fontPequeno,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6 * escala),
        pw.Container(
          padding: pw.EdgeInsets.symmetric(
            horizontal: 6 * escala,
            vertical: 4 * escala,
          ),
          decoration: pw.BoxDecoration(
            color: _surfaceStrong,
            borderRadius: pw.BorderRadius.circular(3),
            border: pw.Border.all(color: _brand, width: 0.4),
          ),
          child: pw.Text(
            'El atraso de dos facturas genera la suspensión del servicio.',
            style: fontPequeno.copyWith(
              fontWeight: pw.FontWeight.bold,
              color: _brandDark,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 6 * escala),
        _tablaConceptos(d, fontPequeno),
        pw.SizedBox(height: 6 * escala),
        pw.Container(
          padding: pw.EdgeInsets.symmetric(
            horizontal: 10 * escala,
            vertical: 8 * escala,
          ),
          decoration: pw.BoxDecoration(
            color: _surface,
            borderRadius: pw.BorderRadius.circular(4),
            border: pw.Border.all(color: _brand, width: 1),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('Total a pagar', style: fontSubtitulo),
              pw.SizedBox(width: 10),
              pw.Text(
                formatPesos(d.totalReciboCobrar),
                style: fontTitulo.copyWith(
                  color: _brandDark,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 8 * escala),
        _bloqueMediosPago(
          t,
          f.numero,
          escala,
          fontPequeno,
          fontTexto,
          fontSubtitulo,
          compacto: compactoLote,
        ),
        if (s.sector != null) ...[
          pw.SizedBox(height: 4 * escala),
          pw.Text('Sector: ${s.sector}', style: fontPequeno),
        ],
        if (compactoLote)
          pw.SizedBox(height: 2 * escala)
        else ...[
          pw.Spacer(),
          pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: _brand, width: 0.5)),
            ),
            padding: pw.EdgeInsets.only(top: 6 * escala),
            child: pw.Text(
              'Gracias por mantener al día su servicio de acueducto.',
              style: fontPequeno.copyWith(color: PdfColors.grey600),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _cabecera(
    Tenant t,
    Factura f,
    pw.TextStyle fontTitulo,
    pw.TextStyle fontPequeno,
    double escala,
    Uint8List? logoBytes,
  ) {
    return pw.Container(
      padding: pw.EdgeInsets.only(bottom: 8 * escala),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _brand, width: 2)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logoBytes != null && logoBytes.isNotEmpty)
            pw.Padding(
              padding: pw.EdgeInsets.only(right: 10 * escala),
              child: pw.Image(
                pw.MemoryImage(logoBytes),
                height: 52 * escala,
                fit: pw.BoxFit.contain,
              ),
            ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(t.nombre.toUpperCase(), style: fontTitulo),
                if (t.nit != null) pw.Text('NIT ${t.nit}', style: fontPequeno),
                pw.SizedBox(height: 2 * escala),
                pw.Text(
                  'Periodo: ${formatPeriodo(f.periodo)} · Vence: ${formatFecha(f.fechaVencimiento)}',
                  style: fontPequeno,
                ),
              ],
            ),
          ),
          pw.Container(
            padding: pw.EdgeInsets.symmetric(
              horizontal: 10 * escala,
              vertical: 6 * escala,
            ),
            decoration: pw.BoxDecoration(
              color: _brand,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'RECIBO',
                  style: fontPequeno.copyWith(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                pw.Text(
                  f.numero,
                  style: fontTitulo.copyWith(
                    color: PdfColors.white,
                    fontSize: (fontTitulo.fontSize ?? 13) * 0.95,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Versión baja de medios de pago para la cuadrícula 2×2 (cabe con [pw.FittedBox]).
  static pw.Widget _bloqueMediosPagoCompact(
    Tenant t,
    String numeroRecibo,
    double escala,
    pw.TextStyle fontPequeno,
    pw.TextStyle fontTexto,
    pw.TextStyle fontSubtitulo,
  ) {
    final tieneBanco =
        t.cuentaBancolombia != null && t.cuentaBancolombia!.trim().isNotEmpty;
    final tieneNequi =
        t.cuentaNequi != null && t.cuentaNequi!.trim().isNotEmpty;

    final titulo = pw.TextStyle(
      fontSize: (fontSubtitulo.fontSize ?? 10) + escala,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );
    final fontCuenta = pw.TextStyle(
      fontSize: (fontTexto.fontSize ?? 9) + 2.5 * escala,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.grey900,
    );
    final fontEtiqueta = pw.TextStyle(
      fontSize: (fontPequeno.fontSize ?? 8) + 0.5 * escala,
      fontWeight: pw.FontWeight.bold,
      color: _brandDark,
    );

    final cuerpo = <pw.Widget>[
      pw.Container(
        width: double.infinity,
        padding: pw.EdgeInsets.symmetric(
          horizontal: 6 * escala,
          vertical: 4 * escala,
        ),
        decoration: const pw.BoxDecoration(color: _brandDark),
        child: pw.Center(child: pw.Text('MEDIOS DE PAGO', style: titulo)),
      ),
    ];

    if (!tieneBanco && !tieneNequi) {
      cuerpo.add(
        pw.Padding(
          padding: pw.EdgeInsets.all(6 * escala),
          child: pw.Text(
            'Consulte en administración los medios de pago habilitados.',
            style: fontPequeno,
            textAlign: pw.TextAlign.center,
          ),
        ),
      );
    } else {
      if (tieneBanco) {
        cuerpo.add(
          pw.Padding(
            padding: pw.EdgeInsets.fromLTRB(
              6 * escala,
              5 * escala,
              6 * escala,
              tieneNequi ? 2 * escala : 3 * escala,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Bancolombia', style: fontEtiqueta),
                pw.Text(t.cuentaBancolombia!.trim(), style: fontCuenta),
              ],
            ),
          ),
        );
      }
      if (tieneNequi) {
        cuerpo.add(
          pw.Padding(
            padding: pw.EdgeInsets.fromLTRB(
              6 * escala,
              tieneBanco ? 0 : 5 * escala,
              6 * escala,
              3 * escala,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Nequi', style: fontEtiqueta),
                pw.Text(t.cuentaNequi!.trim(), style: fontCuenta),
              ],
            ),
          ),
        );
      }
      cuerpo.add(
        pw.Container(
          width: double.infinity,
          padding: pw.EdgeInsets.symmetric(
            horizontal: 6 * escala,
            vertical: 4 * escala,
          ),
          decoration: const pw.BoxDecoration(
            color: PdfColors.amber50,
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.amber200, width: 0.5),
            ),
          ),
          child: pw.Text(
            'Indique su número de usuario y el recibo $numeroRecibo en el pago.',
            style: fontPequeno.copyWith(
              fontWeight: pw.FontWeight.bold,
              fontSize: fontPequeno.fontSize,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      );
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: _brandDark, width: 1),
        color: PdfColors.white,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: cuerpo,
      ),
    );
  }

  /// Bloque grande con medios de pago (énfasis visual).
  /// En [compacto] (lote 2×2) se usa versión baja para caber con [pw.FittedBox].
  static pw.Widget _bloqueMediosPago(
    Tenant t,
    String numeroRecibo,
    double escala,
    pw.TextStyle fontPequeno,
    pw.TextStyle fontTexto,
    pw.TextStyle fontSubtitulo, {
    bool compacto = false,
  }) {
    if (compacto) {
      return _bloqueMediosPagoCompact(
        t,
        numeroRecibo,
        escala,
        fontPequeno,
        fontTexto,
        fontSubtitulo,
      );
    }

    final tieneBanco =
        t.cuentaBancolombia != null && t.cuentaBancolombia!.trim().isNotEmpty;
    final tieneNequi =
        t.cuentaNequi != null && t.cuentaNequi!.trim().isNotEmpty;

    final tituloMedios = pw.TextStyle(
      fontSize: (fontSubtitulo.fontSize ?? 10) + 2 * escala,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    final hijos = <pw.Widget>[
      pw.Container(
        width: double.infinity,
        padding: pw.EdgeInsets.symmetric(
          horizontal: 10 * escala,
          vertical: 8 * escala,
        ),
        decoration: const pw.BoxDecoration(
          color: _brandDark,
          borderRadius: pw.BorderRadius.only(
            topLeft: pw.Radius.circular(5),
            topRight: pw.Radius.circular(5),
          ),
        ),
        child: pw.Center(child: pw.Text('MEDIOS DE PAGO', style: tituloMedios)),
      ),
    ];

    if (!tieneBanco && !tieneNequi) {
      hijos.add(
        pw.Padding(
          padding: pw.EdgeInsets.all(12 * escala),
          child: pw.Text(
            'Consulte en la administración del acueducto las cuentas y canales habilitados para consignar o transferir.',
            style: fontTexto,
            textAlign: pw.TextAlign.center,
          ),
        ),
      );
    } else {
      if (tieneBanco) {
        hijos.add(
          _filaMedioPago(
            etiqueta: 'Bancolombia',
            descripcion: 'Transferencia o consignación a la cuenta',
            cuenta: t.cuentaBancolombia!.trim(),
            escala: escala,
            fontPequeno: fontPequeno,
            fontTexto: fontTexto,
            acento: const PdfColor(0.86, 0.25, 0.20),
          ),
        );
      }
      if (tieneBanco && tieneNequi) {
        hijos.add(
          pw.Divider(color: PdfColors.grey400, height: 1, thickness: 0.5),
        );
      }
      if (tieneNequi) {
        hijos.add(
          _filaMedioPago(
            etiqueta: 'Nequi',
            descripcion: 'Envío desde la app — indique referencia del recibo',
            cuenta: t.cuentaNequi!.trim(),
            escala: escala,
            fontPequeno: fontPequeno,
            fontTexto: fontTexto,
            acento: const PdfColor(0.55, 0.08, 0.58),
          ),
        );
      }
      hijos.add(
        pw.Container(
          width: double.infinity,
          padding: pw.EdgeInsets.fromLTRB(
            10 * escala,
            8 * escala,
            10 * escala,
            10 * escala,
          ),
          decoration: const pw.BoxDecoration(
            color: PdfColors.amber50,
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.amber200, width: 0.75),
            ),
          ),
          child: pw.Text(
            'Importante: en el comprobante indique su número de usuario y el número de recibo $numeroRecibo para aplicar el pago sin demoras.',
            style: fontPequeno.copyWith(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey900,
              fontSize: (fontPequeno.fontSize ?? 8) + 0.5 * escala,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      );
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: _brandDark, width: 1.5),
        boxShadow: const [
          pw.BoxShadow(
            color: PdfColors.grey400,
            offset: PdfPoint(0, 2),
            blurRadius: 2,
          ),
        ],
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: hijos,
      ),
    );
  }

  static pw.Widget _filaMedioPago({
    required String etiqueta,
    required String descripcion,
    required String cuenta,
    required double escala,
    required pw.TextStyle fontPequeno,
    required pw.TextStyle fontTexto,
    required PdfColor acento,
  }) {
    final fontCuenta = pw.TextStyle(
      fontSize: (fontTexto.fontSize ?? 9) + 5 * escala,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.grey900,
      letterSpacing: 0.3,
    );

    return pw.Container(
      color: PdfColors.white,
      padding: pw.EdgeInsets.symmetric(
        horizontal: 10 * escala,
        vertical: 10 * escala,
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(width: 4, height: 52 * escala, color: acento),
          pw.SizedBox(width: 10 * escala),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  etiqueta.toUpperCase(),
                  style: fontTexto.copyWith(
                    fontWeight: pw.FontWeight.bold,
                    color: _brandDark,
                    fontSize: (fontTexto.fontSize ?? 9) + 1.5 * escala,
                  ),
                ),
                pw.SizedBox(height: 2 * escala),
                pw.Text(descripcion, style: fontPequeno),
                pw.SizedBox(height: 6 * escala),
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(
                    horizontal: 8 * escala,
                    vertical: 6 * escala,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _surface,
                    borderRadius: pw.BorderRadius.circular(3),
                    border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text('Nº / celular:  ', style: fontPequeno),
                      pw.Expanded(child: pw.Text(cuenta, style: fontCuenta)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _row(
    String label,
    String value,
    pw.TextStyle fontTexto,
    pw.TextStyle fontPequeno,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 64,
            child: pw.Text(
              label,
              style: fontPequeno.copyWith(fontWeight: pw.FontWeight.bold),
            ),
          ),
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
      border: pw.TableBorder.all(color: _brand, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _surfaceStrong),
          children: [
            for (final h in headers)
              pw.Padding(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text(
                  h,
                  style: font.copyWith(
                    fontWeight: pw.FontWeight.bold,
                    color: _brandDark,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
          ],
        ),
        pw.TableRow(
          children: [
            for (final v in values)
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  v,
                  style: font.copyWith(fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
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
          concepto: 'Facturas atrasadas',
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
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _brand),
          children: [
            _cell('Concepto', font, bold: true, light: true),
            _cell('Cant.', font, bold: true, center: true, light: true),
            _cell('Valor', font, bold: true, right: true, light: true),
          ],
        ),
        for (final row in filas)
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.white),
            children: [
              _cell(row.concepto, font),
              _cell('${row.cantidad}', font, center: true),
              _cell(formatPesos(row.valor), font, right: true),
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
    bool light = false,
  }) {
    var style = bold ? font.copyWith(fontWeight: pw.FontWeight.bold) : font;
    if (light) {
      style = style.copyWith(color: PdfColors.white);
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: pw.Text(
        text,
        style: style,
        textAlign: right
            ? pw.TextAlign.right
            : center
            ? pw.TextAlign.center
            : pw.TextAlign.left,
      ),
    );
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
