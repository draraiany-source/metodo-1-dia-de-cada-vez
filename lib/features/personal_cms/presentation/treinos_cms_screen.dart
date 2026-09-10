import 'package:flutter/material.dart';

import '../../admin/presentation/admin_treinos_catalog_tab.dart';

/// Empacota o catálogo de treinos já existente numa tela própria do CMS.
class TreinosCmsScreen extends StatelessWidget {
  const TreinosCmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Treinos')),
      body: const AdminTreinosCatalogTab(),
    );
  }
}
