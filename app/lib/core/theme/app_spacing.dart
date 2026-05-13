import 'package:flutter/material.dart';

/// Tokens de espaciado consistentes en toda la app.
/// Escala 4px: xs=4, sm=8, md=12, lg=16, xl=20, xxl=24, xxxl=32.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static const EdgeInsets pagePadding = EdgeInsets.all(xxl);
  static const EdgeInsets pagePaddingMobile = EdgeInsets.all(lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(xl);

  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);
  static const SizedBox gapXxl = SizedBox(width: xxl, height: xxl);
}

/// Mínimos de accesibilidad: tap targets, ancho de bordes, etc.
class AppSizes {
  const AppSizes._();

  /// Tap target mínimo Material/WCAG (48dp).
  static const double minTapTarget = 48;

  /// Radio de bordes consistente.
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusPill = 999;

  /// Anchos máximos para forms y contenido en pantallas grandes.
  static const double formMaxWidth = 720;
  static const double formNarrowMaxWidth = 600;
  static const double dialogMaxWidth = 480;

  /// Breakpoints de layout.
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}

class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 360);
  static const Duration searchDebounce = Duration(milliseconds: 300);
}

/// Tipografía destacada para montos en filas de listas (pagos, facturas,
/// tarifas en clientes).
class AppListTypography {
  const AppListTypography._();

  static TextStyle monto(ThemeData theme, {Color? color}) {
    final base =
        theme.textTheme.titleLarge ?? theme.textTheme.titleMedium ?? const TextStyle();
    return base.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      height: 1.15,
      color: color,
    );
  }
}
