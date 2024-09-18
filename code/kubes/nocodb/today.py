#!/usr/bin/env python3

import http.client
import json
import os
import urllib.parse

# Reference Daily Intake
RDI_TABLE = "mamm9dpys1j1znw"

# Ingredients (per 100g)
INGREDIENTS_TABLE = "m0zj43gvvzeqxqz"

# Dishes (ingredients, but in actual weight when put on a plate)
DISHES_TABLE = "m5ddsw6b8q0jn55"

# Meals (dated collections of dishes)
MEALS_TABLE = "mohjrlr1l7et77g"
MEALS_VIEW_TODAY = "vwpckbejvg1mbifx"
MEALS_LINK_DISHES = "cc9wqhoe8nfb18o"


def process_nutrients(rdi, ingredient):
    """Compute all nutrients for an ingredient based on the amount."""
    nutrients = {}
    ingredient_amount = ingredient["Amount (g)"]
    for k, v in ingredient.items():
        if v is None or k in ("Amount (g)", "Name"):
            nutrients[k] = v
        elif k in rdi:
            amount = v / 100 * ingredient_amount
            nutrients[k] = {"Amount": amount, "RDI": amount / rdi[k]["Amount"]}
    return nutrients


def sum_amounts(total, dishes):
    """Sum up all the amounts and RDI values of all nutrients to a total."""
    for dish in dishes:
        for k, v in dish.items():
            if isinstance(v, dict):
                if k not in total:
                    total[k] = {"Amount": 0, "RDI": 0}
                total[k]["Amount"] += v["Amount"]
                total[k]["RDI"] += v["RDI"]


def compute_total(dishes):
    """Create a new Total dish and add it to the end of the dishes."""
    total = {"Name": "Total", "Amount (g)": None}
    sum_amounts(total, dishes)
    return dishes + (total,)


class HealthDb:
    def __init__(self):
        self.conn = http.client.HTTPSConnection("nocodb.xinutec.org")
        self.headers = {'xc-token': os.environ["NOCODB_TOKEN"]}

    def get(self, url: str):
        """GET a URL and JSON-decode the success-response."""
        self.conn.request("GET", url, headers=self.headers)

        res = self.conn.getresponse()
        return json.loads(res.read().decode("utf-8"))["list"]

    def list_table_records(self, table: str, view: str = "", fields: tuple[str] = tuple(), key: str = "Id"):
        """Retrieve records from a specified table/view, create a dict keyed by a given column."""
        fields_encoded = ",".join(map(urllib.parse.quote_plus, fields))
        return {
            rec[key]: rec
            for rec in self.get(
                f"/api/v2/tables/{table}/records?offset=0&limit=1000&viewId={view}&fields={fields_encoded}")
        }

    def list_linked_records(self, table: str, link_field_id: str, record_id: int, key: str = "Id"):
        """Retrieve list of linked records for a specific Link field and Record ID."""
        return {
            rec[key]: rec
            for rec in self.get(
                f"/api/v2/tables/{table}/links/{link_field_id}/records/{record_id}")
        }

    def today(self):
        """Compute nutrient intake for the current day."""
        rdi = self.list_table_records(RDI_TABLE, fields=("Nutrient", "Amount"), key="Nutrient")
        ingredients = self.list_table_records(INGREDIENTS_TABLE)
        dishes = self.list_table_records(DISHES_TABLE, fields=("Id", "Amount (g)", "Ingredient"))
        meals = self.list_table_records(MEALS_TABLE, view=MEALS_VIEW_TODAY)
        for mealId in tuple(meal["Id"] for meal in meals.values()):
            meals[mealId]["Dishes"] = tuple(process_nutrients(rdi, {
                "Amount (g)": dishes[k]["Amount (g)"],
                **ingredients[dishes[k]["Ingredient"]["Id"]]
            }) for k in self.list_linked_records(MEALS_TABLE, MEALS_LINK_DISHES, mealId).keys())
        table = {}
        for meal in meals.values():
            table[meal["Meal"]] = compute_total(meal["Dishes"])
        return table, next(iter(meals.values()))["Date"]


def format_amount(amount):
    """Render an amount or amount with RDI to string."""
    if isinstance(amount, dict):
        rdi = int(round(amount['RDI'] * 100, 0))
        return f"{round(amount['Amount'], 2):7} ({rdi:3}%)"
    elif isinstance(amount, int) or isinstance(amount, float):
        return f"{round(amount, 2):7}"
    else:
        return ""


def print_dishes(meal, dishes):
    print(f"\n## {meal}\n")
    keys = [k for k in dishes[0].keys() if k not in ("Name",)]
    padding = max(len(k) for k in keys)
    min_col_width = 14
    title = ("| " + " " * padding + " | " +
             " | ".join(f"{dish['Name']:{min_col_width}}"
                        for dish in dishes))
    print(title)
    print("| :" + "-" * (padding - 1) + " | " +
          " | ".join("-" * (max(len(dish["Name"]), min_col_width) - 1) + ":"
                     for dish in dishes))
    for k in keys:
        print(f"| {k:{padding}} | " +
              " | ".join(f"{format_amount(dish.get(k, None)):{max(len(dish['Name']), min_col_width)}}"
                         for dish in dishes))


def main():
    db = HealthDb()

    total = {"Name": "Total"}

    meals, date = db.today()
    print(f"# {date}")
    for meal, dishes in meals.items():
        print_dishes(meal, dishes)

        sum_amounts(total, (dish for dish in dishes if dish["Name"] == "Total"))

    print_dishes("Total", [total])


if __name__ == "__main__":
    main()
