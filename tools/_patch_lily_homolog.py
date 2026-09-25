# -*- coding: utf-8 -*-
from pathlib import Path
import re

root = Path(r"C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2")

# ---- 1) treino_catalog_visual.dart: Lily in TreinoSectionIcon ----
vis = root / "lib/features/workouts/presentation/treino_catalog_visual.dart"
text = vis.read_text(encoding="utf-8")

if "lily_treino_image.dart" not in text:
    text = text.replace(
        "import '../../../core/lily/lily_treino_assets.dart';",
        "import '../../../core/lily/lily_treino_assets.dart';\nimport '../../../core/lily/lily_treino_image.dart';",
    )

# Insert lilyAssetForSection before TreinoSectionIcon if missing
helper = '''
/// Asset Lily Fit por seção do filtro (tabs/categorias).
String lilyAssetForSection(TreinoVisualSection section) {
  return switch (section) {
    TreinoVisualSection.cardio => LilyTreinoAssets.corrida,
    TreinoVisualSection.core => LilyTreinoAssets.prancha,
    TreinoVisualSection.mobilidade => LilyTreinoAssets.alongamento,
    TreinoVisualSection.inferioresGluteos => LilyTreinoAssets.agachamento,
    TreinoVisualSection.peitoral => LilyTreinoAssets.supino,
    TreinoVisualSection.costas => LilyTreinoAssets.remada,
    TreinoVisualSection.biceps => LilyTreinoAssets.biceps,
    TreinoVisualSection.triceps => LilyTreinoAssets.triceps,
    TreinoVisualSection.ombros => LilyTreinoAssets.desenvolvimentoOmbros,
    TreinoVisualSection.fullBody => LilyTreinoAssets.halteres,
    TreinoVisualSection.panturrilhas => LilyTreinoAssets.panturrilha,
  };
}

'''

if "lilyAssetForSection" not in text:
    text = text.replace(
        "/// Ícone padronizado dos cards (tamanho/proporção/estilo únicos).\nclass TreinoSectionIcon",
        helper + "/// Ícone padronizado dos cards (tamanho/proporção/estilo únicos).\nclass TreinoSectionIcon",
    )

# Replace glyph construction inside TreinoSectionIcon.build
old_glyph = """    final inner = size * 0.58;
    final radius = size * 0.28;

    final glyph = look.asset != null
        ? AppIconImage(
            look.asset!,
            size: inner,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            fallbackIcon: look.icon,
            semanticLabel: look.label,
          )
        : Icon(look.icon, size: inner * 0.9, color: look.accent);"""

new_glyph = """    final inner = size * 0.82;
    final radius = size * 0.28;

    // Sempre Lily Fit nos cards/listas/categorias de treino (contain, sem corte).
    final lilyAsset = treino != null
        ? lilyTreinoAssetFor(treino!)
        : lilyAssetForSection(section);

    final glyph = LilyTreinoImage(
      asset: lilyAsset,
      height: inner,
      width: inner,
      padding: EdgeInsets.zero,
      semanticLabel: look.label,
    );"""

if old_glyph in text:
    text = text.replace(old_glyph, new_glyph)
    print("OK: TreinoSectionIcon -> Lily")
else:
    print("WARN: glyph block not found exactly; trying flexible replace")
    if "LilyTreinoImage(" in text and "lilyAssetForSection(section)" in text:
        print("Already patched glyph")
    else:
        # fallback: between final look = and return Container
        m = re.search(
            r"(final look = treino != null\s*\n\s*\? treinoVisualLookOf\(treino!\)\s*\n\s*: _lookFromSection\(section\);\s*\n)(.*?)(\n\s*return Container\()",
            text,
            re.S,
        )
        if m:
            text = text[: m.start(2)] + "\n" + new_glyph + "\n" + text[m.start(3) :]
            print("OK: glyph via regex")
        else:
            print("FAIL: could not patch TreinoSectionIcon")

