# KPI Reference: Vendor Performance Analysis

These are the verified results calculated in **SQL Server** from the cleaned dataset (`data/cleaned/`). Every number in Excel and Power BI must match this sheet. If a number differs, the difference is a bug in the Excel or Power BI calculation, not a new result.

## Calculation rules

| Rule | Definition |
|------|------------|
| Total Purchase Spend | `SUM(total_amount)` for **Delivered** orders only. Cancelled orders are not counted because no payment was made |
| Total Orders | All orders placed, including cancelled ones |
| On-Time Delivery % | Deliveries with `actual_delivery_date <= expected_delivery_date` divided by deliveries that have a date. The 20 deliveries with no date are excluded |
| Late Delivery % | Deliveries with `actual_delivery_date > expected_delivery_date` divided by deliveries that have a date |
| Defect Rate % | `SUM(quantity_defective) / SUM(quantity_received)`, excluding the 10 deliveries with invalid defect data (both numerator and denominator) |
| Average Delivery Time | Average of `actual_delivery_date - order_date` in days, over deliveries that have a date |
| Defect Score | `max(0, 100 - 10 x Defect Rate %)` |
| Vendor Quality Score | `0.6 x On-Time % + 0.4 x Defect Score` |
| Spend Share % | Vendor spend divided by total Delivered spend |
| Risk: High | Quality Score < 70 **and** Spend Share >= 2% |
| Risk: Medium | Quality Score < 70 (small spend), **or** On-Time % < 75, **or** Spend Share >= 10% |
| Risk: Low | Everything else |

## Company-level KPIs

| KPI | Value |
|-----|-------|
| Total orders (all) | 6,000 |
| Delivered orders | 5,813 |
| Cancelled orders | 187 |
| **Total Purchase Spend (Delivered)** | **476,741,774.58** |
| Spend of cancelled orders (not counted) | 15,770,328.78 |
| Order value of all orders (Delivered + Cancelled) | 492,512,103.36 |
| Average order value (Delivered) | 82,013.04 |
| Smallest / largest Delivered order | 550.70 / 3,019,770.00 |
| Active vendors, 2024 | 25 |
| Active vendors, 2025 | 22 |
| Orders 2024 / 2025 | 3,310 / 2,690 |
| Spend 2024 | 243,245,733.56 |
| Spend 2025 | 233,496,041.02 |
| Deliveries with a recorded date | 5,793 |
| On-time deliveries | 4,850 |
| Late deliveries | 943 |
| Deliveries with no date (excluded) | 20 |
| **On-Time Delivery %** | **83.72%** |
| **Late Delivery %** | **16.28%** |
| **Defect Rate %** | **3.48%** |
| **Average Delivery Time** | **10.28 days** |
| Large orders (IQR flag, all statuses) | 373 |

## Spend concentration

| Measure | Value |
|---------|-------|
| Top vendor | V001 Apex Circuits, 84,448,534.65 (17.71%) |
| Top 3 vendors share of spend | 43.32% |
| Top 5 vendors share of spend | 62.54% |
| Vendors needed to reach 80% of spend | 10 of 25 (cumulative 82.29%) |
| Average vendor spend | 19,069,670.98 |
| Vendors with spend above the average | 7 |

**Spend by vendor category**

| Category | Vendors | Spend | Share |
|----------|---------|-------|-------|
| Electronics | 5 | 283,735,418.59 | 59.52% |
| Raw Materials | 5 | 98,004,002.85 | 20.56% |
| Office Supplies | 5 | 42,199,568.00 | 8.85% |
| Logistics Supplies | 5 | 33,641,540.58 | 7.06% |
| Packaging | 5 | 19,161,244.56 | 4.02% |

## Quality and risk summary

| Measure | Value |
|---------|-------|
| Average Quality Score (25 vendors) | 76.40 |
| Highest Quality Score | V017 RoadRunner Supplies, 91.85 |
| Lowest Quality Score | V012 PolyChem Materials, 63.03 |
| Vendors with Quality Score below 70 | 5 (V012, V014, V025, V009, V013) |
| High-spend and low-performance vendor (spend above average and score below average) | V012 PolyChem Materials (spend 37,651,235.32, score 63.03) |

