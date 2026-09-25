# -*- coding: utf-8 -*-
from pathlib import Path

# audio import
p = Path('lib/features/audio_courses/presentation/audio_courses_screen.dart')
t = p.read_text(encoding='utf-8')
if 'lili_widgets.dart' not in t:
    t = t.replace(
        "import '../../../core/widgets/app_states.dart';",
        "import '../../../core/widgets/app_states.dart';\nimport '../../../core/widgets/lili_widgets.dart';",
    )
    p.write_text(t, encoding='utf-8')
    print('added lili_widgets')
else:
    print('lili ok')

# RecommendedCard preview
st = Path('lib/features/workouts/presentation/treino_catalog_screen.dart').read_text(encoding='utf-8')
i = st.find('class _RecommendedCard')
print('--- RecommendedCard ---')
print(st[i:i+2200])

# visual imports unused?
v = Path('lib/features/workouts/presentation/treino_catalog_visual.dart').read_text(encoding='utf-8')
print('AppIconImage used', 'AppIconImage(' in v)
print('AppIcons used', 'AppIcons.' in v)
print('LilyTreinoImage', 'LilyTreinoImage(' in v)
print('lilyAssetForSection', 'lilyAssetForSection' in v)

# AppErrorState - improve default by reading lines 110-130
s = Path('lib/core/widgets/app_states.dart').read_text(encoding='utf-8')
lines = s.splitlines()
for n in range(105, 140):
    if n-1 < len(lines):
        print(f'{n}: {lines[n-1]}')
