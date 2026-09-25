# -*- coding: utf-8 -*-
import json
from pathlib import Path

entries = json.loads(
    Path('RELATORIO_YOUTUBE_VIDEOS_STATUS.json').read_text(encoding='utf-8')
)
uniq = {}
for e in entries:
    vid = e.get('videoId')
    if vid:
        uniq[vid] = e

ok_n = sum(1 for e in uniq.values() if str(e['status']).startswith('OK'))
priv_n = sum(1 for e in uniq.values() if 'PRIVATE' in str(e['status']))
unav_n = sum(1 for e in uniq.values() if e['status'] == 'UNAVAILABLE')

lines = [
    '# Relatório YouTube — catálogo de treinos',
    '',
    f'- Treinos no catálogo: {len(entries)}',
    f'- Vídeos únicos: {len(uniq)}',
    f'- Funcionando (público/não listado): {ok_n}',
    f'- Privados/restritos: {priv_n}',
    f'- Indisponíveis: {unav_n}',
    '',
    '## Ação necessária no YouTube',
    'No YouTube Studio, altere a privacidade de **Privado** para '
    '**Não listado** (recomendado) ou **Público**.',
    'Enquanto estiverem Privados, o aluno vê "Private video" e o app '
    'NÃO consegue reproduzir — isso não se resolve no código do app.',
    '',
    '## Lista completa — vídeos PRIVADOS (alterar para Não listado)',
]

seen = set()
for e in entries:
    vid = e.get('videoId')
    if not vid or vid in seen:
        continue
    if 'PRIVATE' not in str(e['status']):
        continue
    seen.add(vid)
    lines.append(f"- `{vid}` — {e.get('nome')} — {e.get('url')}")

lines += ['', '## Indisponíveis']
seen = set()
for e in entries:
    key = e.get('videoId') or e.get('id')
    if key in seen:
        continue
    if e['status'] not in ('UNAVAILABLE', 'INVALID_URL'):
        continue
    seen.add(key)
    lines.append(f"- `{key}` — {e.get('nome')} — {e.get('url', '')}")

Path('RELATORIO_YOUTUBE_VIDEOS_STATUS.md').write_text(
    '\n'.join(lines), encoding='utf-8'
)
print(f'OK priv={priv_n} ok={ok_n} unav={unav_n}')
