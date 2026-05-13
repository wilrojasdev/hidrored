import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Logo por defecto del tenant (mismo asset que recibos PDF).
/// Si falla la carga, muestra el icono de marca.
class TenantLogo extends StatelessWidget {
  const TenantLogo({super.key, required this.size, this.borderRadius});

  final double size;
  final BorderRadius? borderRadius;

  static const assetPath = 'assets/images/tenant_default_logo.png';

  @override
  Widget build(BuildContext context) {
    final r = borderRadius ?? BorderRadius.circular(AppSizes.radiusSm);
    return ClipRRect(
      borderRadius: r,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _Fallback(size: size, borderRadius: r),
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.size, required this.borderRadius});

  final double size;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppGradients.header(context),
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.water_drop,
        color: theme.colorScheme.onPrimary,
        size: size * 0.55,
        semanticLabel: 'Logo',
      ),
    );
  }
}
