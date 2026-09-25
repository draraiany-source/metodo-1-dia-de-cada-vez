"""Conta distribuição visual neon do catálogo (espelha treinoVisualLookOf)."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "assets/content/treinos_catalogo_oficial.json"


def norm(v: str | None) -> str:
    s = (v or "").lower()
    for a, b in {
        "á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u",
        "ã": "a", "õ": "o", "ç": "c",
    }.items():
        s = s.replace(a, b)
    return s


def has(hay: str, keys: list[str]) -> bool:
    return any(norm(k) in hay for k in keys)


def classify(item: dict) -> tuple[str, str]:
    """Retorna (source, label)."""
    cat = norm(item.get("categoria") or item.get("category") or "")
    grupo = norm(item.get("grupoMuscular") or item.get("grupo") or "")
    nome = norm(item.get("nome") or item.get("name") or item.get("titulo") or "")
    hay = f"{cat} {grupo} {nome}"

    rules_ex = [
        (["burpee"], "Burpee"),
        (["polichinelo", "jumping jack"], "Polichinelo"),
        (["kettle", "swing"], "Kettlebell"),
        (["hip thrust", "elevacao pelvica"], "Hip thrust"),
        (["leg press"], "Leg press"),
        (["mesa flexora", "flexora"], "Mesa flexora"),
        (["extensora", "extensao de perna"], "Extensora"),
        (["agachamento sumo", "sumo"], "Agachamento sumo"),
        (["agachamento com barra"], "Agachamento"),
        (["agacha"], "Agachamento"),
        (["afundo", "passada", "lunge"], "Afundo"),
        (["panturrilha", "gemeo"], "Panturrilha"),
        (["elevacao de perna"], "Elevação de pernas"),
        (["rosca"], "Rosca"),
        (["triceps na polia"], "Tríceps polia"),
        (["triceps", "coice", "frances"], "Tríceps"),
        (["kickback"], "Kickback"),
        (["elevacao lateral"], "Elevação lateral"),
        (["supino"], "Peito"),
        (["remada"], "Remada"),
        (["puxada", "pulldown"], "Puxada"),
        (["flexao", "push-up", "push up"], "Flexão"),
        (["prancha", "plank"], "Prancha"),
    ]
    for keys, label in rules_ex:
        if has(hay, keys):
            return "exercise", label

    rules_cat = [
        (["esteira"], "Esteira"),
        (["bike", "bicicleta", "spinning"], "Bike"),
        (["caminhada", "walk"], "Caminhada"),
        (["corrida", "running"], "Corrida"),
        (["hiit", "tabata"], "HIIT"),
        (["along"], "Alongamento"),
        (["abdomen", "abdominal", "core"], "Abdômen"),
        (["peitoral", "peito"], "Peito"),
        (["costas", "dorsal"], "Costas"),
        (["ombro"], "Ombro"),
        (["biceps"], "Bíceps"),
        (["gluteo"], "Glúteo"),
        (["quadriceps"], "Quadríceps"),
        (["funcional"], "Funcional"),
    ]
    for keys, label in rules_cat:
        if has(hay, keys):
            if label == "Corrida" and has(hay, ["caminhada"]):
                continue
            return "category", label

    if has(hay, ["cardio"]) and not has(hay, ["hipertrofia"]):
        return "category", "Cardio"
    if has(hay, ["hipertrofia", "muscul"]):
        return "category", "Musculação"
    return "placeholder", "Treino"


def main() -> None:
    raw = json.loads(CATALOG.read_text(encoding="utf-8"))
    items = raw if isinstance(raw, list) else raw.get("treinos") or raw.get("items") or []
    counts = {"exercise": 0, "category": 0, "placeholder": 0}
    labels: dict[str, int] = {}
    for it in items:
        src, label = classify(it if isinstance(it, dict) else {})
        counts[src] += 1
        labels[label] = labels.get(label, 0) + 1
    print("TOTAL", len(items))
    print("SPECIFIC_EXERCISE", counts["exercise"])
    print("CATEGORY_FALLBACK", counts["category"])
    print("PLACEHOLDER", counts["placeholder"])
    print("BY_LABEL", dict(sorted(labels.items(), key=lambda x: -x[1])[:25]))


if __name__ == "__main__":
    main()
