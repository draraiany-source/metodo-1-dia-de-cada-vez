# -*- coding: utf-8 -*-
"""Remove fina faixa branca (sola) no topo do conteúdo das PNGs Lily."""
from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
from fix_lily_frame import content_bbox, pad_center  # noqa: E402

ROOTS = [
    Path('assets/mascot/png'),
    Path('assets/mascot/extras'),
    Path('assets/images/lily_fit'),
    Path('assets/images/mascote'),
]
PREVIEW = Path('assets/_lily_trim_preview')
WHITE_HARD = 500
WHITE_SOFT = 400
MAX_TRIM = 12


def _white_row(rgb: np.ndarray, a: np.ndarray, y: int, thr: int) -> int:
    return int(((a[y] > 15) & (rgb[y].sum(1) > thr)).sum())


def _center_white(rgb: np.ndarray, a: np.ndarray, y: int, w: int, thr: int) -> int:
    x0, x1 = int(w * 0.25), int(w * 0.75)
    sl = rgb[y, x0:x1]
    al = a[y, x0:x1]
    return int(((al > 15) & (sl.sum(1) > thr)).sum())


def _feet_at_top(arr: np.ndarray) -> bool:
    h, w = arr.shape[:2]
    rgb, a = arr[..., :3], arr[..., 3]
    bad = 0
    for y in range(min(40, h)):
        act = int(((rgb[y].sum(1) > 40) & (a[y] > 15)).sum())
        face = int(
            (
                (a[y] > 20)
                & (rgb[y, :, 0] > 70)
                & (rgb[y, :, 1] > 40)
                & (rgb[y, :, 2] > 25)
                & (rgb[y, :, 0] > rgb[y, :, 2] * 1.05)
            ).sum()
        )
        if act > w * 0.02 and face < w * 0.01:
            bad += 1
    return bad >= 3


def top8_white(arr: np.ndarray) -> tuple[int, int]:
    """Contagem w500/w400 nas primeiras 8 linhas (absolutas)."""
    rgb, a = arr[..., :3], arr[..., 3]
    h = arr.shape[0]
    w500 = sum(_white_row(rgb, a, y, WHITE_HARD) for y in range(min(8, h)))
    w400 = sum(_white_row(rgb, a, y, WHITE_SOFT) for y in range(min(8, h)))
    return w500, w400


def top8_content_white(arr: np.ndarray) -> tuple[int, int]:
    bbox = content_bbox(arr)
    if not bbox:
        return 0, 0
    _, y0, _, y1 = bbox
    rgb, a = arr[..., :3], arr[..., 3]
    w500 = sum(_white_row(rgb, a, y, WHITE_HARD) for y in range(y0, min(y0 + 8, y1)))
    w400 = sum(_white_row(rgb, a, y, WHITE_SOFT) for y in range(y0, min(y0 + 8, y1)))
    return w500, w400


def needs_trim(arr: np.ndarray) -> bool:
    """Só arquivos com sola no topo absoluto ou faixa fina (<=8 px brancos)."""
    w500_abs, _ = top8_white(arr)
    if w500_abs >= 3:
        return True
    w500_c, _ = top8_content_white(arr)
    # Faixa fina de sola no início do conteúdo (ex.: hydration row 22).
    return 1 <= w500_c <= 8


def trim_top_white_sole(arr: np.ndarray) -> tuple[np.ndarray, int]:
    bbox = content_bbox(arr)
    if bbox is None:
        return arr, 0
    x0, y0, x1, y1 = bbox
    crop = arr[y0:y1, x0:x1].copy()
    ch, cw = crop.shape[:2]
    rgb, a = crop[..., :3], crop[..., 3]
    trim = 0
    while trim < min(MAX_TRIM, ch - 30):
        w500 = _white_row(rgb, a, trim, WHITE_HARD)
        w400 = _white_row(rgb, a, trim, WHITE_SOFT)
        cw500 = _center_white(rgb, a, trim, cw, WHITE_HARD)
        cw400 = _center_white(rgb, a, trim, cw, WHITE_SOFT)
        # Faixa fina de sola: branco no centro OU poucos brancos totais (não pele/braço).
        if cw500 >= 1 or (1 <= w500 <= 8 and w400 <= 15):
            trim += 1
            continue
        break
    if trim == 0:
        return arr, 0
    return pad_center(crop[trim:]), trim


def process(path: Path, preview: bool = False) -> dict:
    before = np.array(Image.open(path).convert('RGBA'))
    w500_b, w400_b = top8_white(before)
    wc500_b, wc400_b = top8_content_white(before)
    out, trimmed = trim_top_white_sole(before)
    if trimmed:
        Image.fromarray(out, 'RGBA').save(path, optimize=True)
    after = np.array(Image.open(path).convert('RGBA'))
    w500_a, w400_a = top8_white(after)
    wc500_a, wc400_a = top8_content_white(after)
    if preview and trimmed:
        PREVIEW.mkdir(parents=True, exist_ok=True)
        stem = path.as_posix().replace('/', '__')
        Image.fromarray(before, 'RGBA').save(PREVIEW / f'{stem}_before.png')
        Image.fromarray(after, 'RGBA').save(PREVIEW / f'{stem}_after.png')
    return {
        'path': str(path),
        'trimmed_rows': trimmed,
        'top8_w500_before': w500_b,
        'top8_w500_after': w500_a,
        'top8_w400_before': w400_b,
        'top8_w400_after': w400_a,
        'content8_w500_before': wc500_b,
        'content8_w500_after': wc500_a,
        'feet_at_top': _feet_at_top(after),
    }


def main():
    explicit = [
        Path('assets/mascot/png/mascot_hydration.png'),
        Path('assets/images/lily_fit/07_lili_fit_shaker.png'),
        Path('assets/images/mascote/avatar_hidratacao.png'),
    ]
    targets: list[Path] = list(explicit)
    for root in ROOTS:
        if not root.exists():
            continue
        for p in sorted(root.glob('*.png')):
            if p in targets:
                continue
            arr = np.array(Image.open(p).convert('RGBA'))
            if needs_trim(arr):
                targets.append(p)

    print(f'TARGETS {len(targets)}')
    for p in targets:
        r = process(p, preview=p.name == 'mascot_hydration.png')
        print(
            f"{r['trimmed_rows']:2d} rows  {r['path']}\n"
            f"    top8 w500 {r['top8_w500_before']}->{r['top8_w500_after']}  "
            f"content8 w500 {r['content8_w500_before']}->{r['content8_w500_after']}  "
            f"feet={r['feet_at_top']}"
        )


if __name__ == '__main__':
    main()
