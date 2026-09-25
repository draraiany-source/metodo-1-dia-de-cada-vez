from pathlib import Path
root = Path(r"C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2")
for rel in [
    "lib/features/workouts/presentation/treino_catalog_visual.dart",
    "pubspec.yaml",
]:
    p = root / rel
    b = p.read_bytes()
    if b.startswith(b"\xef\xbb\xbf"):
        p.write_bytes(b[3:])
        print("stripped", rel)
    else:
        print("clean", rel)
