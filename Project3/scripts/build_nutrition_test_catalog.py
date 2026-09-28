"""Build a reproducible test catalog from matching USDA FNDDS and FPED files.

Requires: pip install xlrd
Inputs: FoodData Central survey JSON ZIP (2021-10-28), FPED_1718.xls.
The output is a simulation catalog, not a WIC approved product list.
"""

import argparse
import csv
import json
import re
import zipfile

import xlrd


GROUPS = [
    ("fruit", "Citrus fruits", 6),
    ("fruit", "Other fruits and fruit salads", 5),
    ("fruit", "Peaches and nectarines", 5),
    ("vegetable", "Carrots", 4),
    ("vegetable", "Other red and orange vegetables", 5),
    ("vegetable", "Other dark green vegetables", 5),
    ("vegetable", "String beans", 5),
    ("vegetable", "Other vegetables and combinations", 5),
    ("protein", "Beans, peas, legumes", 5),
    ("protein", "Chicken, whole pieces", 5),
    ("protein", "Fish", 5),
    ("protein", "Eggs and omelets", 5),
    ("protein", "Nuts and seeds", 5),
    ("protein", "Pork", 5),
    ("protein", "Turkey, duck, other poultry", 5),
    ("grain", "Pasta, noodles, cooked grains", 5),
    ("grain", "Rice", 5),
    ("grain", "Yeast breads", 5),
    ("grain", "Ready-to-eat cereal, lower sugar (=<21.2g/100g)", 5),
    ("grain", "Ready-to-eat cereal, higher sugar (>21.2g/100g)", 5),
]

NUTRIENTS = {
    "calories": 1008,
    "proteinGrams": 1003,
    "fiberGrams": 1079,
    "sodiumMg": 1093,
    "saturatedFatGrams": 1258,
}

UNSUITABLE_PRODUCE = {
    "Lemon, raw",
    "Lime, raw",
    "Tamarind",
    "Ambrosia",
    "Alfalfa sprouts, raw",
}

FORCED_NAMES = {
    "Carrots": ["Carrots, raw", "Carrots, fresh, cooked, no added fat"],
    "Other red and orange vegetables": [
        "Sweet potato, baked, peel eaten, no added fat",
        "Winter squash, cooked, no added fat",
    ],
    "Other dark green vegetables": [
        "Collards, fresh, cooked, no added fat",
        "Kale, fresh, cooked, no added fat",
    ],
    "String beans": ["Green beans, fresh, cooked, no added fat"],
    "Other vegetables and combinations": [
        "Peas and carrots, fresh, cooked, no added fat",
        "Avocado, raw",
    ],
    "Beans, peas, legumes": [
        "White beans, from dried, no added fat",
        "Black beans, from canned, reduced sodium",
    ],
    "Chicken, whole pieces": [
        "Chicken breast, baked, broiled, or roasted, skin not eaten, from raw",
        "Chicken breast, grilled without sauce, skin not eaten",
    ],
    "Fish": ["Cod, baked or broiled, no added fat"],
    "Eggs and omelets": ["Egg, whole, boiled or poached "],
    "Turkey, duck, other poultry": [
        "Turkey, light meat, roasted, skin not eaten"
    ],
    "Pasta, noodles, cooked grains": [
        "Bulgur, no added fat",
        "Quinoa, no added fat",
    ],
    "Rice": ["Rice, brown, cooked, no added fat"],
    "Yeast breads": ["Bread, whole wheat", "Bread, pita, whole wheat"],
}


