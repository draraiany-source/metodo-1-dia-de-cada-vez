
from pathlib import Path
p = Path(r"lib/features/workouts/presentation/workout_detail_screen.dart")
t = p.read_text(encoding="utf-8")
old = """                  else
                    WorkoutCoverImage(
                      workout: workout,
                      fit: BoxFit.cover,
                      fallbackIconSize: wide ? 110 : 88,
                    ),"""
new = """                  else
                    ColoredBox(
                      color: const Color(0xFF0A0A0F),
                      child: LilyTreinoImage.forExercise(
                        exercise.name,
                        maxHeight: wide ? 260 : 220,
                        alignment: Alignment.center,
                        genericSeed: index,
                      ),
                    ),"""
if old not in t:
    # try CRLF
    old2 = old.replace("\n", "\r\n")
    new2 = new.replace("\n", "\r\n")
    if old2 in t:
        t = t.replace(old2, new2, 1)
        print("replaced CRLF player cover")
    else:
        print("OLD NOT FOUND")
        idx = t.find("WorkoutCoverImage")
        print("first WorkoutCoverImage at", idx)
        print(repr(t[t.find("else", idx-80):idx+200]) if idx>0 else "none")
else:
    t = t.replace(old, new, 1)
    print("replaced LF player cover")

# Also soft-update _Hero to prefer Lily by workout title (contain, black bg)
old_hero = """    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: wide ? 21 / 9 : 16 / 10,
        child: WorkoutCoverImage(
          workout: workout,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          fallbackIconSize: wide ? 120 : 96,
        ),
      ),
    );"""
new_hero = """    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: wide ? 21 / 9 : 16 / 10,
        child: ColoredBox(
          color: const Color(0xFF0A0A0F),
          child: LilyTreinoImage.forExercise(
            workout.title,
            maxHeight: wide ? 220 : 200,
            alignment: Alignment.center,
            genericSeed: workout.title.hashCode,
          ),
        ),
      ),
    );"""
if old_hero in t:
    t = t.replace(old_hero, new_hero, 1)
    print("hero updated LF")
elif old_hero.replace("\n","\r\n") in t:
    t = t.replace(old_hero.replace("\n","\r\n"), new_hero.replace("\n","\r\n"), 1)
    print("hero updated CRLF")
else:
    print("hero pattern not found (ok if already changed)")

if "lily_treino_image.dart" not in t:
    t = t.replace(
        "import 'workout_category_visual.dart';",
        "import '../../../core/lily/lily_treino_image.dart';\nimport 'workout_category_visual.dart';",
    )
# assets import may already be there from previous
p.write_text(t, encoding="utf-8")
print("saved workout_detail")
