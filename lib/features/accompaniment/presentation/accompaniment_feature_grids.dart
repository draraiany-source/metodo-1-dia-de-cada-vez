import 'package:flutter/material.dart';

import '../../../core/assets/personal_ai_icons.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/feature_icon_card.dart';

/// Grade da aluna: Fale com Amanda · Consultoria · Anamnese · Evolução · Assistente IA.
class StudentAccompanimentSection extends StatelessWidget {
  const StudentAccompanimentSection({
    super.key,
    this.onEvolution,
    this.title = 'Acompanhamento',
  });

  /// Se informado, substitui a rota padrão [Routes.evolution].
  final VoidCallback? onEvolution;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        FeatureIconPair(
          left: FeatureIconCard(
            icon: PersonalAiIcons.chatAmanda,
            title: 'Fale com Amanda',
            subtitle: 'Chat com a Personal',
            accent: AppColors.secondary,
            fallbackIcon: Icons.chat_bubble_outline,
            onPress: () => AppNavigation.open(context, Routes.faleComAmanda),
          ),
          right: FeatureIconCard(
            icon: PersonalAiIcons.agendaConsultoria,
            title: 'Consultoria',
            subtitle: 'Agendar horário',
            accent: AppColors.primary,
            fallbackIcon: Icons.event_available_outlined,
            onPress: () => AppNavigation.open(context, Routes.consultoria),
          ),
        ),
        const SizedBox(height: 10),
        FeatureIconPair(
          left: FeatureIconCard(
            icon: PersonalAiIcons.anamnese,
            title: 'Minha Anamnese',
            subtitle: 'Avaliação inicial',
            accent: AppColors.hotPink,
            fallbackIcon: Icons.assignment_outlined,
            onPress: () => AppNavigation.open(context, Routes.minhaAnamnese),
          ),
          right: FeatureIconCard(
            icon: PersonalAiIcons.insightsIA,
            title: 'Minha Evolução',
            subtitle: 'Resumo de desempenho',
            accent: AppColors.primaryDark,
            fallbackIcon: Icons.show_chart,
            onPress: onEvolution ??
                () => AppNavigation.open(context, Routes.evolution),
          ),
        ),
        const SizedBox(height: 10),
        FeatureIconCard(
          icon: PersonalAiIcons.assistenteIA,
          title: 'Assistente IA',
          subtitle:
              'Seu assistente inteligente para ajudar na organização da sua rotina e no uso do Método.',
          variant: FeatureIconCardVariant.list,
          iconSize: 56,
          accent: AppColors.accent,
          fallbackIcon: Icons.auto_awesome,
          onPress: () => AppNavigation.open(context, Routes.methodAssistant),
        ),
      ],
    );
  }
}

/// Atalhos rápidos do painel da Amanda (rotas já existentes).
class PersonalQuickAccessSection extends StatelessWidget {
  const PersonalQuickAccessSection({
    super.key,
    required this.onStudents,
    required this.onAnamnesis,
  });

  final VoidCallback onStudents;
  final VoidCallback onAnamnesis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acompanhamento',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        FeatureIconPair(
          left: FeatureIconCard(
            icon: PersonalAiIcons.areaPersonal,
            title: 'Minhas Alunas',
            subtitle: 'Dashboard da Amanda',
            variant: FeatureIconCardVariant.compact,
            accent: AppColors.secondary,
            fallbackIcon: Icons.people_alt_outlined,
            onPress: onStudents,
          ),
          right: FeatureIconCard(
            icon: PersonalAiIcons.chatAmanda,
            title: 'Mensagens',
            subtitle: 'Fale com as alunas',
            variant: FeatureIconCardVariant.compact,
            accent: AppColors.hotPink,
            fallbackIcon: Icons.chat_bubble_outline,
            onPress: () => AppNavigation.open(context, Routes.trainerInbox),
          ),
        ),
        const SizedBox(height: 10),
        FeatureIconPair(
          left: FeatureIconCard(
            icon: PersonalAiIcons.agendaConsultoria,
            title: 'Agenda',
            subtitle: 'Próximas consultas',
            variant: FeatureIconCardVariant.compact,
            accent: AppColors.primary,
            fallbackIcon: Icons.event_available_outlined,
            onPress: () => AppNavigation.open(context, Routes.trainerAgenda),
          ),
          right: FeatureIconCard(
            icon: PersonalAiIcons.anamnese,
            title: 'Anamnese',
            subtitle: 'Questionário da aluna',
            variant: FeatureIconCardVariant.compact,
            accent: AppColors.primaryDark,
            fallbackIcon: Icons.assignment_outlined,
            onPress: onAnamnesis,
          ),
        ),
      ],
    );
  }
}

class PersonalAiToolsSection extends StatelessWidget {
  const PersonalAiToolsSection({
    super.key,
    required this.onAnalyze,
    required this.onReplySuggestion,
    required this.onSummarize,
    required this.onAttention,
  });

  final VoidCallback onAnalyze;
  final VoidCallback onReplySuggestion;
  final VoidCallback onSummarize;
  final VoidCallback onAttention;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inteligência Artificial',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'A IA organiza e sugere. A decisão final continua sendo da Amanda.',
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: 12, height: 1.35),
        ),
        const SizedBox(height: 10),
        FeatureIconCard(
          icon: PersonalAiIcons.analisarIA,
          title: 'Analisar com IA',
          subtitle: 'Preparar consulta a partir da anamnese',
          variant: FeatureIconCardVariant.list,
          accent: AppColors.primary,
          fallbackIcon: Icons.auto_awesome,
          onPress: onAnalyze,
        ),
        const SizedBox(height: 8),
        FeatureIconCard(
          icon: PersonalAiIcons.sugestaoResposta,
          title: 'Sugestão de resposta',
          subtitle: 'Apoio à Amanda no chat',
          variant: FeatureIconCardVariant.list,
          accent: AppColors.secondary,
          fallbackIcon: Icons.reply_outlined,
          onPress: onReplySuggestion,
        ),
        const SizedBox(height: 8),
        FeatureIconCard(
          icon: PersonalAiIcons.resumoConversa,
          title: 'Resumo da conversa',
          subtitle: 'Histórico de mensagens',
          variant: FeatureIconCardVariant.list,
          accent: AppColors.hotPink,
          fallbackIcon: Icons.summarize_outlined,
          onPress: onSummarize,
        ),
        const SizedBox(height: 8),
        FeatureIconCard(
          icon: PersonalAiIcons.pontosAtencao,
          title: 'Pontos de atenção',
          subtitle: 'Alertas da anamnese para revisão',
          variant: FeatureIconCardVariant.list,
          accent: AppColors.warning,
          fallbackIcon: Icons.warning_amber_outlined,
          onPress: onAttention,
        ),
      ],
    );
  }
}
