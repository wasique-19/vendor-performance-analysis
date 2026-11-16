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
| 5 | 5 | purchase_orders | Mixed date formats (YYYY-MM-DD and DD-MM-YYYY) | 467 in `order_date`, 476 in `expected_delivery_date` | Parsed each format explicitly with `format=` and combined the results | Automatic guessing can misread dates such as 03-05-2024 (3 May or 5 March) |
| 6 | 5 | purchase_orders, deliveries, vendors | Date columns stored as text | 4 columns (`order_date`, `expected_delivery_date`, `actual_delivery_date`, `contract_start_date`) | Converted to `datetime` | Date arithmetic (delivery time, days late) needs real dates |
| 7 | 6 | purchase_orders | Negative `quantity_ordered` | 12 | Recovered as `total_amount / unit_price` | Negative quantity is impossible. `unit_price` and `total_amount` were consistent with each other |
| 8 | 6 | purchase_orders | Extremely large `quantity_ordered` (total does not equal quantity x price) | 10 | Recovered as `total_amount / unit_price` | Recovered values are whole numbers in a normal range (44 to 693). Cross-check with deliveries improved: received > ordered went from 12 rows to 0 |
| 9 | 6 | purchase_orders | Large but valid orders found by the IQR method | 373 | Kept. Added flag column `is_large_order` | Totals are consistent, so these are real bulk orders. Removing them would understate spend |
| 10 | 6 | deliveries | `quantity_defective` greater than `quantity_received` | 10 | Set to missing. Added flag column `defect_data_invalid` | The value is impossible and the true value is unknown. These rows will be excluded from Defect Rate % in both numerator and denominator |

---

## Checks done with no problem found

| Day | Table | Check | Result |
|-----|-------|-------|--------|
| 4 | products | Missing values | None |
| 4 | vendors, products, deliveries | Duplicate rows | None |
| 3 | purchase_orders, deliveries | Foreign keys (`vendor_id`, `product_id`, `po_id`) | All values exist in the parent table |
| 5 | all date columns | Values that failed to parse (`NaT`) | None, except the 20 deliveries with no recorded date |
| 5 | purchase_orders | Order dates fall in a realistic range | 2024-01-01 to 2025-12-31 |
| 5 | purchase_orders | Expected delivery date before order date | 0 rows |
| 5 | deliveries | Delivered before ordered | 0 rows |
| 6 | purchase_orders | Quantity <= 0 after the fix | 0 rows |
| 6 | purchase_orders | `total_amount` vs `quantity x unit_price` after the fix (1% tolerance) | 0 mismatches |
| 6 | purchase_orders | `unit_price` <= 0 or `total_amount` <= 0 | 0 rows |
| 6 | deliveries | Negative `quantity_defective` or `quantity_received` <= 0 | 0 rows |

---

## Notes for later analysis

- **IQR method:** it flagged 388 orders, but only 17 were real errors. 371 were valid bulk orders, and 5 real errors (small negative quantities) were not flagged. Statistical outlier detection was combined with the business rule `quantity x price = total` instead of deleting flagged rows.
- **Short deliveries:** some deliveries have `quantity_received` below `quantity_ordered`. This is a real business event, not an error, so these rows were kept.
- **KPI rules from cleaning:** exclude the 20 rows with `delivery_date_missing = True` from On-Time and Late Delivery %. Exclude the 10 rows with `defect_data_invalid = True` from Defect Rate %.
- **Recovered quantities (rows 7 and 8):** this assumes `total_amount` and `unit_price` were correct. In a real project this would be confirmed with the procurement team.

---

## To be filled in the next days

| Day | Check | Status |
|-----|-------|--------|
| 11 | 7 | vendors | Inconsistent vendor names: extra spaces (1), "Pvt." with a dot (1), all lowercase (1), ALL UPPERCASE (1) | 4 | Stripped spaces, standardised suffix to "Pvt Ltd", applied Title Case only to fully upper/lower names, and corrected one brand name (V006) from the vendor master list | `.title()` on every name would damage brand names such as VoltEdge; no duplicate vendors found after normalising |
| 8 | Final validation and export to `data/cleaned/` | Pending |