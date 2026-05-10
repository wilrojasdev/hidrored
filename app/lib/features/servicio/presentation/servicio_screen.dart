import 'package:flutter/material.dart';

import 'tabs/bitacora_tab.dart';
import 'tabs/danos_tab.dart';
import 'tabs/estados_tab.dart';
import 'tabs/lista_corte_tab.dart';

class ServicioScreen extends StatelessWidget {
  const ServicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Servicio y daños', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(icon: Icon(Icons.toggle_on_outlined), text: 'Estados'),
                Tab(icon: Icon(Icons.cut_outlined), text: 'Lista de corte'),
                Tab(icon: Icon(Icons.build_outlined), text: 'Daños'),
                Tab(icon: Icon(Icons.history), text: 'Bitácora'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  EstadosTab(),
                  ListaCorteTab(),
                  DanosTab(),
                  BitacoraTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
