import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firebase_service.dart';
import '../domain/food_database_models.dart';

/// Banco de alimentos — Firestore (`food_database`), com fallback pra um
/// conjunto inicial local quando o Firebase não está configurado (mesmo
/// padrão de graceful-degradation do resto do app).
///
/// **Honestidade sobre escala**: isto começa com ~30 alimentos comuns, não
/// "milhares" — é uma estrutura real e funcional, expansível pelo painel
/// admin ou por importação em lote futura (CSV/planilha), não um banco de
/// dados nutricional completo pronto (isso normalmente vem de uma base
/// licenciada, tipo TACO/USDA).
class FoodDatabaseRepository {
  bool get isAvailable => FirebaseService.isReady;

  Future<List<FoodItem>> fetchAll() async {
    if (!isAvailable) return _seedLocal;
    try {
      final snap =
          await FirebaseFirestore.instance.collection('food_database').get();
      if (snap.docs.isEmpty) return _seedLocal;
      return snap.docs.map((d) => FoodItem.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return _seedLocal;
    }
  }

  Future<void> create(FoodItem item) async {
    if (!isAvailable) return;
    final col = FirebaseFirestore.instance.collection('food_database');
    await (item.id.isEmpty ? col.doc() : col.doc(item.id)).set(item.toMap());
  }

  Future<void> delete(String id) async {
    if (!isAvailable) return;
    await FirebaseFirestore.instance
        .collection('food_database')
        .doc(id)
        .delete();
  }

  /// Conjunto inicial — alimentos comuns na dieta brasileira, valores
  /// aproximados por 100g (fonte: referências nutricionais públicas usuais).
  static final List<FoodItem> _seedLocal = [
    const FoodItem(id: 'arroz_branco', name: 'Arroz branco cozido', category: FoodCategory.graosECereais, kcal: 128, protein: 2, carbs: 28, fat: 0, householdMeasure: '4 colheres de sopa (100g)'),
    const FoodItem(id: 'feijao_carioca', name: 'Feijão carioca cozido', category: FoodCategory.graosECereais, kcal: 76, protein: 5, carbs: 14, fat: 0, fiber: 8, householdMeasure: '1 concha (100g)'),
    const FoodItem(id: 'frango_grelhado', name: 'Peito de frango grelhado', category: FoodCategory.frango, kcal: 159, protein: 32, carbs: 0, fat: 3, householdMeasure: '1 filé médio (100g)'),
    const FoodItem(id: 'ovo_cozido', name: 'Ovo cozido', category: FoodCategory.ovos, kcal: 155, protein: 13, carbs: 1, fat: 11, householdMeasure: '2 unidades (100g)'),
    const FoodItem(id: 'banana', name: 'Banana', category: FoodCategory.frutas, kcal: 89, protein: 1, carbs: 23, fat: 0, fiber: 3, householdMeasure: '1 unidade média (100g)'),
    const FoodItem(id: 'maca', name: 'Maçã', category: FoodCategory.frutas, kcal: 52, protein: 0, carbs: 14, fat: 0, fiber: 2, householdMeasure: '1 unidade média (100g)'),
    const FoodItem(id: 'batata_doce', name: 'Batata doce cozida', category: FoodCategory.legumes, kcal: 86, protein: 2, carbs: 20, fat: 0, fiber: 3, householdMeasure: '1 unidade média (100g)'),
    const FoodItem(id: 'brocolis', name: 'Brócolis cozido', category: FoodCategory.verduras, kcal: 35, protein: 2, carbs: 7, fat: 0, fiber: 3, householdMeasure: '1 xícara (100g)'),
    const FoodItem(id: 'alface', name: 'Alface', category: FoodCategory.verduras, kcal: 15, protein: 1, carbs: 3, fat: 0, fiber: 1, householdMeasure: '2 folhas (30g)'),
    const FoodItem(id: 'tomate', name: 'Tomate', category: FoodCategory.legumes, kcal: 18, protein: 1, carbs: 4, fat: 0, fiber: 1, householdMeasure: '1 unidade média (100g)'),
    const FoodItem(id: 'salmao', name: 'Salmão grelhado', category: FoodCategory.peixes, kcal: 208, protein: 20, carbs: 0, fat: 13, householdMeasure: '1 filé (100g)'),
    const FoodItem(id: 'tilapia', name: 'Tilápia grelhada', category: FoodCategory.peixes, kcal: 128, protein: 26, carbs: 0, fat: 3, householdMeasure: '1 filé (100g)'),
    const FoodItem(id: 'carne_bovina_magra', name: 'Carne bovina magra grelhada', category: FoodCategory.carnes, kcal: 219, protein: 26, carbs: 0, fat: 12, householdMeasure: '1 bife (100g)'),
    const FoodItem(id: 'leite_desnatado', name: 'Leite desnatado', category: FoodCategory.laticinios, kcal: 35, protein: 3, carbs: 5, fat: 0, householdMeasure: '1 copo (200ml)', gramWeight: 200),
    const FoodItem(id: 'iogurte_natural', name: 'Iogurte natural', category: FoodCategory.laticinios, kcal: 61, protein: 3, carbs: 5, fat: 3, householdMeasure: '1 pote (100g)'),
    const FoodItem(id: 'queijo_minas', name: 'Queijo minas frescal', category: FoodCategory.laticinios, kcal: 264, protein: 17, carbs: 3, fat: 20, householdMeasure: '1 fatia (30g)'),
    const FoodItem(id: 'aveia', name: 'Aveia em flocos', category: FoodCategory.graosECereais, kcal: 389, protein: 17, carbs: 66, fat: 7, fiber: 10, householdMeasure: '3 colheres de sopa (30g)'),
    const FoodItem(id: 'pao_integral', name: 'Pão integral', category: FoodCategory.graosECereais, kcal: 247, protein: 13, carbs: 41, fat: 4, fiber: 7, householdMeasure: '1 fatia (25g)'),
    const FoodItem(id: 'azeite', name: 'Azeite de oliva', category: FoodCategory.industrializados, kcal: 884, protein: 0, carbs: 0, fat: 100, householdMeasure: '1 colher de sopa (13g)'),
    const FoodItem(id: 'abacate', name: 'Abacate', category: FoodCategory.frutas, kcal: 160, protein: 2, carbs: 9, fat: 15, fiber: 7, householdMeasure: '1/2 unidade (100g)'),
    const FoodItem(id: 'agua', name: 'Água', category: FoodCategory.bebidas, kcal: 0, protein: 0, carbs: 0, fat: 0, householdMeasure: '1 copo (200ml)', gramWeight: 200),
    const FoodItem(id: 'refrigerante', name: 'Refrigerante comum', category: FoodCategory.bebidas, kcal: 42, protein: 0, carbs: 11, fat: 0, sugar: 11, householdMeasure: '1 copo (200ml)', gramWeight: 200),
    const FoodItem(id: 'suco_laranja', name: 'Suco de laranja natural', category: FoodCategory.bebidas, kcal: 45, protein: 1, carbs: 10, fat: 0, householdMeasure: '1 copo (200ml)', gramWeight: 200),
    const FoodItem(id: 'batata_frita', name: 'Batata frita (fast-food)', category: FoodCategory.fastFood, kcal: 312, protein: 3, carbs: 41, fat: 15, householdMeasure: 'porção média (100g)'),
    const FoodItem(id: 'hamburguer', name: 'Hambúrguer (fast-food)', category: FoodCategory.fastFood, kcal: 295, protein: 17, carbs: 24, fat: 14, householdMeasure: '1 unidade (150g)', gramWeight: 150),
    const FoodItem(id: 'chocolate', name: 'Chocolate ao leite', category: FoodCategory.doces, kcal: 545, protein: 8, carbs: 59, fat: 31, sugar: 51, householdMeasure: '1 barra (25g)'),
    const FoodItem(id: 'whey_protein', name: 'Whey protein (pó)', category: FoodCategory.suplementos, kcal: 400, protein: 80, carbs: 8, fat: 5, householdMeasure: '1 scoop (30g)'),
    const FoodItem(id: 'creatina', name: 'Creatina monohidratada', category: FoodCategory.suplementos, kcal: 0, protein: 0, carbs: 0, fat: 0, householdMeasure: '1 dose (5g)', gramWeight: 5),
    const FoodItem(id: 'amendoim', name: 'Amendoim torrado', category: FoodCategory.industrializados, kcal: 567, protein: 26, carbs: 16, fat: 49, fiber: 8, householdMeasure: '1 punhado (30g)'),
    const FoodItem(id: 'macarrao', name: 'Macarrão cozido', category: FoodCategory.graosECereais, kcal: 158, protein: 6, carbs: 31, fat: 1, householdMeasure: '1 escumadeira (100g)'),
  ];
}
