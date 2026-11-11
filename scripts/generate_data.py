"""
generate_data.py
Creates a realistic, synthetic Vendor Performance dataset and saves 4 RAW CSV files
into data/raw/. Some mistakes are added ON PURPOSE so we can practise cleaning later.
Run from the project root:  python scripts/generate_data.py
"""
import numpy as np
import pandas as pd
from pathlib import Path

# ------------------------------------------------------------------
# 0. SETUP
# ------------------------------------------------------------------
rng = np.random.default_rng(42)          # fixed seed -> same data every run
RAW_DIR = Path("data/raw")
RAW_DIR.mkdir(parents=True, exist_ok=True)

N_VENDORS = 25
N_ORDERS = 6000
START = pd.Timestamp("2024-01-01")       # data covers 24 months: 2024 and 2025

# ------------------------------------------------------------------
# 1. VENDORS table
# ------------------------------------------------------------------
categories = ["Electronics", "Packaging", "Raw Materials",
              "Logistics Supplies", "Office Supplies"]

vendor_names = [
    "Apex Circuits", "Nova Electronics", "Pixel Components", "VoltEdge Systems", "Zenith Micro",
    "BoxCraft Packaging", "PackRight Solutions", "GreenWrap Industries", "SafeSeal Containers", "CrateWorks",
    "SteelCore Metals", "PolyChem Materials", "TimberLine Supply", "AlloyHub Traders", "ResinPro Chemicals",
    "SwiftPallet Logistics", "RoadRunner Supplies", "CargoSafe Equipment", "LoadMaster Tools", "FleetMate Supplies",
    "PaperTrail Stationers", "OfficeNest Supplies", "InkWell Traders", "DeskPro Essentials", "BrightDesk Supplies",
]
cities = ["Delhi", "Mumbai", "Pune", "Bengaluru", "Chennai",
          "Kolkata", "Ahmedabad", "Hyderabad", "Jaipur", "Surat"]

