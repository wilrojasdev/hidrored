import 'package:flutter/material.dart';

class NavItem {
  const NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}

const navDestinations = <NavItem>[
  NavItem(
    label: 'Pagos',
    icon: Icons.payments_outlined,
    selectedIcon: Icons.payments,
    route: '/pagos',
  ),
  NavItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    route: '/',
  ),
  NavItem(
    label: 'Clientes',
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
    route: '/clientes',
  ),
  NavItem(
    label: 'Facturación',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
    route: '/facturas',
  ),
  NavItem(
    label: 'Conceptos',
    icon: Icons.list_alt_outlined,
    selectedIcon: Icons.list_alt,
    route: '/conceptos',
  ),
  NavItem(
    label: 'Servicio',
    icon: Icons.build_outlined,
    selectedIcon: Icons.build,
    route: '/servicio',
  ),
  NavItem(
    label: 'Reportes',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
    route: '/reportes',
  ),
  NavItem(
    label: 'Configuración',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    route: '/configuracion',
  ),
];
