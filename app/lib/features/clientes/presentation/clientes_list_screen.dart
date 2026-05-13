import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/formato.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_async_value.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/status_mappers.dart';
import '../../../domain/entities/cliente.dart';
import 'clientes_controller.dart';

class ClientesListScreen extends ConsumerStatefulWidget {
  const ClientesListScreen({super.key});

  @override
  ConsumerState<ClientesListScreen> createState() => _ClientesListScreenState();
}

class _ClientesListScreenState extends ConsumerState<ClientesListScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(AppDurations.searchDebounce, () {
      ref.read(clientesSearchProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncList = ref.watch(clientesListProvider);
    final isMobile =
        MediaQuery.sizeOf(context).width < AppSizes.mobileBreakpoint;

    return Padding(
      padding: isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(isMobile: isMobile, theme: theme),
          AppSpacing.gapLg,
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, cédula o dirección',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpiar búsqueda',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchCtrl.clear();
                        _onSearchChanged('');
                        setState(() {});
                      },
                    ),
            ),
          ),
          AppSpacing.gapLg,
          Expanded(
            child: AsyncValueWidget<List<Cliente>>(
              value: asyncList,
              onRetry: () => ref.invalidate(clientesListProvider),
              loading: const _ClientesSkeleton(),
              data: (lista) {
                if (lista.isEmpty) {
                  if (_searchCtrl.text.isNotEmpty) {
                    return AppEmptyState(
                      icon: Icons.search_off,
                      titulo: 'Sin resultados',
                      descripcion:
                          'No encontramos clientes que coincidan con "${_searchCtrl.text}".',
                      acciones: [
                        OutlinedButton.icon(
                          onPressed: () {
                            _searchCtrl.clear();
                            _onSearchChanged('');
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpiar búsqueda'),
                        ),
                      ],
                    );
                  }
                  return AppEmptyState(
                    icon: Icons.people_outline,
                    titulo: 'Sin clientes aún',
                    descripcion:
                        'Importa tu lista desde Excel o crea el primer cliente manualmente.',
                    acciones: [
                      FilledButton.icon(
                        onPressed: () => context.go('/clientes/importar'),
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Importar Excel'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/clientes/nuevo'),
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo cliente'),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          Text(
                            pluralES(lista.length, 'cliente', 'clientes'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(clientesListProvider);
                          await ref.read(clientesListProvider.future);
                        },
                        child: ListView.separated(
                          itemCount: lista.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, i) =>
                              _ClienteTile(cliente: lista[i]),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isMobile, required this.theme});
  final bool isMobile;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clientes', style: theme.textTheme.headlineSmall),
          AppSpacing.gapSm,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go('/clientes/importar'),
                icon: const Icon(Icons.upload_file),
                label: const Text('Importar'),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/clientes/nuevo'),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo'),
              ),
            ],
          ),
        ],
      );
    }
    return Row(
      children: [
        Text('Clientes', style: theme.textTheme.headlineMedium),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () => context.go('/clientes/importar'),
          icon: const Icon(Icons.upload_file),
          label: const Text('Importar Excel'),
        ),
        AppSpacing.gapMd,
        FilledButton.icon(
          onPressed: () => context.go('/clientes/nuevo'),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo cliente'),
        ),
      ],
    );
  }
}

class _ClientesSkeleton extends StatelessWidget {
  const _ClientesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 8,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, _) => const ListTileSkeleton(),
    );
  }
}

class _ClienteTile extends StatelessWidget {
  const _ClienteTile({required this.cliente});
  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile =
        MediaQuery.sizeOf(context).width < AppSizes.mobileBreakpoint;
    final subtitle = [
      formatCedula(cliente.cedula),
      if (cliente.direccion != null && cliente.direccion!.isNotEmpty)
        cliente.direccion,
      if (cliente.telefono != null && cliente.telefono!.isNotEmpty)
        formatTelefono(cliente.telefono!),
    ].whereType<String>().join(' · ');

    return Semantics(
      button: true,
      label:
          '${cliente.nombre}, código ${cliente.codigo}, '
          'estado ${cliente.estado.label}, '
          'tarifa ${formatPesos(cliente.tarifaMensual)}',
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            '${cliente.codigo}',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                cliente.nombre,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isMobile) ...[
              AppSpacing.gapSm,
              StatusChip(
                label: cliente.estado.label,
                variant: cliente.estado.variant,
                compact: true,
              ),
            ],
          ],
        ),
        subtitle: isMobile
            ? Text.rich(
                TextSpan(
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(text: subtitle),
                    const TextSpan(text: '\n'),
                    TextSpan(
                      text: '${formatPesos(cliente.tarifaMensual)} / mes',
                      style: AppListTypography.monto(
                        theme,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              )
            : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        isThreeLine: isMobile,
        trailing: isMobile
            ? const Icon(Icons.chevron_right)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusChip(
                    label: cliente.estado.label,
                    variant: cliente.estado.variant,
                  ),
                  AppSpacing.gapMd,
                  Text(
                    formatPesos(cliente.tarifaMensual),
                    style: AppListTypography.monto(
                      theme,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  AppSpacing.gapSm,
                  const Icon(Icons.chevron_right),
                ],
              ),
        onTap: () => context.go('/clientes/${cliente.id}/editar'),
      ),
    );
  }
}