| Risk category | Vendors | Spend | Share of spend |
|---------------|---------|-------|----------------|
| High | 3 (V012, V014, V025) | 64,916,278.56 | 13.62% |
| Medium | 11 | 308,679,322.89 | 64.75% |
| Low | 11 | 103,146,173.13 | 21.64% |

## Vendor scorecard (all 25 vendors)

| Vendor | Name | Total orders | Total spend | Spend share | Deliveries | On-time % | Defect rate % | Avg delivery days | Quality score | Risk |
|--------|------|--------------|-------------|-------------|------------|-----------|---------------|-------------------|---------------|------|
| V001 | Apex Circuits Pvt Ltd | 364 | 84,448,534.65 | 17.71% | 357 | 87.64 | 2.90 | 11.38 | 81.00 | Medium |
| V002 | Nova Electronics Pvt Ltd | 305 | 66,746,790.73 | 14.00% | 292 | 96.22 | 2.42 | 14.76 | 88.07 | Medium |
| V003 | Pixel Components Pvt Ltd | 102 | 23,212,116.97 | 4.87% | 95 | 84.21 | 2.12 | 14.71 | 82.03 | Low |
| V004 | VoltEdge Systems Pvt Ltd | 256 | 55,342,316.44 | 11.61% | 246 | 91.46 | 3.83 | 10.24 | 79.55 | Medium |
| V005 | Zenith Micro Pvt Ltd | 222 | 53,985,659.80 | 11.32% | 213 | 82.46 | 2.58 | 8.60 | 79.18 | Medium |
| V006 | BoxCraft Packaging Pvt Ltd | 218 | 3,069,854.81 | 0.64% | 213 | 67.45 | 1.00 | 15.93 | 76.48 | Medium |
| V007 | PackRight Solutions Pvt Ltd | 430 | 5,439,600.21 | 1.14% | 413 | 87.14 | 1.10 | 6.33 | 87.87 | Low |
| V008 | GreenWrap Industries Pvt Ltd | 235 | 3,179,970.12 | 0.67% | 228 | 90.75 | 5.56 | 13.33 | 72.21 | Low |
| V009 | SafeSeal Containers Pvt Ltd | 314 | 4,836,584.30 | 1.01% | 309 | 84.09 | 5.50 | 5.52 | 68.44 | Medium |
| V010 | CrateWorks Pvt Ltd | 190 | 2,635,235.12 | 0.55% | 181 | 89.50 | 4.37 | 14.35 | 76.21 | Low |
| V011 | SteelCore Metals Pvt Ltd | 248 | 27,151,955.69 | 5.70% | 243 | 79.75 | 1.92 | 14.82 | 80.17 | Low |
| V012 | PolyChem Materials Pvt Ltd | 338 | 37,651,235.32 | 7.90% | 328 | 78.05 | 5.95 | 6.16 | 63.03 | High |
| V013 | TimberLine Supply Pvt Ltd | 50 | 5,727,559.33 | 1.20% | 48 | 79.17 | 4.75 | 17.04 | 68.52 | Medium |
| V014 | AlloyHub Traders Pvt Ltd | 141 | 13,703,808.71 | 2.87% | 138 | 69.34 | 4.19 | 11.86 | 64.83 | High |
| V015 | ResinPro Chemicals Pvt Ltd | 110 | 13,769,443.80 | 2.89% | 107 | 70.48 | 2.88 | 17.72 | 70.76 | Medium |
| V016 | SwiftPallet Logistics Pvt Ltd | 99 | 2,441,067.45 | 0.51% | 94 | 67.74 | 2.11 | 5.84 | 72.20 | Medium |
| V017 | RoadRunner Supplies Pvt Ltd | 152 | 2,907,113.34 | 0.61% | 146 | 93.15 | 1.01 | 5.86 | 91.85 | Low |
| V018 | CargoSafe Equipment Pvt Ltd | 663 | 16,303,695.49 | 3.42% | 646 | 95.02 | 5.52 | 10.82 | 74.95 | Low |
| V019 | LoadMaster Tools Pvt Ltd | 82 | 2,772,413.55 | 0.58% | 79 | 86.08 | 3.39 | 7.52 | 78.10 | Low |
| V020 | FleetMate Supplies Pvt Ltd | 440 | 9,217,250.75 | 1.93% | 428 | 70.26 | 1.65 | 10.70 | 75.57 | Medium |
| V021 | PaperTrail Stationers Pvt Ltd | 46 | 1,805,185.66 | 0.38% | 43 | 81.40 | 2.22 | 15.05 | 79.96 | Low |
| V022 | OfficeNest Supplies Pvt Ltd | 134 | 5,301,253.89 | 1.11% | 132 | 92.37 | 3.45 | 6.20 | 81.63 | Low |
| V023 | InkWell Traders Pvt Ltd | 229 | 9,094,260.83 | 1.91% | 222 | 73.87 | 1.42 | 15.35 | 78.63 | Medium |
| V024 | DeskPro Essentials Pvt Ltd | 304 | 12,437,633.09 | 2.61% | 298 | 90.27 | 5.06 | 5.20 | 73.91 | Low |
| V025 | BrightDesk Supplies Pvt Ltd | 328 | 13,561,234.53 | 2.84% | 314 | 72.76 | 4.68 | 7.43 | 64.95 | High |