def portion_grams(group, category, description):
    if category == "Nuts and seeds":
        return 30
    if category == "Beans, peas, legumes":
        if "from canned" in description:
            return 150
        return 180
    if category == "Eggs and omelets":
        return 100
    if "cereal" in category.lower():
        return 40
    if category == "Yeast breads":
        return 80
    if group == "grain":
        return 150
    if group == "protein":
        return 120
    return 100


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fndds-zip", required=True)
    parser.add_argument("--fped-xls", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--price-overlay")
    args = parser.parse_args()

    with zipfile.ZipFile(args.fndds_zip) as archive:
        foods = json.load(archive.open(archive.namelist()[0]))["SurveyFoods"]
    sheet = xlrd.open_workbook(args.fped_xls).sheet_by_name("FPED_1718")
    headers = sheet.row_values(0)
    sugar_index = headers.index("ADD_SUGARS (tsp. eq.)")
    fped = {
        int(sheet.cell_value(i, 0)): float(sheet.cell_value(i, sugar_index))
        for i in range(1, sheet.nrows)
    }
    prices = {}
    if args.price_overlay:
        with open(args.price_overlay, newline="", encoding="utf-8") as file:
            prices = {row["upc"]: row for row in csv.DictReader(file)}

    rows = []
    for group, category, count in GROUPS:
        candidates = []
        for food in foods:
            food_category = (food.get("wweiaFoodCategory") or {}).get(
                "wweiaFoodCategoryDescription"
            )
            description = food["description"]
            if food_category != category or re.search(r"\b(NFS|NS as)\b", description):
                continue
            if int(food["foodCode"]) not in fped:
                continue
            nutrients = {
                entry["nutrient"]["id"]: entry["amount"]
                for entry in food["foodNutrients"]
                if "amount" in entry
            }
            if any(key not in nutrients for key in NUTRIENTS.values()):
                continue
            candidates.append((food, nutrients))
        # Spread selections across the category instead of taking near-duplicate
        # records clustered by food code. The result is deterministic.
        candidates.sort(key=lambda pair: pair[0]["description"])
        if len(candidates) < count:
            raise ValueError(f"Only {len(candidates)} usable foods in {category}")
        forced = FORCED_NAMES.get(category, [])
        selected = [pair for name in forced for pair in candidates
                    if pair[0]["description"] == name]
        if len(selected) != len(forced):
            raise ValueError(f"Missing forced food in {category}")
        remaining = [pair for pair in candidates if pair not in selected]
        needed = count - len(selected)
        if needed == 1:
            selected.append(remaining[len(remaining) // 2])
        elif needed > 1:
            selected.extend(remaining[round(i * (len(remaining) - 1) / (needed - 1))]
                            for i in range(needed))
        for food, nutrients in selected:
            description = food["description"]
            grams = portion_grams(group, category, description)
            scale = grams / 100
            added_sugar = round(fped[int(food["foodCode"])] * 4.2 * scale, 2)
            reason = ""
            if description in UNSUITABLE_PRODUCE:
                reason = "Requires a different portion or food-safety review"
            elif "Shark," in description:
                reason = "Fish choice requires mercury/life-stage review"
            elif description in {"Collards, raw", "Mustard greens, raw",
                                 "Winter squash, raw"}:
                reason = "Not a practical standalone produce portion here"
            elif "in syrup" in description.lower():
                reason = "Syrup-packed fruit is not a preferred produce side"
            elif group == "protein" and category == "Nuts and seeds":
                reason = "A small nuts/seeds portion is not a protein anchor"
            elif group == "protein" and nutrients[1003] * scale < 10:
                reason = "Less than 10 g protein in this scenario portion"
            elif "cereal" in category.lower() and added_sugar > 10:
                reason = "Over 10 g estimated added sugar in this scenario portion"
            row = {
                "upc": f"FDC{food['fdcId']}",
                "name": food["description"],
                "foodGroup": group,
                "category": category,
                "eligible": "true",  # Candidate for simulation only; WIC status unknown.
                "servingGrams": grams,
                **{
                    name: round(nutrients[code] * scale, 2)
                    for name, code in NUTRIENTS.items()
                },
                "addedSugarGrams": added_sugar,
                "sourceUrl": f"https://fdc.nal.usda.gov/food-details/{food['fdcId']}/nutrients",
                "addedSugarSourceUrl": "https://www.ars.usda.gov/northeast-area/beltsville-md-bhnrc/beltsville-human-nutrition-research-center/food-surveys-research-group/docs/fped-databases/",
                "portionBasis": "Scenario portion; USDA nutrients are per 100 g",
                "mealCandidate": str(not reason).lower(),
                "candidateNote": reason,
                "mealStyle": "sweet" if "cereal" in category.lower()
                             else "savory" if group != "fruit" else "neutral",
                "pricePerServing": prices.get(f"FDC{food['fdcId']}", {}).get(
                    "pricePerServing", ""),
                "priceObservedAt": prices.get(f"FDC{food['fdcId']}", {}).get(
                    "priceObservedAt", ""),
                "priceSourceUrl": prices.get(f"FDC{food['fdcId']}", {}).get(
                    "priceSourceUrl", ""),
                "priceMappingNote": prices.get(f"FDC{food['fdcId']}", {}).get(
                    "priceMappingNote", ""),
            }
            rows.append(row)

    if len(rows) != 100 or len({row["upc"] for row in rows}) != 100:
        raise ValueError("Expected 100 unique foods")
    with open(args.output, "w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)
    print(f"Wrote {len(rows)} USDA survey foods to {args.output}")


if __name__ == "__main__":
    main()
