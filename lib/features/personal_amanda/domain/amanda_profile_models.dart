/// Conteúdo do perfil público “Quem Sou Eu” / Conheça a Amanda.
/// Fotos de capa/perfil/galeria: coleção `amanda_assets` + Storage.
/// Textos e CTAs: documento Firestore `amanda_profile/main`.
class AmandaFormationItem {
  const AmandaFormationItem({
    required this.name,
    this.institution = '',
    this.year = '',
    this.imageUrl = '',
    this.description = '',
  });

  final String name;
  final String institution;
  final String year;
  final String imageUrl;
  final String description;

  Map<String, dynamic> toMap() => {
        'name': name,
        'institution': institution,
        'year': year,
        'imageUrl': imageUrl,
        'description': description,
      };

  factory AmandaFormationItem.fromMap(Map<String, dynamic> m) =>
      AmandaFormationItem(
        name: (m['name'] ?? '').toString().trim(),
        institution: (m['institution'] ?? '').toString().trim(),
        year: (m['year'] ?? '').toString().trim(),
        imageUrl: (m['imageUrl'] ?? '').toString().trim(),
        description: (m['description'] ?? '').toString().trim(),
      );
}

/// Destino do botão principal “Quero começar”.
enum AmandaCtaTarget {
  whatsapp,
  url,
  plans,
}

AmandaCtaTarget amandaCtaFrom(String? raw) {
  final v = (raw ?? '').trim().toLowerCase();
  return switch (v) {
    'url' || 'link' => AmandaCtaTarget.url,
    'plans' || 'planos' => AmandaCtaTarget.plans,
    _ => AmandaCtaTarget.whatsapp,
  };
}

class AmandaProfileContent {
  const AmandaProfileContent({
    required this.fullName,
    required this.professionalTitle,
    required this.location,
    required this.shortBio,
    required this.highlightQuote,
    required this.sportHistory,
    required this.formations,
    required this.whyPersonalTrainer,
    required this.markedStoryTitle,
    required this.markedStory,
    required this.ownTransformation,
    required this.methodOrigin,
    required this.methodMantra,
    required this.methodMeaning,
    required this.methodAudience,
    required this.methodAudienceHighlight,
    required this.methodMainGoal,
    required this.methodDifference,
    required this.methodDifferenceHighlight,
    required this.accompanimentSteps,
    required this.accompanimentBody,
    required this.philosophyCards,
    required this.philosophyText,
    required this.trainingBalance,
    required this.trainingBalanceHighlight,
    required this.whenThinkQuit,
    required this.aboutMeCards,
    required this.aboutMeText,
    required this.loveProfession,
    required this.methodDream,
    required this.feelHereCards,
    required this.feelHereText,
    required this.closingMessage,
    required this.signatureTitle,
    required this.specialties,
    required this.methodology,
    required this.certifications,
    required this.story,
    required this.instagramUrl,
    required this.instagramMetodoUrl,
    required this.youtubeUrl,
    required this.tiktokUrl,
    required this.facebookUrl,
    required this.websiteUrl,
    required this.plansUrl,
    required this.whatsappNumber,
    required this.contactLabel,
    required this.startCtaLabel,
    required this.startCtaTarget,
    required this.startCtaUrl,
    required this.sportHistoryImageUrl,
    required this.whyPtImageUrl,
    required this.transformationImageUrl,
  });

  final String fullName;
  final String professionalTitle;
  final String location;
  final String shortBio;
  final String highlightQuote;
  final String sportHistory;
  final List<AmandaFormationItem> formations;
  final String whyPersonalTrainer;
  final String markedStoryTitle;
  final String markedStory;
  final String ownTransformation;
  final String methodOrigin;
  final String methodMantra;
  final String methodMeaning;
  final List<String> methodAudience;
  final String methodAudienceHighlight;
  final String methodMainGoal;
  final String methodDifference;
  final String methodDifferenceHighlight;
  final List<String> accompanimentSteps;
  final String accompanimentBody;
  final List<String> philosophyCards;
  final String philosophyText;
  final String trainingBalance;
  final String trainingBalanceHighlight;
  final String whenThinkQuit;
  final List<String> aboutMeCards;
  final String aboutMeText;
  final String loveProfession;
  final String methodDream;
  final List<String> feelHereCards;
  final String feelHereText;
  final String closingMessage;
  final String signatureTitle;

