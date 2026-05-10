import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/connectivity/connectivity_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/offline_banner.dart';
import '../auth/presentation/auth_controller.dart';
import 'nav_destinations.dart';

/// Layout principal post-login.
/// - Pantallas anchas (>= 800dp): NavigationRail a la izquierda con todos los
///   destinos siempre visibles.
/// - Pantallas angostas: AppBar + Drawer con todos los destinos + bottom nav
///   con los 4 más usados (Dashboard, Clientes, Facturación, Pagos) y un
///   ítem "Más" que abre el drawer.
class ShellScaffold extends ConsumerWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  static const _bottomItems = 4;

  int _selectedIndex(String location) {
    final index = navDestinations.indexWhere(
      (d) => d.route == '/' ? location == '/' : location.startsWith(d.route),
    );
    return index < 0 ? 0 : index;
  }

  void _onSelect(BuildContext context, int index) {
    context.go(navDestinations[index].route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final selected = _selectedIndex(location);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AppSizes.tabletBreakpoint;
    final perfil = ref.watch(perfilProvider).valueOrNull;
    final isOffline = ref.watch(isOfflineProvider);
    final theme = Theme.of(context);

    if (isWide) {
      final extended = width >= AppSizes.desktopBreakpoint;
      return Scaffold(
        body: Row(
          children: [
            _SideRail(
              extended: extended,
              selected: selected,
              onSelect: (i) => _onSelect(context, i),
              onSignOut: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            ),
            Container(width: 1, color: theme.colorScheme.outlineVariant),
            Expanded(
              child: Column(
                children: [
                  if (perfil != null)
                    _TopBar(
                      perfilNombre: perfil.nombre,
                      tenantId: perfil.tenantId,
                      moduloLabel: navDestinations[selected].label,
                    ),
                  if (isOffline) const OfflineBanner(),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _MobileShell(
      selected: selected,
      perfilNombre: perfil?.nombre,
      isOffline: isOffline,
      onSelect: (i) => _onSelect(context, i),
      onSignOut: () => ref.read(authControllerProvider.notifier).signOut(),
      child: child,
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.extended,
    required this.selected,
    required this.onSelect,
    required this.onSignOut,
  });

  final bool extended;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: extended ? 220 : 88,
      child: Material(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            _Brand(extended: extended),
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: [
                  for (var i = 0; i < navDestinations.length; i++)
                    _RailTile(
                      item: navDestinations[i],
                      selected: i == selected,
                      extended: extended,
                      onTap: () => onSelect(i),
                    ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: extended
                  ? OutlinedButton.icon(
                      onPressed: onSignOut,
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Cerrar sesión'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Cerrar sesión',
                      onPressed: onSignOut,
                      icon: const Icon(Icons.logout),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logo = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppGradients.header(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.water_drop,
        color: theme.colorScheme.onPrimary,
        size: 22,
        semanticLabel: 'Hidrored',
      ),
    );
    if (!extended) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: logo,
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          logo,
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hidrored',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Acueducto veredal',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RailTile extends StatelessWidget {
  const _RailTile({
    required this.item,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedBg = theme.colorScheme.primaryContainer;
    final selectedFg = theme.colorScheme.onPrimaryContainer;
    final unselectedFg = theme.colorScheme.onSurfaceVariant;

    final icon = Icon(
      selected ? item.selectedIcon : item.icon,
      size: 22,
      color: selected ? selectedFg : unselectedFg,
      semanticLabel: item.label,
    );

    final content = extended
        ? Row(
            children: [
              icon,
              AppSpacing.gapMd,
              Expanded(
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected ? selectedFg : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 4),
              Text(
                item.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? selectedFg : unselectedFg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      child: Material(
        color: selected ? selectedBg : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            padding: extended
                ? const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  )
                : const EdgeInsets.symmetric(vertical: AppSpacing.md),
            constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _MobileShell extends StatefulWidget {
  const _MobileShell({
    required this.selected,
    required this.perfilNombre,
    required this.isOffline,
    required this.onSelect,
    required this.onSignOut,
    required this.child,
  });

  final int selected;
  final String? perfilNombre;
  final bool isOffline;
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;
  final Widget child;

  @override
  State<_MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<_MobileShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const bottomItems = ShellScaffold._bottomItems;
    final bottomDestinations = navDestinations.take(bottomItems).toList();
    final isInBottom = widget.selected < bottomItems;
    final selectedLabel = navDestinations[widget.selected].label;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Menú',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            if (isInBottom) ...[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: AppGradients.header(context),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.water_drop,
                  color: theme.colorScheme.onPrimary,
                  size: 16,
                ),
              ),
              AppSpacing.gapSm,
              const Text('Hidrored'),
            ] else
              Text(selectedLabel),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: widget.onSignOut,
          ),
          AppSpacing.gapSm,
        ],
      ),
      drawer: _AppDrawer(
        selectedIndex: widget.selected,
        perfilNombre: widget.perfilNombre,
        onSelect: (i) {
          Navigator.of(context).pop();
          widget.onSelect(i);
        },
        onSignOut: () {
          Navigator.of(context).pop();
          widget.onSignOut();
        },
      ),
      body: Column(
        children: [
          if (widget.isOffline) const OfflineBanner(),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: isInBottom ? widget.selected : bottomItems,
          onDestinationSelected: (i) {
            if (i == bottomItems) {
              _scaffoldKey.currentState?.openDrawer();
            } else {
              widget.onSelect(i);
            }
          },
          destinations: [
            for (final d in bottomDestinations)
              NavigationDestination(
                icon: Icon(d.icon, semanticLabel: d.label),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            const NavigationDestination(
              icon: Icon(Icons.menu, semanticLabel: 'Más opciones'),
              selectedIcon: Icon(Icons.menu_open),
              label: 'Más',
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.selectedIndex,
    required this.onSelect,
    required this.onSignOut,
    this.perfilNombre,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;
  final String? perfilNombre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(gradient: AppGradients.header(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary.withValues(
                        alpha: 0.18,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.water_drop,
                      color: theme.colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  AppSpacing.gapMd,
                  Text(
                    'Hidrored',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (perfilNombre != null)
                    Text(
                      perfilNombre!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.85,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.sm,
                ),
                children: [
                  for (var i = 0; i < navDestinations.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: ListTile(
                        leading: Icon(
                          i == selectedIndex
                              ? navDestinations[i].selectedIcon
                              : navDestinations[i].icon,
                        ),
                        title: Text(navDestinations[i].label),
                        selected: i == selectedIndex,
                        onTap: () => onSelect(i),
                      ),
                    ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: onSignOut,
            ),
            AppSpacing.gapSm,
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.perfilNombre,
    required this.tenantId,
    required this.moduloLabel,
  });

  final String perfilNombre;
  final String tenantId;
  final String moduloLabel;

  String get _iniciales {
    final partes = perfilNombre.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) return partes.first.characters.first.toUpperCase();
    return (partes.first.characters.first + partes[1].characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            moduloLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    _iniciales,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppSpacing.gapSm,
                Text(
                  perfilNombre,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
