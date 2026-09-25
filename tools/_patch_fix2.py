# -*- coding: utf-8 -*-
from pathlib import Path
import re

# Fix RecommendedCard closing braces if broken
st_path = Path('lib/features/workouts/presentation/treino_catalog_screen.dart')
st = st_path.read_text(encoding='utf-8')
i = st.find('class _RecommendedCard')
j = st.find('class _TreinoCard', i)
chunk = st[i:j]
print('CHUNK TAIL:')
print(repr(chunk[-400:]))

# Prefer center alignment on wide screens - use Alignment.center
if 'alignment: Alignment.centerLeft' in chunk:
    st = st[:i] + chunk.replace('alignment: Alignment.centerLeft', 'alignment: Alignment.center') + st[j:]
    st_path.write_text(st, encoding='utf-8')
    print('centered RecommendedCard')

# Remove unused imports from visual
vpath = Path('lib/features/workouts/presentation/treino_catalog_visual.dart')
v = vpath.read_text(encoding='utf-8')
v2 = v.replace("import '../../../core/assets/app_icons.dart';\n", '')
v2 = v2.replace("import '../../../core/widgets/app_icon_image.dart';\n", '')
if v2 != v:
    vpath.write_text(v2, encoding='utf-8')
    print('removed unused AppIcons imports')

# Improve AppErrorState default message (keep Portuguese)
spath = Path('lib/core/widgets/app_states.dart')
s = spath.read_text(encoding='utf-8')
# Replace the two-line default message regardless of encoding of Não
s2, n = re.subn(
    r"this\.message = '[^']*carregar[^']*'\s*\n\s*'tente de novo\.',",
    "this.message = 'Não foi possível carregar agora. Confira a conexão; "
    "se o conteúdo ainda não foi cadastrado, a lista pode aparecer vazia.',",
    s,
    count=1,
)
if n:
    spath.write_text(s2, encoding='utf-8')
    print('updated AppErrorState message')
else:
    print('AppErrorState message not updated')

# Verify RecommendedCard parentheses balance in build
st = st_path.read_text(encoding='utf-8')
i = st.find('class _RecommendedCard')
j = st.find('class _TreinoCard', i)
chunk = st[i:j]
# crude: count ( vs )
print('parens', chunk.count('('), chunk.count(')'))
print('braces', chunk.count('{'), chunk.count('}'))
