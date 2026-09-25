# Replace Lily Fit cadeira images from Cursor attachments (PNG -> JPEG).
# Does not modify the source attachment files.
from __future__ import annotations

import hashlib
import shutil
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    import subprocess
    subprocess.check_call(["python", "-m", "pip", "install", "pillow", "-q"])
    from PIL import Image

ROOT = Path(r"C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2")
ATTACH = Path(
    r"C:\Users\Lenovo\.cursor\projects\c-Users-Lenovo-Desktop-metodo-1-dia-perfil-premium-2\assets"
)

SRC_ABD = ATTACH / "c__Users_Lenovo_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_01_Lily_Fit_Cadeira_Abdutora-83b72056-0b08-4479-a2b1-99f250f4499d.png"
SRC_EXT = ATTACH / "c__Users_Lenovo_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_02_Lily_Fit_Cadeira_Extensora-598215da-2034-459b-b774-40f741fc17ff.png"

DST_ABD = ROOT / "assets" / "lily_exercicios" / "lily_fit_cadeira_abdutora.jpeg"
DST_EXT = ROOT / "assets" / "lily_exercicios" / "lily_fit_cadeira_extensora.jpeg"
FLEXORA = ROOT / "assets" / "lily_exercicios" / "treino_063.jpg"
BACKUP = ROOT / "tools" / "_excluded_from_bundle" / "cadeiras_backup_20260923"

OUT = ROOT / "tools" / "_troca_cadeiras_out.txt"


def sha256(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def to_jpeg(src: Path, dst: Path, quality: int = 92) -> None:
    img = Image.open(src)
    if img.mode in ("RGBA", "P"):
        bg = Image.new("RGB", img.size, (17, 17, 17))
        rgba = img.convert("RGBA")
        bg.paste(rgba, mask=rgba.split()[-1])
        img = bg
    else:
        img = img.convert("RGB")
    dst.parent.mkdir(parents=True, exist_ok=True)
    img.save(dst, format="JPEG", quality=quality, optimize=True)


def main() -> None:
    lines: list[str] = []
    assert SRC_ABD.exists(), f"missing {SRC_ABD}"
    assert SRC_EXT.exists(), f"missing {SRC_EXT}"
    assert FLEXORA.exists(), f"missing {FLEXORA}"

    flex_before = sha256(FLEXORA)
    lines.append(f"FLEXORA_SHA_BEFORE={flex_before}")

    BACKUP.mkdir(parents=True, exist_ok=True)
    for dst in (DST_ABD, DST_EXT):
        if dst.exists():
            shutil.copy2(dst, BACKUP / dst.name)
            lines.append(f"BACKUP={dst.name} bytes={dst.stat().st_size}")

    to_jpeg(SRC_ABD, DST_ABD)
    to_jpeg(SRC_EXT, DST_EXT)

    flex_after = sha256(FLEXORA)
    lines.append(f"FLEXORA_SHA_AFTER={flex_after}")
    lines.append(f"FLEXORA_UNCHANGED={flex_before == flex_after}")
    lines.append(f"ABD_BYTES={DST_ABD.stat().st_size} sha={sha256(DST_ABD)}")
    lines.append(f"EXT_BYTES={DST_EXT.stat().st_size} sha={sha256(DST_EXT)}")
    lines.append(f"SRC_ABD_BYTES={SRC_ABD.stat().st_size}")
    lines.append(f"SRC_EXT_BYTES={SRC_EXT.stat().st_size}")
    lines.append("DONE")
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
