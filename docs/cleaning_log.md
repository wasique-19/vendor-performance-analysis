# Cleaning Log: Vendor Performance Analysis

This log records every data quality problem found in the raw data, what was done about it, and why. Raw files in `data/raw/` are never edited. All fixes are done in Python (`notebooks/03_cleaning.ipynb`) and saved to `data/cleaned/`.

---

## Completed

| # | Day | Table | Issue | Rows affected | Decision | Reason |
|---|-----|-------|-------|---------------|----------|--------|
| 1 | 4 | purchase_orders | Duplicate rows (exact copies) | 60 | Removed with `drop_duplicates()`. Rows went from 6060 to 6000 | Duplicates inflate Total Spend and Total Orders. `po_id` must be unique because it is the primary key |
| 2 | 4 | purchase_orders | Missing `unit_price` | 40 (0.66%) | Recalculated as `total_amount / quantity_ordered` | Filling with the mean would be wrong because prices range from about 51 to 2800 depending on the product. Quantity was checked to be positive before using the formula |
| 3 | 4 | vendors | Missing `city` | 2 (8%) | Filled with "Unknown" | City is not used in any KPI, so this does not affect the analysis |
| 4 | 4 | deliveries | Missing `actual_delivery_date` | 20 (0.34%) | Kept as missing. Added a flag column `delivery_date_missing` | A date cannot be guessed. The rows still hold valid received and defective quantities, so they are not dropped. They will be excluded only from On-Time Delivery % |

---

## Checks done with no problem found

| Table | Check | Result |
|-------|-------|--------|
| products | Missing values | None |
| vendors, products, deliveries | Duplicate rows | None |
| purchase_orders, deliveries | Foreign keys (`vendor_id`, `product_id`, `po_id`) | All values exist in the parent table |

---

## To be filled in the next days

| Day | Check | Status |
|-----|-------|--------|
| 5 | Date columns stored as text, mixed date formats | Pending |
| 6 | Outliers in quantity (IQR method), negative quantities, `total_amount` vs `quantity x unit_price` | Pending |
| 7 | Inconsistent vendor names (case, extra spaces, punctuation) | Pending |
| 8 | Final validation and export to `data/cleaned/` | Pending |
| 5 | 5 | purchase_orders | Mixed date formats (YYYY-MM-DD and DD-MM-YYYY) | 467 in order_date, 476 in expected_delivery_date | Parsed each format explicitly with `format=` and combined results | Automatic guessing can misread dates like 03-05-2024 |
| 6 | 5 | purchase_orders, deliveries, vendors | Date columns stored as text | 4 columns | Converted to datetime | Date arithmetic (delivery time, days late) needs real dates |