  /// Campos legados / atalhos ainda usados no painel.
  final List<String> specialties;
  final String methodology;
  final List<String> certifications;
  final String story;

  final String instagramUrl;
  final String instagramMetodoUrl;
  final String youtubeUrl;
  final String tiktokUrl;
  final String facebookUrl;
  final String websiteUrl;
  final String plansUrl;
  final String whatsappNumber;
  final String contactLabel;
  final String startCtaLabel;
  final AmandaCtaTarget startCtaTarget;
  final String startCtaUrl;

  final String sportHistoryImageUrl;
  final String whyPtImageUrl;
  final String transformationImageUrl;

  static const defaults = AmandaProfileContent(
    fullName: 'Amanda Lopes',
    professionalTitle: 'Treinadora Pessoal On-line | Personal Trainer',
    location: 'Canaã dos Carajás',
    shortBio:
        'Sou Amanda Lopes Sousa Silva, Personal Trainer, formada em Educação Física '
        'e especialista em Fisiologia do Exercício, Biomecânica e Personal Trainer.\n\n'
        'Há 16 anos trabalho ajudando pessoas a transformarem sua saúde, confiança e '
        'qualidade de vida através do movimento.\n\n'
        'Criei o Método 1 Dia de Cada Vez porque acredito que você não precisa mudar '
        'tudo de uma vez para transformar sua vida.\n'
        'Você precisa apenas continuar.\n'
        'Um treino de cada vez.\n'
        'Uma escolha de cada vez.\n'
        'Um recomeço de cada vez.',
    highlightQuote: 'Todas as manhãs são recomeços.',
    sportHistory:
        'Minha relação com a atividade física começou ainda na infância.\n\n'
        'Aos 10 anos, comecei fazendo parte do banco de reservas de um time de handebol '
        'da escola onde estudava, na minha cidade natal.\n'
        'Aos poucos comecei a participar das competições e me apaixonei pelo esporte.\n'
        'Jogava quase todas as tardes com as meninas da escola e, muitas vezes, também '
        'nos finais de semana.\n'
        'Aquele era o meu mundo preferido.\n\n'
        'O esporte me ensinou muito cedo sobre desafios, disciplina, superação, '
        'trabalho em equipe e recomeços.\n'
        'Cada treino, cada competição e cada dificuldade foram construindo uma parte '
        'importante de quem eu sou hoje.',
    formations: [
      AmandaFormationItem(
          name: 'Licenciada em Educação Física', institution: 'Universidade ITPAC'),
      AmandaFormationItem(
          name: 'Bacharel em Educação Física', institution: 'Universidade ITPAC'),
      AmandaFormationItem(name: 'Especialista em Fisiologia do Exercício'),
      AmandaFormationItem(name: 'Especialista em Biomecânica'),
      AmandaFormationItem(name: 'Personal Trainer'),
      AmandaFormationItem(
          name: 'Curso Funcional Super Core Brasil',
          institution: 'Belo Horizonte'),
      AmandaFormationItem(
          name: '16 anos de formação e atuação profissional'),
    ],
    whyPersonalTrainer:
        'Decidi seguir essa profissão quando percebi o quanto o exercício físico '
        'é capaz de transformar uma pessoa.\n\n'
        'Não apenas fisicamente.\n'
        'O exercício transforma a mente, melhora a saúde, aumenta a confiança e faz '
        'com que a pessoa descubra capacidades que muitas vezes nem sabia que possuía.\n\n'
        'Foi isso que me fez escolher trabalhar ajudando outras pessoas a viverem '
        'esse processo.',
    markedStoryTitle: 'Uma história que me marcou',
    markedStory:
        'Um dos momentos mais importantes da minha vida profissional foi acompanhar '
        'uma aluna que havia sido limitada por uma hérnia de disco.\n\n'
        'Ela chegou a apresentar dificuldades para caminhar e teve limitações '
        'importantes nos membros inferiores.\n'
        'Poder acompanhar sua evolução e vê-la voltar a praticar musculação foi algo '
        'muito marcante para mim.\n\n'
        'Situações como essa me lembram todos os dias que nosso trabalho vai muito '
        'além da estética.\n'
        'Estamos falando de autonomia, saúde, confiança e qualidade de vida.',
    ownTransformation:
        'Também vivi minhas próprias transformações.\n\n'
        'Depois da gravidez, o exercício teve um papel muito importante para que eu '
        'voltasse a me enxergar como mulher e reencontrasse uma parte de mim.\n\n'
        'Durante esse processo, aprendi uma das lições que mais levo para a vida:\n'
        'muitas vezes, os nossos limites aparecem primeiro na mente antes de o corpo '
        'realmente estar cansado.\n'
        'Quando entendemos isso, começamos a descobrir uma força que não sabíamos '
        'que tínhamos.',
    methodOrigin:
        'Criei o Método 1 Dia de Cada Vez porque percebi que muitas pessoas desistem '
        'antes mesmo de conseguirem experimentar os resultados.\n\n'
        'Quando colocamos metas muito longas, treinos difíceis ou mudanças enormes '
        'de uma vez, nossa mente começa a enxergar aquele caminho como algo pesado.\n'
        'E acontece algo muito comum: a pessoa falha um dia e acredita que perdeu '
        'todo o processo.\n\n'
        'Mas não funciona assim.\n'
        'Você não precisa abandonar tudo porque teve um dia difícil.\n'
        'Você simplesmente pode recomeçar no próximo dia.\n'
        'É daí que nasce o Método 1 Dia de Cada Vez.',
    methodMantra:
        'Um treino de cada vez.\nUma escolha de cada vez.\nUm recomeço de cada vez.',
    methodMeaning:
        'Para mim, significa olhar para o hoje.\n'
        'Hoje eu faço aquilo que preciso fazer.\n'
        'Sem carregar o peso da próxima semana, do próximo mês ou de tudo que ainda falta.\n\n'
        'Quando o amanhã chegar, nós cuidamos dele.\n'
        'O objetivo é transformar grandes mudanças em pequenas decisões possíveis.',
    methodAudience: [
      'Já começaram e desistiram várias vezes',
      'Sentem dificuldade em manter constância',
      'Não gostam de se sentir pressionadas',
      'Acreditam que não conseguem se adaptar a uma rotina saudável',
      'Precisam de acompanhamento e acolhimento',
      'Querem evoluir respeitando o próprio ritmo',
    ],
    methodAudienceHighlight:
        'Aqui você não precisa competir com ninguém.\n'
        'Não precisa fazer tudo perfeitamente.\n'
        'Você só precisa continuar.',
    methodMainGoal:
        'O principal objetivo do Método 1 Dia de Cada Vez é diminuir a desistência '
        'no meio do caminho.\n\n'
        'Quero ensinar minhas alunas a entenderem que um dia ruim não apaga todos '
        'os dias bons.\n'
        'Um treino perdido não significa que você fracassou.\n'
        'Uma alimentação fora do planejado não significa que tudo acabou.\n'
        'Você simplesmente continua.',
    methodDifference:
        'O Método 1 Dia de Cada Vez foi criado para pessoas que muitas vezes não se '
        'sentiram acolhidas em outros processos.\n'
        'Aqui, o acompanhamento é adaptado à realidade, ao ritmo, às dificuldades e '
        'aos objetivos de cada pessoa.',
    methodDifferenceHighlight:
        'Não quero que você tente se encaixar em um método.\n'
        'Quero que o método consiga se adaptar a você.',
    accompanimentSteps: [
      'Chamada de vídeo inicial',
      'Conhecer rotina',
      'Entender objetivos',
      'Identificar dificuldades',
      'Montar estratégia personalizada',
      'Criar treino',
      'Acompanhar execução',
      'Receber feedback',
      'Ajustar quando necessário',
      'Acompanhar evolução',
    ],
    accompanimentBody:
        'O primeiro contato acontece através de uma chamada de vídeo.\n'
        'Quero conhecer você, sua rotina, seus objetivos, suas dificuldades e, '
        'principalmente, entender por que você acredita que ainda não conseguiu '
        'alcançar o resultado que deseja.\n\n'
        'A partir disso, construímos juntas um caminho possível.\n'
        'Durante o acompanhamento, teremos feedbacks e suporte, inclusive através '
        'de grupo no WhatsApp, se essa modalidade estiver ativa.\n'
        'Também poderão ser enviados vídeos das execuções dos exercícios para '
        'análise e orientação.\n\n'
        'Meu objetivo não é apenas entregar um treino.\n'
        'É acompanhar o processo.',
    philosophyCards: ['CONSTÂNCIA', 'EXECUÇÃO', 'SEM COMPARAÇÕES'],
    philosophyText:
        'Não compare o seu início com o resultado de outra pessoa.\n'
        'Faça aquilo que precisa ser feito hoje.\n'
        'E se hoje não conseguiu?\n'
        'Amanhã você tenta novamente.',
    trainingBalance:
        'Eu acredito que você não precisa começar pelo mais difícil.\n'
        'Podemos começar pelo que é possível.\n'
        'Fazer as coisas de uma maneira mais simples no início e evoluir gradualmente.\n\n'
        'Primeiro criamos o hábito.\nDepois melhoramos.\nDepois avançamos.',
    trainingBalanceHighlight: 'Hoje eu venci. Amanhã eu vejo como vai ser.',
    whenThinkQuit:
        'Quero que você se lembre de uma coisa:\n'
        'você é uma das pessoas mais importantes da sua própria vida.\n\n'
        'E uma das maiores demonstrações de amor que você pode oferecer à sua '
        'família é cuidar da sua saúde.\n'
        'Porque para cuidar das pessoas que você ama, você também precisa estar bem.\n\n'
        'Cuidar de você não é egoísmo.\n'
        'É responsabilidade, amor e respeito pela sua própria vida.',
    aboutMeCards: ['AMOR', 'GRATIDÃO', 'RESILIÊNCIA'],
    aboutMeText:
        'Acredito que, através do exercício, as pessoas podem viver melhor, ter '
        'mais qualidade de vida e descobrir o seu verdadeiro potencial.',
    loveProfession:
        'O que mais amo é acompanhar os resultados de cada aluno.\n'
        'Cada conquista me alegra profundamente.\n'
        'Eu comemoro cada evolução como se fosse minha.\n\n'
        'Porque sei que por trás de cada resultado existe esforço, insegurança, '
        'dias difíceis, pequenas vitórias e muita superação.',
    methodDream:
        'Meu maior sonho é ver mulheres que já desistiram de si mesmas voltarem '
        'a acreditar que conseguem.\n'
        'Mulheres que não percebiam evolução por falta de orientação ou acompanhamento.\n\n'
        'Quero vê-las treinando, evoluindo, recuperando a confiança e comemorando '
        'as transformações que estão acontecendo tanto no corpo quanto na mente.\n'
        'Quero que o exercício deixe de ser uma obrigação e passe a representar '
        'cuidado, saúde, força e liberdade.',
    feelHereCards: ['ACOLHIDA', 'AMADA', 'RESPEITADA', 'CAPAZ'],
    feelHereText:
        'Quero que você perceba que também merece fazer por si mesma tudo aquilo '
        'que faz pelas pessoas que ama.\n'
        'Você importa.\nSua saúde importa.\nSua vida importa.',
    closingMessage:
        'Você pode fazer mais por você, porque você é muito importante.\n'
        'Todos os dias são uma nova oportunidade de recomeçar.\n'
        'Não precisa ser perfeito.\n'
        'Só precisa ser um dia de cada vez.',
    signatureTitle: 'Treinadora Pessoal On-line\nPersonal Trainer',
    specialties: [
      'Treino personalizado online',
      'Emagrecimento saudável',
      'Hipertrofia e definição',
      'Iniciantes e retorno aos treinos',
      'Rotina fitness sustentável',
    ],
    methodology:
        'O Método 1 Dia de Cada Vez prioriza hábitos simples, progressão segura '
        'e acompanhamento contínuo.',
    certifications: [
      'Licenciada e Bacharel em Educação Física — ITPAC',
      'Especialista em Fisiologia do Exercício',
      'Especialista em Biomecânica',
      'Personal Trainer',
      'Funcional Super Core Brasil — Belo Horizonte',
    ],
    story:
        'A Amanda acredita que transformação real acontece com constância, '
        'cuidado e planos feitos sob medida.',
    instagramUrl: 'https://instagram.com/AmandalopesPersonalTrainer',
    instagramMetodoUrl: 'https://instagram.com/metodo1decadavez',
    youtubeUrl: '',
    tiktokUrl: '',
    facebookUrl: '',
    websiteUrl: '',
    plansUrl: '',
    whatsappNumber: '',
    contactLabel: 'Falar no WhatsApp',
    startCtaLabel: 'Quero começar',
    startCtaTarget: AmandaCtaTarget.whatsapp,
    startCtaUrl: '',
    sportHistoryImageUrl: '',
    whyPtImageUrl: '',
    transformationImageUrl: '',
  );

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'professionalTitle': professionalTitle,
        'location': location,
        'shortBio': shortBio,
        'highlightQuote': highlightQuote,
        'sportHistory': sportHistory,
        'formations': formations.map((e) => e.toMap()).toList(),
        'whyPersonalTrainer': whyPersonalTrainer,
        'markedStoryTitle': markedStoryTitle,
        'markedStory': markedStory,
        'ownTransformation': ownTransformation,
        'methodOrigin': methodOrigin,
        'methodMantra': methodMantra,
        'methodMeaning': methodMeaning,
        'methodAudience': methodAudience,
        'methodAudienceHighlight': methodAudienceHighlight,
        'methodMainGoal': methodMainGoal,
        'methodDifference': methodDifference,
        'methodDifferenceHighlight': methodDifferenceHighlight,
        'accompanimentSteps': accompanimentSteps,
        'accompanimentBody': accompanimentBody,
        'philosophyCards': philosophyCards,
        'philosophyText': philosophyText,
        'trainingBalance': trainingBalance,
        'trainingBalanceHighlight': trainingBalanceHighlight,
        'whenThinkQuit': whenThinkQuit,
        'aboutMeCards': aboutMeCards,
        'aboutMeText': aboutMeText,
        'loveProfession': loveProfession,
        'methodDream': methodDream,
        'feelHereCards': feelHereCards,
        'feelHereText': feelHereText,
        'closingMessage': closingMessage,
        'signatureTitle': signatureTitle,
        'specialties': specialties,
        'methodology': methodology,
        'certifications': certifications,
        'story': story,
        'instagramUrl': instagramUrl,
        'instagramMetodoUrl': instagramMetodoUrl,
        'youtubeUrl': youtubeUrl,
        'tiktokUrl': tiktokUrl,
        'facebookUrl': facebookUrl,
        'websiteUrl': websiteUrl,
        'plansUrl': plansUrl,
        'whatsappNumber': whatsappNumber,
        'contactLabel': contactLabel,
        'startCtaLabel': startCtaLabel,
        'startCtaTarget': startCtaTarget.name,
        'startCtaUrl': startCtaUrl,
        'sportHistoryImageUrl': sportHistoryImageUrl,
        'whyPtImageUrl': whyPtImageUrl,
        'transformationImageUrl': transformationImageUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      };

  factory AmandaProfileContent.fromMap(Map<String, dynamic>? m) {
    if (m == null || m.isEmpty) return defaults;

    List<String> list(dynamic v) {
      if (v is List) {
        return v
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      if (v is String && v.trim().isNotEmpty) {
        return v
            .split(RegExp(r'[\n,]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return const [];
    }

    String s(String key, String fallback) {
      final v = (m[key] ?? '').toString().trim();
      return v.isEmpty ? fallback : v;
    }

    List<AmandaFormationItem> formations() {
      final raw = m['formations'];
      if (raw is List && raw.isNotEmpty) {
        return raw
            .whereType<Map>()
            .map((e) => AmandaFormationItem.fromMap(Map<String, dynamic>.from(e)))
            .where((e) => e.name.isNotEmpty)
            .toList();
      }
      // Compatível com lista antiga de certificações em string.
      final certs = list(m['certifications']);
      if (certs.isNotEmpty) {
        return certs.map((c) => AmandaFormationItem(name: c)).toList();
      }
      return defaults.formations;
    }

    final specs = list(m['specialties']);
    final certs = list(m['certifications']);
    final audience = list(m['methodAudience']);
    final steps = list(m['accompanimentSteps']);
    final philosophy = list(m['philosophyCards']);
    final about = list(m['aboutMeCards']);
    final feel = list(m['feelHereCards']);

    return AmandaProfileContent(
      fullName: s('fullName', defaults.fullName),
      professionalTitle: s('professionalTitle', defaults.professionalTitle),
      location: s('location', defaults.location),
      shortBio: s('shortBio', defaults.shortBio),
      highlightQuote: s('highlightQuote', defaults.highlightQuote),
      sportHistory: s('sportHistory', defaults.sportHistory),
      formations: formations(),
      whyPersonalTrainer: s('whyPersonalTrainer', defaults.whyPersonalTrainer),
      markedStoryTitle: s('markedStoryTitle', defaults.markedStoryTitle),
      markedStory: s('markedStory', defaults.markedStory),
      ownTransformation: s('ownTransformation', defaults.ownTransformation),
      methodOrigin: s('methodOrigin', defaults.methodOrigin),
      methodMantra: s('methodMantra', defaults.methodMantra),
      methodMeaning: s('methodMeaning', defaults.methodMeaning),
      methodAudience: audience.isEmpty ? defaults.methodAudience : audience,
      methodAudienceHighlight:
          s('methodAudienceHighlight', defaults.methodAudienceHighlight),
      methodMainGoal: s('methodMainGoal', defaults.methodMainGoal),
      methodDifference: s('methodDifference', defaults.methodDifference),
      methodDifferenceHighlight:
          s('methodDifferenceHighlight', defaults.methodDifferenceHighlight),
      accompanimentSteps:
          steps.isEmpty ? defaults.accompanimentSteps : steps,
      accompanimentBody: s('accompanimentBody', defaults.accompanimentBody),
      philosophyCards:
          philosophy.isEmpty ? defaults.philosophyCards : philosophy,
      philosophyText: s('philosophyText', defaults.philosophyText),
      trainingBalance: s('trainingBalance', defaults.trainingBalance),
      trainingBalanceHighlight:
          s('trainingBalanceHighlight', defaults.trainingBalanceHighlight),
      whenThinkQuit: s('whenThinkQuit', defaults.whenThinkQuit),
      aboutMeCards: about.isEmpty ? defaults.aboutMeCards : about,
      aboutMeText: s('aboutMeText', defaults.aboutMeText),
      loveProfession: s('loveProfession', defaults.loveProfession),
      methodDream: s('methodDream', defaults.methodDream),
      feelHereCards: feel.isEmpty ? defaults.feelHereCards : feel,
      feelHereText: s('feelHereText', defaults.feelHereText),
      closingMessage: s('closingMessage', defaults.closingMessage),
      signatureTitle: s('signatureTitle', defaults.signatureTitle),
      specialties: specs.isEmpty ? defaults.specialties : specs,
      methodology: s('methodology', defaults.methodology),
      certifications: certs.isEmpty ? defaults.certifications : certs,
      story: s('story', defaults.story),
      instagramUrl: s('instagramUrl', defaults.instagramUrl),
      instagramMetodoUrl: s('instagramMetodoUrl', defaults.instagramMetodoUrl),
      youtubeUrl: (m['youtubeUrl'] ?? '').toString().trim(),
      tiktokUrl: (m['tiktokUrl'] ?? '').toString().trim(),
      facebookUrl: (m['facebookUrl'] ?? '').toString().trim(),
      websiteUrl: (m['websiteUrl'] ?? '').toString().trim(),
      plansUrl: (m['plansUrl'] ?? '').toString().trim(),
      whatsappNumber: (m['whatsappNumber'] ?? '')
          .toString()
          .replaceAll(RegExp(r'\D'), ''),
      contactLabel: s('contactLabel', defaults.contactLabel),
      startCtaLabel: s('startCtaLabel', defaults.startCtaLabel),
      startCtaTarget: amandaCtaFrom(m['startCtaTarget']?.toString()),
      startCtaUrl: (m['startCtaUrl'] ?? '').toString().trim(),
      sportHistoryImageUrl: (m['sportHistoryImageUrl'] ?? '').toString().trim(),
      whyPtImageUrl: (m['whyPtImageUrl'] ?? '').toString().trim(),
      transformationImageUrl:
          (m['transformationImageUrl'] ?? '').toString().trim(),
    );
  }

  bool get hasWhatsApp => whatsappNumber.length >= 10;
  bool get hasAnySocial =>
      instagramUrl.isNotEmpty ||
      instagramMetodoUrl.isNotEmpty ||
      youtubeUrl.isNotEmpty ||
      tiktokUrl.isNotEmpty ||
      facebookUrl.isNotEmpty ||
      websiteUrl.isNotEmpty;
}
