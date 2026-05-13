// Enums del dominio. El campo `value` corresponde al string almacenado
// en Postgres (debe coincidir con los CHECK constraints de la migracion).

enum EstadoCliente {
  activo('activo'),
  suspendidoMora('suspendido_mora'),
  suspendidoVoluntario('suspendido_voluntario'),
  danoReportado('dano_reportado'),
  enReparacion('en_reparacion'),
  retirado('retirado');

  const EstadoCliente(this.value);
  final String value;

  static EstadoCliente fromValue(String value) =>
      EstadoCliente.values.firstWhere((e) => e.value == value);

  String get label => switch (this) {
    EstadoCliente.activo => 'Activo',
    EstadoCliente.suspendidoMora => 'Suspendido por mora',
    EstadoCliente.suspendidoVoluntario => 'Suspendido voluntario',
    EstadoCliente.danoReportado => 'Daño reportado',
    EstadoCliente.enReparacion => 'En reparación',
    EstadoCliente.retirado => 'Retirado',
  };

  /// Si el cliente tiene servicio activo o no.
  bool get tieneServicio => this == EstadoCliente.activo;
}

enum TipoFactura {
  mensual('mensual'),
  recordatorioSuspension('recordatorio_suspension');

  const TipoFactura(this.value);
  final String value;

  static TipoFactura fromValue(String value) =>
      TipoFactura.values.firstWhere((e) => e.value == value);

  String get label => switch (this) {
    TipoFactura.mensual => 'Mensual',
    TipoFactura.recordatorioSuspension => 'Recordatorio de suspensión',
  };
}

enum EstadoFactura {
  pendiente('pendiente'),
  pagada('pagada'),
  anulada('anulada'),
  refacturada('refacturada');

  const EstadoFactura(this.value);
  final String value;

  static EstadoFactura fromValue(String value) =>
      EstadoFactura.values.firstWhere((e) => e.value == value);

  String get label => switch (this) {
    EstadoFactura.pendiente => 'Pendiente',
    EstadoFactura.pagada => 'Pagada',
    EstadoFactura.anulada => 'Anulada',
    EstadoFactura.refacturada => 'Refacturada',
  };
}

enum MetodoPago {
  bancolombia('bancolombia'),
  nequi('nequi'),
  efectivo('efectivo'),
  otro('otro');

  const MetodoPago(this.value);
  final String value;

  static MetodoPago fromValue(String value) =>
      MetodoPago.values.firstWhere((e) => e.value == value);

  String get label => switch (this) {
    MetodoPago.bancolombia => 'Bancolombia',
    MetodoPago.nequi => 'Nequi',
    MetodoPago.efectivo => 'Efectivo',
    MetodoPago.otro => 'Otro',
  };
}

enum TipoEventoServicio {
  activacion('activacion'),
  suspension('suspension'),
  reconexion('reconexion'),
  reporteDano('reporte_dano'),
  inicioReparacion('inicio_reparacion'),
  finReparacion('fin_reparacion'),
  retiro('retiro'),
  cambioEstado('cambio_estado');

  const TipoEventoServicio(this.value);
  final String value;

  static TipoEventoServicio fromValue(String value) =>
      TipoEventoServicio.values.firstWhere((e) => e.value == value);
}

enum EstadoDano {
  reportado('reportado'),
  enReparacion('en_reparacion'),
  solucionado('solucionado');

  const EstadoDano(this.value);
  final String value;

  static EstadoDano fromValue(String value) =>
      EstadoDano.values.firstWhere((e) => e.value == value);

  String get label => switch (this) {
    EstadoDano.reportado => 'Reportado',
    EstadoDano.enReparacion => 'En reparación',
    EstadoDano.solucionado => 'Solucionado',
  };
}
