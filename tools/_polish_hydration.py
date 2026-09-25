from pathlib import Path
p = Path(r"lib/features/nutrition/presentation/hydration_screen.dart")
t = p.read_text(encoding="utf-8")
t2 = t.replace(
    "static const _quickMl = [150, 200, 250, 300, 500];",
    "static const _quickMl = [200, 300, 500];",
)
# Use check icon for history confirmation feel
t2 = t2.replace(
    """          child: AppIconImage(
            AppIcons.hydrationGlass,
            size: 20,
            fit: BoxFit.contain,
            fallbackIcon: Icons.water_drop_rounded,
          ),""",
    """          child: AppIconImage(
            AppIcons.hydrationCheck,
            size: 22,
            fit: BoxFit.contain,
            fallbackIcon: Icons.water_drop_rounded,
          ),""",
)
# Clearer empty state with neon bottle icon
if "AppIcons.hydrationBottle" not in t2.split("_EmptyHistory")[1][:800]:
    t2 = t2.replace(
        """          child: const Column(
        children: [
          Icon(Icons.water_drop_outlined,
              color: AppColors.textTertiary, size: 28),
          SizedBox(height: 10),
          Text(
            'Ainda não há registros de água hoje.',""",
        """          child: Column(
        children: [
          AppIconImage(
            AppIcons.hydrationBottle,
            size: 48,
            fit: BoxFit.contain,
            fallbackIcon: Icons.water_drop_outlined,
          ),
          const SizedBox(height: 10),
          const Text(
            'Ainda não há registros de água hoje.',""",
    )
    # fix const Text siblings - need to add const to following texts or remove const from Column - already did Column non-const
    t2 = t2.replace(
        """          const SizedBox(height: 4),
          Text(
            'Adicione seu primeiro copo para começar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}""",
        """          const SizedBox(height: 4),
          const Text(
            'Use os atalhos 200, 300 ou 500 ml para começar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}""",
    )

# Ensure history section title mentions lista vertical
if "Histórico do dia" in t2:
    pass
else:
    print("no Histórico do dia title - check")

p.write_text(t2, encoding="utf-8")
print("hydration updated", "200/300/500" in t2 or "[200, 300, 500]" in t2)
# verify syntax-ish
print("quickMl line:", [l for l in t2.splitlines() if "_quickMl" in l][0])
