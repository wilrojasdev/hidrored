import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/conceptos/presentation/concepto_form_screen.dart';
import '../../features/conceptos/presentation/conceptos_list_screen.dart';
import '../../features/configuracion/presentation/configuracion_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/importador/presentation/importador_screen.dart';
import '../../features/facturacion/presentation/factura_detalle_screen.dart';
import '../../features/facturacion/presentation/facturas_list_screen.dart';
import '../../features/facturacion/presentation/generar_factura_individual_screen.dart';
import '../../features/facturacion/presentation/generar_facturacion_screen.dart';
import '../../features/pagos/presentation/pago_detalle_screen.dart';
import '../../features/pagos/presentation/pagos_list_screen.dart';
import '../../features/pagos/presentation/registrar_pago_screen.dart';
import '../../features/reportes/presentation/reportes_screen.dart';
import '../../features/servicio/presentation/bitacora_cliente_screen.dart';
import '../../features/servicio/presentation/dano_form_screen.dart';
import '../../features/servicio/presentation/servicio_screen.dart';
import '../../features/shell/shell_scaffold.dart';
import '../../features/clientes/presentation/cliente_form_screen.dart';
import '../../features/clientes/presentation/clientes_list_screen.dart';

final _rootNavKey = GlobalKey<NavigatorState>();
final _shellNavKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) {
      final isAuth = ref.read(isAuthenticatedProvider);
      final loggingIn = state.matchedLocation == '/login';
      if (!isAuth && !loggingIn) return '/login';
      if (isAuth && loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavKey,
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/clientes',
            name: 'clientes',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ClientesListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'nuevo',
                name: 'cliente-nuevo',
                builder: (_, _) => const ClienteFormScreen(),
              ),
              GoRoute(
                path: 'importar',
                name: 'cliente-importar',
                builder: (_, _) => const ImportadorScreen(),
              ),
              GoRoute(
                path: ':id/editar',
                name: 'cliente-editar',
                builder: (_, state) =>
                    ClienteFormScreen(id: state.pathParameters['id']),
              ),
            ],
          ),
          GoRoute(
            path: '/facturas',
            name: 'facturas',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const FacturasListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'generar',
                name: 'facturas-generar',
                builder: (_, _) => const GenerarFacturacionScreen(),
              ),
              GoRoute(
                path: 'individual/:clienteId',
                name: 'factura-individual',
                builder: (_, state) => GenerarFacturaIndividualScreen(
                  clienteId: state.pathParameters['clienteId']!,
                  periodoInicial: state.uri.queryParameters['periodo'],
                ),
              ),
              GoRoute(
                path: ':id',
                name: 'factura-detalle',
                builder: (_, state) =>
                    FacturaDetalleScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/pagos',
            name: 'pagos',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PagosListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'nuevo',
                name: 'pago-nuevo',
                builder: (_, _) => const RegistrarPagoScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'pago-detalle',
                builder: (_, state) =>
                    PagoDetalleScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/conceptos',
            name: 'conceptos',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ConceptosListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'nuevo',
                name: 'concepto-nuevo',
                builder: (_, _) => const ConceptoFormScreen(),
              ),
              GoRoute(
                path: ':id/editar',
                name: 'concepto-editar',
                builder: (_, state) =>
                    ConceptoFormScreen(id: state.pathParameters['id']),
              ),
            ],
          ),
          GoRoute(
            path: '/servicio',
            name: 'servicio',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ServicioScreen(),
            ),
            routes: [
              GoRoute(
                path: 'danos/nuevo',
                name: 'dano-nuevo',
                builder: (_, _) => const DanoFormScreen(),
              ),
              GoRoute(
                path: 'danos/:id/editar',
                name: 'dano-editar',
                builder: (_, state) =>
                    DanoFormScreen(id: state.pathParameters['id']),
              ),
              GoRoute(
                path: 'bitacora/:id',
                name: 'bitacora-cliente',
                builder: (_, state) => BitacoraClienteScreen(
                  clienteId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/reportes',
            name: 'reportes',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ReportesScreen(),
            ),
          ),
          GoRoute(
            path: '/configuracion',
            name: 'configuracion',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ConfiguracionScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _ref.listen(isAuthenticatedProvider, (_, _) => notifyListeners());
  }
  final Ref _ref;
}
