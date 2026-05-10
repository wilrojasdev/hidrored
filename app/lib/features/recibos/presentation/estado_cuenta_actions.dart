import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../data/estado_cuenta_loader.dart';
import '../domain/estado_cuenta_pdf_builder.dart';

class EstadoCuentaActions {
  const EstadoCuentaActions._();

  /// Vista previa / impresion del estado de cuenta del cliente.
  static Future<void> imprimir(
    BuildContext context,
    WidgetRef ref,
    String clienteId,
  ) async {
    final loader = await ref.read(estadoCuentaLoaderProvider.future);
    final data = await loader.cargar(clienteId);
    final bytes = await EstadoCuentaPdfBuilder.build(data);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'estado-cuenta-${data.cliente.codigo}.pdf',
    );
  }

  /// Comparte el PDF (sheet nativo).
  static Future<void> compartir(
    BuildContext context,
    WidgetRef ref,
    String clienteId,
  ) async {
    final loader = await ref.read(estadoCuentaLoaderProvider.future);
    final data = await loader.cargar(clienteId);
    final bytes = await EstadoCuentaPdfBuilder.build(data);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'estado-cuenta-${data.cliente.codigo}.pdf',
    );
  }
}
