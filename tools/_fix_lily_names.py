# -*- coding: utf-8 -*-
from pathlib import Path
p = Path('lib/features/workouts/presentation/treino_catalog_visual.dart')
t = p.read_text(encoding='utf-8')
fixes = {
    'LilyTreinoAssets.tricepsExt': 'LilyTreinoAssets.triceps',
    'LilyTreinoAssets.alongamentoAlt': 'LilyTreinoAssets.alongamento',
    'LilyTreinoAssets.halteresPlaceholder': 'LilyTreinoAssets.generico1',
    'LilyTreinoAssets.halteresGoal': 'LilyTreinoAssets.halteres',
    'LilyTreinoAssets.halteresPlaceholder': 'LilyTreinoAssets.generico1',
}
for a,b in fixes.items():
    c = t.count(a)
    t = t.replace(a,b)
    print(a, '->', b, 'count', c)
# any remaining unknown LilyTreinoAssets that aren't real?
import re
known = {
 'halteres','agachamento','prancha','cordaNaval','kettlebell','hipThrust','coiceGluteo',
 'abducaoFaixa','elevacaoLateral','biceps','triceps','remada','supino','desenvolvimentoOmbros',
 'panturrilha','bicicleta','esteira','caminhada','corrida','alongamento','generico1','generico2',
 'generico3','generico4','base','all','genericos','resolve','_normalize','_exact'
}
found = set(re.findall(r'LilyTreinoAssets\.(\w+)', t))
unknown = found - known
print('unknown members', unknown)
p.write_text(t, encoding='utf-8')
print('fixed')
