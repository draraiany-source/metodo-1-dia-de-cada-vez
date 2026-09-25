from pathlib import Path
p = Path(r"lib/core/widgets/lili_widgets.dart")
t = p.read_text(encoding="utf-8")
old = """String _mascoteAsset(MascotePose pose) {
  if (MascotConfig.useNewMascot) {
    return MascotAssets.resolve(pose);
  }
  return switch (pose) {"""
# Check actual content
idx = t.find("String _mascoteAsset")
print(repr(t[idx:idx+350]))
