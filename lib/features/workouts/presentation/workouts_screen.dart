import 'package:flutter/material.dart';

import 'treino_catalog_screen.dart';

/// Rota principal de treinos — delega ao catálogo oficial (117 exercícios).
class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) => const TreinoCatalogScreen();
}