Check totals: orders add up to 6,000, deliveries to 5,813 and spend to 476,741,774.58.

## Monthly view (by order month)

Spend counts Delivered orders. On-Time % is for deliveries of orders placed in that month.

| Month | Orders | Spend | Deliveries | On-time % |
|-------|--------|-------|------------|-----------|
| 2024-01 | 273 | 18,665,301.45 | 267 | 82.64 |
| 2024-02 | 223 | 13,219,063.54 | 218 | 81.19 |
| 2024-03 | 289 | 23,639,029.68 | 282 | 81.85 |
| 2024-04 | 288 | 22,215,472.69 | 278 | 83.03 |
| 2024-05 | 296 | 20,611,132.31 | 283 | 86.52 |
| 2024-06 | 271 | 17,881,211.48 | 263 | 78.24 |
| 2024-07 | 277 | 18,996,038.48 | 272 | 85.66 |
| 2024-08 | 304 | 22,324,325.28 | 295 | 83.28 |
| 2024-09 | 268 | 26,199,769.05 | 255 | 83.53 |
| 2024-10 | 287 | 20,507,508.40 | 279 | 83.51 |
| 2024-11 | 283 | 19,068,366.74 | 273 | 85.24 |
| 2024-12 | 251 | 19,918,514.46 | 244 | 83.20 |
| 2025-01 | 229 | 19,967,538.93 | 217 | 79.63 |
| 2025-02 | 201 | 18,917,495.84 | 196 | 85.20 |
| 2025-03 | 226 | 20,489,017.10 | 215 | 82.79 |
| 2025-04 | 237 | 19,236,165.27 | 233 | 85.71 |
| 2025-05 | 220 | 19,342,967.21 | 210 | 89.52 |
| 2025-06 | 205 | 19,132,939.60 | 202 | 84.65 |
| 2025-07 | 234 | 20,802,512.58 | 227 | 85.84 |
| 2025-08 | 215 | 21,964,717.49 | 209 | 86.54 |
| 2025-09 | 231 | 18,233,616.41 | 220 | 79.82 |
| 2025-10 | 232 | 16,592,334.97 | 231 | 84.28 |
| 2025-11 | 229 | 17,507,966.78 | 223 | 84.68 |
| 2025-12 | 231 | 21,308,768.84 | 221 | 83.71 |

Check totals: orders add up to 6,000 and monthly spend to 476,741,774.58.

## How to use this sheet

- **Excel (Phase 4):** after building each pivot table, compare it with the matching row here.
- **Power BI (Phase 5):** every card and chart total must match the company-level KPIs. Vendor-level tables must match the scorecard.
- If a value differs by a few paise, check rounding. If it differs by more, check the filter (Delivered only, missing dates excluded, invalid defect rows excluded).