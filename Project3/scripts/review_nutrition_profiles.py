"""Run five offline test profiles and check nutritional plausibility gates.

These scenario gates are test assumptions, not clinical target recommendations.
Run from Project3: python scripts/review_nutrition_profiles.py --dart path/to/dart
"""

import argparse
import csv
import json
import subprocess
from pathlib import Path


CATALOG = Path("test/fixtures/nutrition_catalog_100.csv")
PROFILES = Path("test/fixtures/nutrition_profiles")


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def run_profile(dart, filename):
    request = PROFILES / filename
    completed = subprocess.run(
        [dart, "scripts/nutrition_cli.dart", "--catalog", str(CATALOG),
         "--request", str(request)],
        check=True, capture_output=True, text=True,
    )
    return json.loads(completed.stdout)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dart", default="dart")
    args = parser.parse_args()
    with CATALOG.open(newline="", encoding="utf-8") as file:
        foods = list(csv.DictReader(file))
    require(len(foods) == 100, "Catalog must have exactly 100 foods")
    require(len({food["upc"] for food in foods}) == 100, "Duplicate food ID")
    for food in foods:
        require(food["sourceUrl"].startswith("https://fdc.nal.usda.gov/"),
                f"Missing USDA provenance: {food['upc']}")
        require("fped-databases" in food["addedSugarSourceUrl"],
                f"Missing added-sugar provenance: {food['upc']}")
        require(all(food[key] for key in ("servingGrams", "calories",
                  "proteinGrams", "fiberGrams", "sodiumMg",
                  "saturatedFatGrams", "addedSugarGrams")),
                f"Missing key nutrient: {food['upc']}")
    priced = [food for food in foods if food["pricePerServing"]]
    require(len(priced) == 5, "Expected five sourced price observations")
    require(all(food["priceSourceUrl"].startswith("https://") for food in priced),
            "A price observation lacks provenance")

    results = {
        stem: run_profile(args.dart, f"test_{stem}.json")
        for stem in ("privacy", "bodybuilding", "fat_loss",
                     "money_saving", "pregnant")
    }
    privacy = results["privacy"]
    require(privacy["mealIdeas"] and not privacy["blockedReason"],
            "Privacy profile needs a food combination")
    meal = privacy["mealIdeas"][0]
    require(350 <= meal["calories"] <= 750 and meal["proteinGrams"] >= 15,
            "Privacy top choice is too small or low in protein for this scenario")
    require(meal["sodiumMg"] <= 800,
            "Privacy top choice has too much sodium for this scenario")
    require(meal["targetSource"] is None, "Privacy mode used a personal target")

    bodybuilding = results["bodybuilding"]
    require(bodybuilding["mealIdeas"], "Bodybuilding profile needs a meal")
    meal = bodybuilding["mealIdeas"][0]
    require(720 <= meal["calories"] <= 1080,
            "Bodybuilding meal misses the illustrative energy range")
    require(meal["proteinGrams"] >= 40,
            "Bodybuilding meal misses 80% of per-meal protein target")
    require(meal["sodiumMg"] <= 2300 / 3 * 1.25,
            "Bodybuilding meal spends too much of sodium budget")
    require(all("Cereal" not in p["name"] for p in meal["products"]),
            "Sweet cereal paired with savory chicken")

    fat_loss = results["fat_loss"]
    require(fat_loss["mealIdeas"], "Fat-loss profile needs a meal")
    meal = fat_loss["mealIdeas"][0]
    require(360 <= meal["calories"] <= 720 and meal["proteinGrams"] >= 20,
            "Fat-loss meal misses illustrative energy/protein gates")
    require(meal["addedSugarGrams"] <= 10,
            "Fat-loss meal has too much estimated added sugar")
    require("FDC1101707" in meal["replacedBasketUpcs"],
            "High-sugar cereal was retained instead of swapped")

    money = results["money_saving"]
    require(len(money["mealIdeas"]) >= 2, "Budget profile needs two priced choices")
    cheapest, alternative = money["mealIdeas"][:2]
    require(cheapest["pricePerServing"] < alternative["pricePerServing"] <= 1.5,
            "Budget mode did not prioritize the less costly comparable meal")
    require(350 <= cheapest["calories"] <= 750 and
            cheapest["proteinGrams"] >= 15 and cheapest["sodiumMg"] <= 960,
            "Cheaper meal failed nutrition plausibility gates")
    require(all(p["priceSource"] for p in cheapest["products"]),
            "Budget recommendation did not expose price sources")
    pregnant = results["pregnant"]
    require(not pregnant["mealIdeas"] and pregnant["blockedReason"],
            "Unsafe pregnancy weight plan was not blocked")

    catalog_by_id = {food["upc"]: food for food in foods}
    for profile, result in results.items():
        for idea in result["mealIdeas"]:
            require(all(catalog_by_id[p["upc"]]["mealCandidate"] == "true"
                        for p in idea["products"]),
                    f"Unsuitable food entered {profile} meal")
            require(all(evidence["url"].startswith("https://")
                        for evidence in idea["evidence"]),
                    f"Missing citation in {profile}")
        if result["mealIdeas"]:
            top = result["mealIdeas"][0]
            names = " + ".join(p["name"] for p in top["products"])
            print(f"{profile}: {names} | {top['calories']:.0f} kcal, "
                  f"{top['proteinGrams']:.0f} g protein, "
                  f"{top['sodiumMg']:.0f} mg sodium")
        else:
            print(f"{profile}: abstained ({result['blockedReason']})")
    print("Five-profile review gates passed (100 sourced USDA foods).")


if __name__ == "__main__":
    main()
