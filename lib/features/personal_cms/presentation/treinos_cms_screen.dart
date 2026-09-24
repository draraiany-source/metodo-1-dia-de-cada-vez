import 'package:flutter/material.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../admin/presentation/admin_treinos_catalog_tab.dart';

/// Empacota o catálogo de treinos já existente numa tela própria do CMS.
class TreinosCmsScreen extends StatelessWidget {
  const TreinosCmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: PremiumAppBar(
        title: 'Treinos',
        showStaffSignOut: true,
      ),
      body: AdminTreinosCatalogTab(),
    );
  }
}
