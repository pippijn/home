#!/usr/bin/env python3

import http.client
import json
import os
import urllib.parse

RDI_TABLE = "mamm9dpys1j1znw"

DISHES_TABLE = "m5ddsw6b8q0jn55"

MEALS_TABLE = "mohjrlr1l7et77g"
MEALS_VIEW_TODAY = "vwpckbejvg1mbifx"
MEALS_LINK_DISHES = "cc9wqhoe8nfb18o"

def process_nutrients(rdi, ingredient):
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
    for dish in dishes:
        for k, v in dish.items():
            if isinstance(v, dict):
                if k not in total:
                    total[k] = {"Amount": 0, "RDI": 0}
                total[k]["Amount"] += v["Amount"]
                total[k]["RDI"] += v["RDI"]


def compute_total(dishes):
    total = {"Name": "Total", "Amount (g)": None}
    sum_amounts(total, dishes)
    dishes.append(total)
    return dishes


class HealthDb:
    def __init__(self):
        self.conn = http.client.HTTPSConnection("nocodb.xinutec.org")
        self.headers = {'xc-token': os.environ["NOCODB_TOKEN"]}

    def get(self, url: str):
        self.conn.request("GET", url, headers=self.headers)

        res = self.conn.getresponse()
        return json.loads(res.read().decode("utf-8"))["list"]

    def list_table_records(self, table: str, view: str = "", fields: tuple[str] = tuple(), key: str = "Id"):
        return {
            rec[key]: rec
            for rec in self.get(f"/api/v2/tables/{table}/records?offset=0&limit=1000&viewId={view}&fields={','.join(map(urllib.parse.quote_plus, fields))}")
        }

    def list_linked_records(self, table: str, link_field_id: str, record_id: int, key: str = "Id"):
        return {rec[key]: rec for rec in self.get(f"/api/v2/tables/{table}/links/{link_field_id}/records/{record_id}")}

    def today(self):
        rdi = self.list_table_records(RDI_TABLE, fields=("Nutrient", "Amount"), key="Nutrient")
        dishes = self.list_table_records(DISHES_TABLE, fields=("Id", "Amount (g)", "nc_cupq___nc_m2m_8u3b_5gyns"))
        meals = self.list_table_records(MEALS_TABLE, view=MEALS_VIEW_TODAY)
        for mealId in [meal["Id"] for meal in meals.values()]:
            meals[mealId]["Dishes"] = [process_nutrients(rdi, {
                "Amount (g)": dishes[k]["Amount (g)"],
                **dishes[k]["nc_cupq___nc_m2m_8u3b_5gyns"][0]["Ingredients"]
            }) for k in self.list_linked_records(MEALS_TABLE, MEALS_LINK_DISHES, mealId).keys()]
        table = {}
        for meal in meals.values():
            table[meal["Meal"]] = compute_total(meal["Dishes"])
        return table


def format_amount(amount):
    if isinstance(amount, dict):
        rdi = int(round(amount['RDI'] * 100, 0))
        return f"{round(amount['Amount'], 2):7} ({rdi:3}%)"
    elif isinstance(amount, int):
        return f"{round(amount, 2):7}"
    else:
        return ""


def print_dishes(meal, dishes):
    print(f"\n## {meal}\n")
    keys = [k for k in dishes[0].keys() if k not in ("Name",)]
    padding = max(len(k) for k in keys)
    title = "| " + " " * padding + " | " + " | ".join(f"{dish['Name']:18}" for dish in dishes)
    print(title)
    print("| :" + "-" * (padding - 1) + " | " + " | ".join("-" * 17 + ":" for dish in dishes))
    for k in keys:
        print(f"| {k:{padding}} | " + " | ".join(f"{format_amount(dish.get(k, None)):18}" for dish in dishes))

db = HealthDb()

total = {"Name": "Total"}

for meal, dishes in db.today().items():
    print_dishes(meal, dishes)

    sum_amounts(total, (dish for dish in dishes if dish["Name"] == "Total"))

print_dishes("Total", [total])
