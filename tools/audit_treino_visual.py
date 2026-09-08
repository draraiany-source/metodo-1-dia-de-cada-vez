import json
from collections import Counter
from pathlib import Path

items = json.loads(
    Path('assets/content/treinos_catalogo_oficial.json').read_text(encoding='utf-8')
)['treinos']


def norm(v):
    s = (v or '').lower()
    for a, b in zip('áéíóúãõç', 'aeiouaoc'):
        s = s.replace(a, b)
    return s


def has(hay, keys):
    return any(norm(k) in hay for k in keys)


def label_of(t):
    cat, grupo, nome = (
        norm(t.get('categoria')),
        norm(t.get('grupo_muscular')),
        norm(t.get('nome')),
    )
    hay = f'{cat} {grupo} {nome}'
    if has(hay, ['esteira']):
        return 'Esteira'
    if has(hay, ['bike', 'bicicleta', 'ciclismo']):
        return 'Bike'
    if has(hay, ['caminhada', 'walk']):
        return 'Caminhada'
    if has(hay, ['corrida', 'running']) and not has(hay, ['caminhada']):
        return 'Corrida'
    if has(hay, ['hiit', 'alta intensidade', 'tabata']):
        return 'HIIT'
    if has(hay, ['along']):
        return 'Alongamento'
    if has(hay, ['aquec']):
        return 'Aquecimento'
    if has(hay, ['mobili', 'flexib', 'yoga']):
        return 'Mobilidade'
    if has(hay, ['panturrilha', 'gemeo']):
        return 'Panturrilha'
    if has(hay, ['abdomen', 'abdominal', 'core', 'prancha']):
        return 'Abdômen'
    if has(hay, ['peitoral', 'peito', 'supino', 'crucifixo']):
        return 'Peito'
    if has(hay, ['costas', 'dorsal', 'remada', 'puxada', 'pulldown']):
        return 'Costas'
    if has(hay, ['ombro', 'desenvolvimento', 'elevacao lateral', 'trap']):
        return 'Ombro'
    if has(hay, ['biceps', 'rosca']):
        return 'Bíceps'
    if has(hay, ['triceps', 'extensao', 'coice', 'frances']):
        return 'Tríceps'
    lower_hits = sum(
        1
        for k in ['gluteo', 'quadriceps', 'posterior', 'isquio', 'adutor', 'abdut']
        if k in hay
    )
    if lower_hits >= 2 or ('membros inferiores' in hay and lower_hits >= 1):
        return 'Inferiores'
    if has(hay, ['quadriceps', 'agacha', 'leg press', 'extensora', 'afundo', 'passada']):
        return 'Quadríceps'
    if has(hay, ['posterior', 'isquio', 'isquiotib', 'stiff', 'mesa flexora']):
        return 'Posterior'
    if has(hay, ['gluteo', 'elevacao pelvica', 'ponte', 'hip thrust']):
        return 'Glúteo'
    if has(hay, ['adutor', 'abdut', 'membros inferiores', 'perna', 'pernas']):
        return 'Inferiores'
    if has(hay, ['funcional', 'full body', 'corpo todo', 'corpo inteiro']):
        return 'Funcional'
    if has(hay, ['cardio']) and not has(hay, ['hipertrofia']):
        return 'Cardio'
    if has(hay, ['cardio']) and has(hay, ['hipertrofia']):
        return 'Musculação'
    if has(hay, ['hipertrofia', 'muscul']):
        return 'Musculação'
    return 'Treino'


def old_heart(t):
    cat, grupo = norm(t.get('categoria')), norm(t.get('grupo_muscular'))
    if 'panturrilha' in grupo or 'panturrilha' in cat:
        return False
    if 'cardio' in cat and 'hipertrofia' not in cat:
        return True
    if any(x in cat or x in grupo for x in ['core', 'abdomen']):
        return False
    if any(x in cat for x in ['flexibilidade', 'mobilidade', 'aquecimento']):
        return False
    if 'peitoral' in grupo or 'peitoral' in cat:
        return False
    if 'costas' in grupo or 'costas' in cat:
        return False
    if 'biceps' in grupo or 'biceps' in cat:
        return False
    if 'triceps' in grupo or 'triceps' in cat:
        return False
    if 'ombro' in grupo or 'ombro' in cat:
        return False
    if any(x in cat for x in ['full body', 'funcional', 'emagrecimento']):
        return False
    if 'membros inferiores' in cat or any(
        x in grupo for x in ['gluteo', 'quadriceps', 'posterior', 'isquio', 'adutor']
    ):
        return False
    if 'cardio' in cat:
        return True
    return False


labels = [label_of(t) for t in items]
print('TOTAL', len(items))
print('OLD_HEART', sum(1 for t in items if old_heart(t)))
print('NEW_CARDIO_HEART', sum(1 for l in labels if l == 'Cardio'))
print('CATEGORY', sum(1 for l in labels if l != 'Treino'))
print('PLACEHOLDER', sum(1 for l in labels if l == 'Treino'))
print('SPECIFIC_EXERCISE_IMAGE', 0)
print('NO_OWN_IMAGE', len(items))
print('BY_LABEL', dict(Counter(labels)))
