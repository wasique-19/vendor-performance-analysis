# KPI Definitions: Vendor Performance Analysis

This document explains every KPI used in the project: what it means, how it is calculated, and why a business manager cares about it.

---

## 1. Total Purchase Spend
- **Meaning:** The total money the company spent on purchases from vendors.
- **Formula:** `SUM(quantity_ordered × unit_price)`
- **Why a manager cares:** It shows where the procurement budget is going. Without it, nobody can judge which vendors matter most financially.

## 2. Total Orders
- **Meaning:** The number of purchase orders (POs) placed in a period.
- **Formula:** `COUNT(po_id)`
- **Why a manager cares:** It shows how much work each vendor handles and how busy the procurement team is.

## 3. On-Time Delivery %
- **Meaning:** The share of deliveries that arrived on or before the promised date.
- **Formula:** `(Deliveries where actual_delivery_date <= expected_delivery_date) ÷ Total deliveries × 100`
- **Why a manager cares:** Late materials can stop production and delay customer orders. This is the most important reliability KPI.

## 4. Late Delivery %
- **Meaning:** The share of deliveries that arrived after the promised date.
- **Formula:** `100 − On-Time Delivery %`
- **Why a manager cares:** It highlights unreliable vendors. A vendor with a high late % may need penalties or renegotiated terms.

## 5. Defect Rate %
- **Meaning:** The share of received goods that were faulty or unusable.
- **Formula:** `SUM(quantity_defective) ÷ SUM(quantity_received) × 100`
- **Why a manager cares:** Defective goods mean returns, rework, wasted money and unhappy customers.

## 6. Average Delivery Time
- **Meaning:** The average number of days between placing the order and receiving the goods.
- **Formula:** `AVG(actual_delivery_date − order_date)`
- **Why a manager cares:** Shorter lead times mean less inventory needs to be stored and the company can react faster to demand changes.

## 7. Active Vendors
- **Meaning:** The number of vendors that received at least one order in the selected period.
- **Formula:** `COUNT(DISTINCT vendor_id)` from purchase orders
- **Why a manager cares:** It shows how wide the supplier base is. Too few vendors is risky. Too many is hard to manage.

## 8. Spend Concentration
- **Meaning:** How much of the total spend is held by a small number of vendors.
- **Formula:** `Top N vendors' spend ÷ Total spend × 100` (we will also use Pareto analysis: do the top 20% of vendors make up about 80% of spend?)
- **Why a manager cares:** If a few vendors take most of the spend, the company depends heavily on them. If one fails, the business is hurt.

## 9. Vendor Quality Score
- **Meaning:** A single score that combines delivery reliability and product quality for each vendor.
- **Formula:** To be defined on Day 3 (it will use On-Time % and Defect Rate %).
- **Why a manager cares:** It allows fair ranking of vendors in one number instead of comparing many separate metrics.

## 10. Vendor Risk Category (to be defined later in SQL)
- **Meaning:** A label such as High / Medium / Low risk, based on spend, delivery performance and quality.
- **Why a manager cares:** It tells procurement which vendors need immediate attention, especially those with high spend and low performance.

---

## Key Definitions
- **On-time:** a delivery is on-time if `actual_delivery_date <= expected_delivery_date`.
- **Days late:** `actual_delivery_date − expected_delivery_date` (only when positive).
- **Delivery time (lead time):** `actual_delivery_date − order_date`.