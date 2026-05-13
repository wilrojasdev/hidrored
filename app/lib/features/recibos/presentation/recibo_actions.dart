import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../domain/entities/factura.dart';
import '../data/recibo_data_loader.dart';
import '../domain/recibo_data.dart';
import '../domain/recibo_pdf_builder.dart';

/// Acciones de recibo: vista previa, imprimir, compartir, abrir WhatsApp.
class ReciboActions {
  const ReciboActions._();

  /// Abre el dialogo nativo de impresion / vista previa.
  static Future<void> imprimirIndividual(
    BuildContext context,
    WidgetRef ref,
    Factura factura,
  ) async {
    final loader = await ref.read(reciboDataLoaderProvider.future);
    final data = await loader.cargarUno(factura);
    final bytes = await ReciboPdfBuilder.buildIndividual(data);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'recibo-${factura.numero}.pdf',
    );
  }

  /// Comparte el PDF (abre share sheet con WhatsApp/email/etc).
  static Future<void> compartirIndividual(
    BuildContext context,
    WidgetRef ref,
    Factura factura,
  ) async {
    final loader = await ref.read(reciboDataLoaderProvider.future);
    final data = await loader.cargarUno(factura);
    final bytes = await ReciboPdfBuilder.buildIndividual(data);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'recibo-${factura.numero}.pdf',
    );
  }

  /// Abre WhatsApp con un mensaje pre-redactado al telefono del cliente.
  /// El admin debe adjuntar el PDF manualmente (limitacion de wa.me).
  static Future<void> mensajeWhatsApp(
    BuildContext context,
    WidgetRef ref,
    Factura factura,
  ) async {
    final loader = await ref.read(reciboDataLoaderProvider.future);
    final data = await loader.cargarUno(factura);
    final telE164 = _normalizarTelefonoColombia(data.cliente.telefono);
    if (telE164 == null) {
      if (!context.mounted) return;
      final telOriginal = data.cliente.telefono;
      AppSnackbar.info(
        context,
        telOriginal == null || telOriginal.isEmpty
            ? 'Este cliente no tiene teléfono registrado.'
            : 'El teléfono del cliente no es válido para WhatsApp.',
      );
      return;
    }
    final mensaje = _mensajeRecibo(data);
    final url = Uri.parse(
      'https://wa.me/$telE164?text=${Uri.encodeComponent(mensaje)}',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      AppSnackbar.errorMessage(context, 'No se pudo abrir WhatsApp');
    }
  }

  /// Normaliza un teléfono colombiano a formato E.164 (`573xxxxxxxxx`).
  /// Devuelve `null` si el número no es válido para uso con wa.me.
  ///
  /// Reglas:
  /// - 10 dígitos empezando con 3 (móvil) → se antepone 57.
  /// - 12 dígitos empezando con 573 (ya con indicativo) → se usa tal cual.
  /// - Cualquier otro patrón → null (fijos, internacionales raros, basura).
  static String? _normalizarTelefonoColombia(String? telefono) {
    if (telefono == null) return null;
    final limpio = telefono.replaceAll(RegExp(r'[^0-9]'), '');
    if (limpio.length == 10 && limpio.startsWith('3')) {
      return '57$limpio';
    }
    if (limpio.length == 12 && limpio.startsWith('573')) {
      return limpio;
    }
    return null;
  }

  /// Imprime / previsualiza un PDF con todos los recibos del lote (4 por hoja).
  static Future<void> imprimirLote(
    BuildContext context,
    WidgetRef ref,
    List<Factura> facturas,
  ) async {
    if (facturas.isEmpty) return;
    final loader = await ref.read(reciboDataLoaderProvider.future);
    final datos = await loader.cargarLote(facturas);
    final bytes = await ReciboPdfBuilder.buildLote(datos);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'recibos-lote.pdf',
    );
  }

  /// Comparte el PDF del lote.
  static Future<void> compartirLote(
    BuildContext context,
    WidgetRef ref,
    List<Factura> facturas,
  ) async {
    if (facturas.isEmpty) return;
    final loader = await ref.read(reciboDataLoaderProvider.future);
    final datos = await loader.cargarLote(facturas);
    final bytes = await ReciboPdfBuilder.buildLote(datos);
    await Printing.sharePdf(bytes: bytes, filename: 'recibos-lote.pdf');
  }

  static String _mensajeRecibo(ReciboData d) {
    final saludo = d.cliente.nombre.split(' ').first;
    final periodoFmt = formatPeriodo(d.factura.periodo);
    final venceFmt = formatFecha(d.factura.fechaVencimiento);
    final total = formatPesos(d.totalReciboCobrar);
    return 'Hola $saludo, tu recibo de ${d.tenant.nombre} '
        'correspondiente a $periodoFmt está listo.\n\n'
        'Total a pagar: $total\n'
        'Vence: $venceFmt\n'
        'Recibo Nº: ${d.factura.numero}\n\n'
        'Puedes pagar en Bancolombia ${d.tenant.cuentaBancolombia ?? ''} '
        'o Nequi ${d.tenant.cuentaNequi ?? ''}. Gracias.';
  }
}