vendors = pd.DataFrame({
    "vendor_id": [f"V{i:03d}" for i in range(1, N_VENDORS + 1)],
    "vendor_name": [name + " Pvt Ltd" for name in vendor_names],
    "category": [categories[i // 5] for i in range(N_VENDORS)],
    "city": rng.choice(cities, N_VENDORS),
    "payment_terms_days": rng.choice([15, 30, 45, 60], N_VENDORS),
    "contract_start_date": (pd.Timestamp("2019-01-01")
                            + pd.to_timedelta(rng.integers(0, 1800, N_VENDORS), unit="D")),
    "status": "Active",
})
inactive_idx = rng.choice(N_VENDORS, 3, replace=False)       # 3 vendors stopped working with us
vendors.loc[inactive_idx, "status"] = "Inactive"

# Hidden "personality" of each vendor (NOT saved to any file; we must discover it with analysis)
size_weight = rng.lognormal(0, 0.9, N_VENDORS)               # big vendors get many more orders
vendor_prob = size_weight / size_weight.sum()
late_prob = rng.uniform(0.05, 0.35, N_VENDORS)               # chance a delivery is late
defect_rate = rng.uniform(0.005, 0.06, N_VENDORS)            # share of faulty items
promised_days = rng.integers(5, 21, N_VENDORS)               # promised lead time in days
is_inactive = (vendors["status"] == "Inactive").to_numpy()

# ------------------------------------------------------------------
# 2. PRODUCTS table
# ------------------------------------------------------------------
product_names = [
    "Control Board", "Sensor Module", "Power Adapter", "LED Panel",
    "Corrugated Box", "Bubble Wrap Roll", "Packing Tape", "Pallet Wrap",
    "Steel Sheet", "Plastic Granules", "Wood Plank", "Industrial Resin",
    "Wooden Pallet", "Strapping Band", "Safety Label", "Cargo Net",
    "A4 Paper Ream", "Printer Cartridge", "Notebook Pack", "Marker Set",
]
price_range = {"Electronics": (800, 3000), "Packaging": (20, 150), "Raw Materials": (300, 1500),
               "Logistics Supplies": (50, 400), "Office Supplies": (100, 600)}

products = pd.DataFrame({
    "product_id": [f"P{i:03d}" for i in range(1, 21)],
    "product_name": product_names,
    "category": [categories[i // 4] for i in range(20)],
})
products["base_price"] = [int(rng.integers(*price_range[c])) for c in products["category"]]

# ------------------------------------------------------------------
# 3. PURCHASE_ORDERS table
# ------------------------------------------------------------------
v_idx = rng.choice(N_VENDORS, size=N_ORDERS, p=vendor_prob)
p_idx = (v_idx // 5) * 4 + rng.integers(0, 4, N_ORDERS)      # product from the vendor's own category

# Inactive vendors only have orders during 2024
day_offset = np.where(is_inactive[v_idx],
                      rng.integers(0, 366, N_ORDERS),
                      rng.integers(0, 731, N_ORDERS))
order_date = START + pd.to_timedelta(day_offset, unit="D")
expected_date = order_date + pd.to_timedelta(promised_days[v_idx], unit="D")

quantity = np.clip(rng.lognormal(4.5, 0.8, N_ORDERS), 10, 1500).astype(int)
unit_price = np.round(products["base_price"].to_numpy()[p_idx] * rng.uniform(0.9, 1.1, N_ORDERS), 2)

po = pd.DataFrame({
    "po_id": [f"PO{i:06d}" for i in range(1, N_ORDERS + 1)],
    "vendor_id": vendors["vendor_id"].to_numpy()[v_idx],
    "product_id": products["product_id"].to_numpy()[p_idx],
    "order_date": order_date,
    "expected_delivery_date": expected_date,
    "quantity_ordered": quantity,
    "unit_price": unit_price,
    "total_amount": np.round(quantity * unit_price, 2),
    "po_status": np.where(rng.random(N_ORDERS) < 0.03, "Cancelled", "Delivered"),
})

# ------------------------------------------------------------------
# 4. DELIVERIES table (only for orders that were delivered)
# ------------------------------------------------------------------
d = po[po["po_status"] == "Delivered"].copy()
vidx_d = d["vendor_id"].str[1:].astype(int).to_numpy() - 1    # V001 -> 0

is_late = rng.random(len(d)) < late_prob[vidx_d]
delay_days = np.where(is_late, rng.integers(1, 11, len(d)), rng.integers(-3, 1, len(d)))
received = np.where(rng.random(len(d)) < 0.05,
                    (d["quantity_ordered"] * 0.95).astype(int),   # 5% of deliveries are short
                    d["quantity_ordered"])

deliveries = pd.DataFrame({
    "delivery_id": [f"D{i:06d}" for i in range(1, len(d) + 1)],
    "po_id": d["po_id"].to_numpy(),
    "actual_delivery_date": d["expected_delivery_date"].to_numpy() + pd.to_timedelta(delay_days, unit="D"),
    "quantity_received": received,
    "quantity_defective": rng.binomial(received, defect_rate[vidx_d]),
})

# ------------------------------------------------------------------
# 5. ADD REALISTIC MESS (so Phase 2 cleaning has real work to do)
# ------------------------------------------------------------------
# 5a. vendors: inconsistent names + missing cities
i = rng.choice(N_VENDORS, 6, replace=False)
vendors.loc[i[0], "vendor_name"] = vendors.loc[i[0], "vendor_name"].upper()
vendors.loc[i[1], "vendor_name"] = "  " + vendors.loc[i[1], "vendor_name"] + "  "
vendors.loc[i[2], "vendor_name"] = vendors.loc[i[2], "vendor_name"].replace("Pvt Ltd", "Pvt. Ltd.")
vendors.loc[i[3], "vendor_name"] = vendors.loc[i[3], "vendor_name"].lower()
vendors.loc[i[4:6], "city"] = np.nan

# 5b. purchase_orders: missing prices, bad quantities, outliers
bad = rng.choice(len(po), 40 + 12 + 10, replace=False)
po.loc[bad[:40], "unit_price"] = np.nan                      # 40 missing unit prices
po.loc[bad[40:52], "quantity_ordered"] *= -1                 # 12 negative quantities
po.loc[bad[52:], "quantity_ordered"] *= 50                   # 10 extreme outliers

# 5c. purchase_orders: mixed date formats (8% of rows use DD-MM-YYYY)
for col in ["order_date", "expected_delivery_date"]:
    iso = po[col].dt.strftime("%Y-%m-%d")
    dmy = po[col].dt.strftime("%d-%m-%Y")
    po[col] = np.where(rng.random(len(po)) < 0.08, dmy, iso)

# 5d. purchase_orders: 60 exact duplicate rows, then shuffle
po = pd.concat([po, po.sample(60, random_state=42)]).sample(frac=1, random_state=42)

# 5e. deliveries: missing delivery dates, defective > received
deliveries["actual_delivery_date"] = deliveries["actual_delivery_date"].dt.strftime("%Y-%m-%d")
miss = rng.choice(len(deliveries), 20, replace=False)
deliveries.loc[miss, "actual_delivery_date"] = np.nan
wrong = rng.choice(len(deliveries), 10, replace=False)
deliveries.loc[wrong, "quantity_defective"] = deliveries.loc[wrong, "quantity_received"] + 5

# ------------------------------------------------------------------
# 6. SAVE
# ------------------------------------------------------------------
vendors.to_csv(RAW_DIR / "vendors.csv", index=False)
products.to_csv(RAW_DIR / "products.csv", index=False)
po.to_csv(RAW_DIR / "purchase_orders.csv", index=False)
deliveries.to_csv(RAW_DIR / "deliveries.csv", index=False)

print("Raw files created in", RAW_DIR)
print("vendors:         ", vendors.shape)
print("products:        ", products.shape)
print("purchase_orders: ", po.shape)
print("deliveries:      ", deliveries.shape)