# Update _lookFromSection assets to Lily (for any leftover AppIconImage consumers)
replacements = [
    ("asset: AppIcons.cardio,", "asset: LilyTreinoAssets.corrida,"),
    ("asset: AppIcons.abs,", "asset: LilyTreinoAssets.prancha,"),
    ("asset: AppIcons.yoga,", "asset: LilyTreinoAssets.alongamento,"),
    ("asset: AppIcons.glutes,", "asset: LilyTreinoAssets.hipThrust,"),
    ("asset: AppIcons.workout,", "asset: LilyTreinoAssets.halteres,"),
    ("asset: AppIcons.personal,", "asset: LilyTreinoAssets.remada,"),
    ("asset: AppIcons.workoutGoal,", "asset: LilyTreinoAssets.biceps,"),
    ("asset: AppIcons.achievement,", "asset: LilyTreinoAssets.triceps,"),
    ("asset: AppIcons.trophy,", "asset: LilyTreinoAssets.desenvolvimentoOmbros,"),
    ("asset: AppIcons.running,", "asset: LilyTreinoAssets.caminhada,"),
    ("asset: AppIcons.workoutPlaceholder,", "asset: LilyTreinoAssets.generico1,"),
]
# Only replace inside _lookFromSection to avoid breaking unrelated if any
# Actually treinoVisualLookOf also uses AppIcons - replace ALL asset: AppIcons in this file for exercise/category looks
# Map common exercise AppIcons to Lily
ex_map = {
    "AppIcons.exBurpee": "LilyTreinoAssets.halteres",
    "AppIcons.exJumpingJack": "LilyTreinoAssets.alongamento",
    "AppIcons.exKettlebell": "LilyTreinoAssets.kettlebell",
    "AppIcons.exHipThrust": "LilyTreinoAssets.hipThrust",
    "AppIcons.exLegPress": "LilyTreinoAssets.agachamento",
    "AppIcons.exLegCurl": "LilyTreinoAssets.agachamento",
    "AppIcons.exLegExtension": "LilyTreinoAssets.agachamento",
    "AppIcons.exSquatSumo": "LilyTreinoAssets.agachamento",
    "AppIcons.exSquatBar": "LilyTreinoAssets.agachamento",
    "AppIcons.exSquat": "LilyTreinoAssets.agachamento",
    "AppIcons.exLunge": "LilyTreinoAssets.agachamento",
    "AppIcons.exCalf": "LilyTreinoAssets.panturrilha",
    "AppIcons.exLegRaise": "LilyTreinoAssets.prancha",
    "AppIcons.exCurl": "LilyTreinoAssets.biceps",
    "AppIcons.exTriceps": "LilyTreinoAssets.triceps",
    "AppIcons.exTricepsExt": "LilyTreinoAssets.triceps",
    "AppIcons.exKickback": "LilyTreinoAssets.coiceGluteo",
    "AppIcons.exLateralRaise": "LilyTreinoAssets.elevacaoLateral",
    "AppIcons.exBenchDb": "LilyTreinoAssets.supino",
    "AppIcons.exBench": "LilyTreinoAssets.supino",
    "AppIcons.exRowLow": "LilyTreinoAssets.remada",
    "AppIcons.exRow": "LilyTreinoAssets.remada",
    "AppIcons.exPulldown": "LilyTreinoAssets.remada",
    "AppIcons.exPushup": "LilyTreinoAssets.prancha",
    "AppIcons.exPlank": "LilyTreinoAssets.prancha",
    "AppIcons.treadmill": "LilyTreinoAssets.esteira",
    "AppIcons.bike": "LilyTreinoAssets.bicicleta",
    "AppIcons.stairs": "LilyTreinoAssets.caminhada",
    "AppIcons.walk": "LilyTreinoAssets.caminhada",
    "AppIcons.running": "LilyTreinoAssets.corrida",
    "AppIcons.stopwatch": "LilyTreinoAssets.generico2",
    "AppIcons.exStretch": "LilyTreinoAssets.alongamento",
    "AppIcons.exFunctional": "LilyTreinoAssets.halteres",
    "AppIcons.exStretchAlt": "LilyTreinoAssets.alongamento",
    "AppIcons.abs": "LilyTreinoAssets.prancha",
    "AppIcons.exTorso": "LilyTreinoAssets.prancha",
    "AppIcons.exBack": "LilyTreinoAssets.remada",
    "AppIcons.exArm": "LilyTreinoAssets.biceps",
    "AppIcons.glutes": "LilyTreinoAssets.hipThrust",
    "AppIcons.cardio": "LilyTreinoAssets.corrida",
    "AppIcons.workout": "LilyTreinoAssets.halteres",
    "AppIcons.workoutPlaceholder": "LilyTreinoAssets.generico1",
    "AppIcons.yoga": "LilyTreinoAssets.alongamento",
    "AppIcons.personal": "LilyTreinoAssets.remada",
    "AppIcons.workoutGoal": "LilyTreinoAssets.halteres",
    "AppIcons.achievement": "LilyTreinoAssets.triceps",
    "AppIcons.trophy": "LilyTreinoAssets.desenvolvimentoOmbros",
}
count = 0
for old, new in ex_map.items():
    c = text.count(old)
    if c:
        text = text.replace(old, new)
        count += c
