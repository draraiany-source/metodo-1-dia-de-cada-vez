# -*- coding: utf-8 -*-
"""Remove faixa de pés no topo / cabeça wrap no rodapé das PNGs da Lily."""
from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOTS = [
    Path('assets/mascot/png'),
    Path('assets/mascot/extras'),
    Path('assets/images/lily_fit'),
    Path('assets/images/mascote'),
]
BACKUP = Path('assets/_lily_backup_before_frame_fix')
PAD = 0.10


def row_stats(arr: np.ndarray):
    rgb = arr[..., :3].astype(np.float32)
    a = arr[..., 3].astype(np.float32)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    act = (((rgb.sum(2) > 40) & (a > 15)).sum(1)).astype(np.float64)
    face = (
        (
            (a > 20)
            & (r > 70)
            & (g > 40)
            & (b > 25)
            & (r > b * 1.05)
            & (r > 50)
            & ((r + g + b) > 140)
        )
        .sum(1)
        .astype(np.float64)
    )
    return act, face


def smooth(x: np.ndarray, h: int) -> np.ndarray:
    k = max(3, h // 50)
    ker = np.ones(k) / k
    return np.convolve(x / (x.max() or 1), ker, mode='same')


def content_bbox(arr: np.ndarray):
    rgb = arr[..., :3].astype(np.int16)
    a = arr[..., 3].astype(np.int16)
    mask = (rgb.sum(2) > 35) & (a > 12)
    ys, xs = np.where(mask)
    if len(xs) == 0:
        return None
    return int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1


def _skip_shoe_band(act_s: np.ndarray, face_s: np.ndarray, h: int) -> int:
    """Avança sobre faixa inicial de pés (atividade sem rosto)."""
    y = 0
    limit = max(12, h // 4)
    while y < limit:
        if act_s[y] > 0.10 and face_s[y] < 0.06:
            y += 1
        else:
            break
    return y


def _first_face_row(act_s: np.ndarray, face_s: np.ndarray, h: int, start: int) -> int:
    """Sobe a partir do pico de rosto na metade superior — evita pés/legs cedo."""
    margin = max(3, h // 60)
    search_end = max(start + 20, int(h * 0.62))
    region = face_s[start:search_end]
    if region.size == 0 or region.max() < 0.08:
        return start
    peak = start + int(np.argmax(region))
    for y in range(peak, start - 1, -1):
        if face_s[y] < 0.07:
            return max(start, y + 1 - margin)
    return max(start, peak - max(20, h // 8))


def _white_in_row(rgb: np.ndarray, a: np.ndarray, y: int) -> int:
    return int(((a[y] > 15) & (rgb[y].sum(1) > 600)).sum())


def _refine_top(arr: np.ndarray, y0: int) -> int:
    """Remove linhas iniciais com solas brancas (restos de pés) antes do busto."""
    rgb = arr[..., :3]
    a = arr[..., 3]
    h = arr.shape[0]
    y = y0
    limit = min(h - 40, y0 + max(30, h // 4))
    while y < limit:
        if _white_in_row(rgb, a, y) >= 5:
            y += 1
            continue
        # busto limpo: 3 linhas seguidas sem solas brancas
        ok = True
        for yy in range(y, min(y + 3, h)):
            if _white_in_row(rgb, a, yy) > 2:
                ok = False
                break
        if ok:
            return y
        y += 1
    return y0


def _bottom_row(act_s: np.ndarray, face_s: np.ndarray, h: int, y0: int) -> int:
    """Corta antes de gap ou wrap de cabeça/pés no rodapé."""
    min_h = max(40, h // 5)
    mid_end = int(h * 0.62)
    mid_peak = float(face_s[y0:mid_end].max()) if y0 < mid_end else 0.0

    # Wrap no rodapé: segundo pico de rosto nos últimos 28%
    tail_start = int(h * 0.72)
    tail = face_s[tail_start:]
    if tail.size and mid_peak > 0.10:
        wrap_peak = tail_start + int(np.argmax(tail))
        if wrap_peak > h * 0.80 and face_s[wrap_peak] > mid_peak * 0.45:
            for y in range(wrap_peak - 1, max(y0 + min_h, int(h * 0.55)), -1):
                if face_s[y] < face_s[wrap_peak] * 0.45:
                    return max(y0 + min_h, y + 1)
            return max(y0 + min_h, wrap_peak - max(12, h // 28))

    # Gap após tronco principal
    mid = y0 + max(30, (h - y0) // 4)
    for y in range(mid, h - 3):
        if act_s[y] < 0.09 and act_s[y + 1] < 0.09 and act_s[y + 2] < 0.09:
            if y - y0 >= min_h:
                return y

    return h


def extract(arr: np.ndarray) -> tuple[np.ndarray, str]:
    h = arr.shape[0]
    act, face = row_stats(arr)
    act_s = smooth(act, h)
    face_s = smooth(face, h)

    shoe_start = _skip_shoe_band(act_s, face_s, h)
    y0 = _first_face_row(act_s, face_s, h, shoe_start)
    y0 = _refine_top(arr, y0)
    y1 = _bottom_row(act_s, face_s, h, y0)

    cropped = y0 > 0 or y1 < h
    if cropped and (y1 - y0) >= max(40, h // 5):
        return arr[y0:y1].copy(), f'CROP:{y0}-{y1}'

    return arr, 'FULL'


def pad_center(arr: np.ndarray) -> np.ndarray:
    bbox = content_bbox(arr)
    if bbox is None:
        return arr
    x0, y0, x1, y1 = bbox
    crop = arr[y0:y1, x0:x1]
    ch, cw = crop.shape[:2]
    pad = max(12, int(max(cw, ch) * PAD))
    canvas = np.zeros((ch + pad * 2, cw + pad * 2, 4), dtype=np.uint8)
    canvas[pad : pad + ch, pad : pad + cw] = crop
    return canvas


def process_file(path: Path) -> str:
    bak = BACKUP / path.as_posix().replace('/', '__')
    if not bak.exists():
        shutil.copy2(path, bak)
    arr = np.array(Image.open(bak).convert('RGBA'))
    seg, tag = extract(arr)
    out = pad_center(seg)
    Image.fromarray(out, 'RGBA').save(path, optimize=True)
    return tag


def collect_paths(only: list[str] | None) -> list[Path]:
    if only:
        return [Path(p) for p in only]
    out: list[Path] = []
    for root in ROOTS:
        if root.exists():
            out.extend(sorted(root.glob('*.png')))
    return out


def main():
    parser = argparse.ArgumentParser(description='Corrige framing das PNGs da Lily.')
    parser.add_argument(
        '--files',
        nargs='*',
        help='Caminhos relativos para reprocessar (restaura do backup antes).',
    )
    args = parser.parse_args()

    BACKUP.mkdir(parents=True, exist_ok=True)
    paths = collect_paths(args.files)
    lines: list[str] = []
    for path in paths:
        if not path.exists():
            print(f'MISSING {path}', file=sys.stderr)
            continue
        tag = process_file(path)
        line = f'{tag:14} {path}'
        print(line)
        lines.append(line)

    log = Path('lily_frame_fix_log.txt')
    if args.files:
        existing = log.read_text(encoding='utf-8').splitlines() if log.exists() else []
        merged = {ln.split(None, 1)[-1]: ln for ln in existing if ln.strip()}
        for ln in lines:
            merged[ln.split(None, 1)[-1]] = ln
        log.write_text('\n'.join(merged[k] for k in sorted(merged)), encoding='utf-8')
    else:
        log.write_text('\n'.join(lines), encoding='utf-8')
    print('DONE', len(lines))


if __name__ == '__main__':
    main()
