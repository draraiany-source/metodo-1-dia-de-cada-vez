from pathlib import Path
p = Path(r"lib/features/nutrition/presentation/hydration_screen.dart")
t = p.read_text(encoding="utf-8")
# Replace Icon in empty history with AppIconImage bottle - find unique marker
old = """          Icon(Icons.water_drop_outlined,
              color: AppColors.textTertiary, size: 28),"""
new = """          AppIconImage(
            AppIcons.hydrationBottle,
            size: 48,
            fit: BoxFit.contain,
            fallbackIcon: Icons.water_drop_outlined,
          ),"""
if old in t:
    t = t.replace(old, new)
    # Column cannot be const if AppIconImage is not const - remove const before Column in EmptyHistory
    t = t.replace(
        """      child: const Column(
        children: [
          AppIconImage(
            AppIcons.hydrationBottle,""",
        """      child: Column(
        children: [
          AppIconImage(
            AppIcons.hydrationBottle,""",
    )
    # make following Text widgets const explicitly if needed - they may already be without const keyword under const Column
    print("empty history icon updated")
else:
    print("old icon pattern not found")

# Also update first-copo hint if present
t = t.replace(
    "Adicione seu primeiro copo para começar.",
    "Use os atalhos 200, 300 ou 500 ml para começar.",
)
p.write_text(t, encoding="utf-8")
print("quickMl", "[200, 300, 500]" in p.read_text(encoding="utf-8"))