print(f"OK: replaced {count} AppIcons->LilyTreinoAssets refs")

vis.write_text(text, encoding="utf-8")
print("Wrote", vis)

# ---- 2) RecommendedCard max width + larger Lily ----
scr = root / "lib/features/workouts/presentation/treino_catalog_screen.dart"
st = scr.read_text(encoding="utf-8")

# Ensure lily import
if "lily_treino_image.dart" not in st:
    st = st.replace(
        "import 'treino_catalog_visual.dart';",
        "import 'treino_catalog_visual.dart';\nimport '../../../core/lily/lily_treino_image.dart';\nimport '../../../core/lily/lily_treino_assets.dart';",
    )

# Replace RecommendedCard build body - work on compressed markers
# Find class and replace return Container with constrained version
marker = "class _RecommendedCard extends StatelessWidget"
idx = st.find(marker)
if idx < 0:
    print("FAIL: _RecommendedCard not found")
else:
    # Find build method return
    build_idx = st.find("Widget build(BuildContext context)", idx)
    ret_idx = st.find("return Container(", build_idx)
    # Find closing of class - next "class _TreinoCard"
    end_class = st.find("class _TreinoCard", ret_idx)
    if ret_idx < 0 or end_class < 0:
        print("FAIL: RecommendedCard structure")
    else:
        # Find the end of return statement before class end - last ); before class _TreinoCard belonging to build
        chunk = st[ret_idx:end_class]
        # Replace first TreinoSectionIcon size 56 with larger Lily-friendly 72
        chunk2 = chunk.replace("size: 56,", "size: 72,", 1)
        new_return = """return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
"""
        # change "return Container(" to constrained wrapper; need extra closing parens before final ;
        if chunk2.startswith("return Container("):
            inner = chunk2[len("return Container("):]
            # inner ends with `    );\n\n...\n` before class - typically `    );\n\n  }\n\n}`
            # Find last `);` that closes return - the build method ends with `  }`
            # Safer: wrap by replacing start and adding closes before `  }` of build
            # Parse: chunk2 is from return to before _TreinoCard, includes `  }\n\n}` of RecommendedCard
            # Structure: return Container( ... ); \n  }\n\n}
            m = re.match(r"return Container\((.*)\)\s*;\s*\}\s*\}", chunk2, re.S)
            if not m:
                # with blank lines
                m = re.search(r"return Container\((.*)\)\s*;\s*\}", chunk2, re.S)
            if m:
                inner_body = m.group(1)
                # also bump icon size already in chunk2
                inner_body = inner_body.replace("size: 56,", "size: 72,", 1)
                rebuilt = (
                    "return Align(\n"
                    "      alignment: Alignment.centerLeft,\n"
                    "      child: ConstrainedBox(\n"
                    "        constraints: const BoxConstraints(maxWidth: 560),\n"
                    "        child: Container("
                    + inner_body
                    + "),\n"
                    "      ),\n"
                    "    );\n"
                    "  }\n"
                    "}\n\n\n"
                )
                st = st[:ret_idx] + rebuilt + st[end_class:]
                print("OK: RecommendedCard constrained maxWidth 560")
            else:
                print("FAIL: regex RecommendedCard; len chunk", len(chunk2))
                print(repr(chunk2[:200]))
                print(repr(chunk2[-200:]))

scr.write_text(st, encoding="utf-8")

