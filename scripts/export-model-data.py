#!/usr/bin/env python3
"""Выгружает выборку модели подбора оружия в JSON для веб-приложения.

Модель: KNeighborsClassifier (elden_ring_weapon_best.json + label_encoder.joblib).
Веб-приложение умеет считать KNN само (src/ml/knn.js), но ему нужны объекты
обучающей выборки. Скрипт достаёт их из исходного датасета или из сохранённой
модели и пишет public/ml/weapon-dataset.json.

Запуск из корня проекта:
    python3 scripts/export-model-data.py
    python3 scripts/export-model-data.py --csv elden_ring_weapons.csv
    python3 scripts/export-model-data.py --model elden_ring_weapon_best.joblib

После появления файла подбор на странице «Помощник билдов» автоматически
переходит с базы оружия вики на обучающую выборку модели.
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_META = ROOT / "elden_ring_weapon_best.json"
DEFAULT_OUT = ROOT / "public" / "ml" / "weapon-dataset.json"

# Подписи столбцов, которые встречаются в выгрузке по характеристикам.
ALIASES = {
    "сила": "сила",
    "str": "сила",
    "strength": "сила",
    "ловкость": "ловкость",
    "dex": "ловкость",
    "dexterity": "ловкость",
    "мудрость": "мудрость",
    "int": "мудрость",
    "intel": "мудрость",
    "intelligence": "мудрость",
    "интеллект": "мудрость",
    "вера": "вера",
    "fai": "вера",
    "faith": "вера",
    "колдовство": "колдовство",
    "arc": "колдовство",
    "arcane": "колдовство",
    "архана": "колдовство",
}


def norm_key(value: str) -> str:
    return str(value).strip().lower().replace("ё", "е")


def load_meta(path: Path) -> dict:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def from_csv(path: Path, meta: dict) -> tuple[list[list[float]], list[str]]:
    features = meta.get("features") or ["сила", "ловкость", "мудрость", "вера", "колдовство"]
    target = meta.get("target") or "Название оружия"

    with path.open(encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        headers = reader.fieldnames or []
        by_norm = {norm_key(h): h for h in headers}

        columns = []
        for feature in features:
            source = by_norm.get(norm_key(feature)) or by_norm.get(ALIASES.get(norm_key(feature), ""))
            if source is None:
                raise SystemExit(f"В {path.name} нет столбца '{feature}'. Есть: {headers}")
            columns.append(source)

        name_column = by_norm.get(norm_key(target)) or by_norm.get(norm_key("weapon")) or by_norm.get(
            norm_key("name")
        )
        if name_column is None:
            # Целевой столбец обычно последний текстовый.
            numeric = set(columns)
            rest = [h for h in headers if h not in numeric]
            if not rest:
                raise SystemExit(f"Не удалось найти столбец с названием оружия в {path.name}")
            name_column = rest[-1]

        samples: list[list[float]] = []
        labels: list[str] = []
        for row in reader:
            try:
                vector = [float(str(row[c]).replace(",", ".").strip() or 0) for c in columns]
            except ValueError:
                continue
            label = str(row.get(name_column) or "").strip()
            if not label:
                continue
            samples.append(vector)
            labels.append(label)

    if not samples:
        raise SystemExit(f"В {path.name} не нашлось строк с числовыми характеристиками")
    return samples, labels


def from_model(path: Path, meta: dict) -> tuple[list[list[float]], list[str]]:
    try:
        import joblib  # noqa: PLC0415
    except ImportError as exc:  # pragma: no cover - зависит от окружения
        raise SystemExit("Для чтения .joblib нужен пакет joblib: pip install joblib scikit-learn") from exc

    model = joblib.load(path)
    model_classes = getattr(model, "classes_", None)
    classes = [str(c) for c in model_classes] if model_classes is not None and len(model_classes) else []
    if not classes:
        classes = [str(c) for c in (meta.get("classes") or [])]
    if not classes:
        raise SystemExit("В модели нет classes_ — укажите --csv с обучающей выборкой")

    vectors = getattr(model, "_fit_X", None)
    targets = getattr(model, "_y", None)
    if vectors is None or targets is None:
        raise SystemExit(
            f"{path.name} не содержит обученных соседей (_fit_X/_y). "
            "Выгрузите выборку из CSV: --csv elden_ring_weapons.csv"
        )

    samples = [[float(value) for value in row] for row in vectors]
    labels = [str(classes[int(index)]) for index in targets]
    return samples, labels


def main() -> int:
    parser = argparse.ArgumentParser(description="Выгрузка выборки KNN в JSON для веба")
    parser.add_argument("--csv", type=Path, help="обучающий датасет elden_ring_weapons.csv")
    parser.add_argument("--model", type=Path, help="сохранённая модель KNeighborsClassifier (.joblib/.pkl)")
    parser.add_argument("--meta", type=Path, default=DEFAULT_META, help="метаданные модели (JSON)")
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT, help="куда писать выборку")
    args = parser.parse_args()

    if not args.meta.exists():
        raise SystemExit(f"Не найден файл метаданных модели: {args.meta}")
    meta = load_meta(args.meta)

    csv_path = args.csv
    if csv_path is None:
        guess = ROOT / (meta.get("dataset_file") or "elden_ring_weapons.csv")
        csv_path = guess if guess.exists() else None

    model_path = args.model
    if model_path is None and csv_path is None:
        for name in ("elden_ring_weapon_best.joblib", "elden_ring_weapon_best.pkl", "model.joblib"):
            candidate = ROOT / name
            if candidate.exists():
                model_path = candidate
                break

    if csv_path:
        samples, labels = from_csv(Path(csv_path), meta)
        source = Path(csv_path).name
    elif model_path:
        samples, labels = from_model(Path(model_path), meta)
        source = Path(model_path).name
    else:
        candidates = ", ".join([str(ROOT / (meta.get("dataset_file") or "elden_ring_weapons.csv"))])
        raise SystemExit(
            "Не найдено ни обучающей выборки, ни сохранённой модели.\n"
            f"Положите рядом с проектом {candidates} или обученный файл модели и запустите:\n"
            "  python3 scripts/export-model-data.py --csv elden_ring_weapons.csv"
        )

    payload = {
        "model": meta.get("model"),
        "features": meta.get("features"),
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "source": source,
        "note": f"обучающая выборка модели: {len(samples)} объектов",
        "samples": samples,
        "labels": labels,
    }

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, ensure_ascii=False)

    try:
        shown = args.out.relative_to(ROOT)
    except ValueError:
        shown = args.out
    classes = len(set(labels))
    print(f"Готово: {shown} — {len(samples)} объектов, {classes} классов")
    return 0


if __name__ == "__main__":
    sys.exit(main())