# ---- 3) Fix Lily normalize accents (encoding-safe) ----
assets = root / "lib/core/lily/lily_treino_assets.dart"
at = assets.read_text(encoding="utf-8")
# Replace broken _normalize with ASCII-folding that doesn't depend on corrupted literals
new_norm = r'''  static String _normalize(String raw) {
    var s = raw.toLowerCase().trim();
    const pairs = <List<String>>[
      ['á', 'a'], ['à', 'a'], ['â', 'a'], ['ã', 'a'], ['ä', 'a'],
      ['é', 'e'], ['è', 'e'], ['ê', 'e'], ['ë', 'e'],
      ['í', 'i'], ['ì', 'i'], ['î', 'i'], ['ï', 'i'],
      ['ó', 'o'], ['ò', 'o'], ['ô', 'o'], ['õ', 'o'], ['ö', 'o'],
      ['ú', 'u'], ['ù', 'u'], ['û', 'u'], ['ü', 'u'],
      ['ç', 'c'], ['ñ', 'n'],
    ];
    for (final p in pairs) {
      s = s.replaceAll(p[0], p[1]);
    }
    s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    while (s.contains('__')) {
      s = s.replaceAll('__', '_');
    }
    return s.replaceAll(RegExp(r'^_|_$'), '');
  }'''
# Replace existing _normalize method
at2, n = re.subn(
    r"  static String _normalize\(String raw\) \{.*?\n  \}",
    new_norm,
    at,
    count=1,
    flags=re.S,
)
if n:
    assets.write_text(at2, encoding="utf-8")
    print("OK: fixed LilyTreinoAssets._normalize")
else:
    print("WARN: _normalize not replaced")

# ---- 4) Meditations empty state clearer ----
acs = root / "lib/features/audio_courses/presentation/audio_courses_screen.dart"
ac = acs.read_text(encoding="utf-8")
old_empty = '''                        if (courses.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: ComingSoonView(
                              emoji: '🎧',
                              title: 'Nenhum curso disponível ainda',
                              description:
                                  'Assim que os cursos forem cadastrados, eles aparecem aqui automaticamente.',
                            ),
                          )'''
new_empty = '''                        if (courses.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: AppEmptyState(
                              title: widget.onlyCategories != null
                                  ? 'Nenhuma meditação por aqui ainda'
                                  : 'Nenhum áudio disponível ainda',
                              message: widget.onlyCategories != null
                                  ? 'Quando a Personal cadastrar meditações e áudios de calma no CMS, eles aparecem aqui automaticamente.'
                                  : 'Quando os cursos forem cadastrados no painel da Personal, eles aparecem aqui automaticamente.',
                              pose: MascotePose.padrao,
                              mascotHeight: 140,
                            ),
                          )'''
if old_empty in ac:
    ac = ac.replace(old_empty, new_empty)
    # ensure AppEmptyState import already via app_states; MascotePose via lili
    if "app_states.dart" not in ac:
        ac = ac.replace(
            "import '../../../core/widgets/common_widgets.dart';",
            "import '../../../core/widgets/common_widgets.dart';\nimport '../../../core/widgets/app_states.dart';",
        )
    # MascotePose - check if lili_widgets imported
    if "lili_widgets.dart" not in ac and "mascot" not in ac:
        ac = ac.replace(
            "import '../../../core/widgets/app_states.dart';",
            "import '../../../core/widgets/app_states.dart';\nimport '../../../core/widgets/lili_widgets.dart';",
        )
    acs.write_text(ac, encoding="utf-8")
    print("OK: meditations/audio empty state")
else:
    print("WARN: empty block not found (maybe already patched)")
    if "Nenhuma meditação por aqui ainda" in ac:
        print("Already has new empty")

# ---- 5) Soften AppErrorState default message ----
states = root / "lib/core/widgets/app_states.dart"
stt = states.read_text(encoding="utf-8")
stt2 = stt.replace(
    "this.message = 'Não conseguimos carregar agora. Verifique sua conexão e '",
    "this.message = 'Não foi possível carregar agora. Se a conexão estiver ok, "
)
# Actually don't break string concatenation - read the full default
print("AppError snippet:")
for i, line in enumerate(stt.splitlines()):
    if "carregar" in line.lower() or "servidor" in line.lower():
        print(f"{i+1}: {line}")

print("DONE patches")
