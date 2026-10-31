# SupplyPulse Operational & Modeling Assumptions

## 1. Data Ingestion & Publication Latency
* **Macroeconomic & Trade Indicators**: World Bank / UN Comtrade publication lag is assumed at 45 calendar days (`WB_PUBLICATION_LAG_DAYS=45`). Synthetic models apply historical backfill to simulate real-world publishing delays.
* **Maritime Port Telemetry**: Port activity logs and AIS dwell times are received on a daily batch schedule at 00:00 UTC.
* **Weather & Disaster Feeds**: GDACS and RSS feeds provide near-real-time event streaming with up to 1-hour delay.
* **Internal ERP Telemetry**: Warehouse inventory and consumption rates are updated at end-of-shift daily.

---

## 2. Supply Chain Topology
* **Tier-1 Direct Focus**: Primary modeling focuses on Tier-1 suppliers. Backup supplier relations are mapped 1-to-1 or 1-to-N based on vendor master catalog data.
* **Single-Point Bottlenecks**: Components are assumed non-substitutable across differing product families without procurement signoff.
* **Linear Inventory Consumption**: Warehouse daily consumption rate is modeled as constant over short forecasting horizons (1 to 14 days), reflecting steady-state manufacturing demand.

---

## 3. Machine Learning & Risk Bounds
* **Stationarity**: Supplier baseline risk is computed across rolling 90-day windows.
* **False Discovery Mitigation**: Hysteresis controls (raise threshold 70, clear threshold 50) and a 2-day persistence filter prevent flickering alerts caused by transient sensor spikes.
* **Synthetic Generation Fidelity**: In the absence of live production ERP connections, data generator reproduces empirical distributions matching automotive and electronics supply chain benchmarks.

---

## 4. Responsible AI & HITL
* **No Autonomous Ordering**: The system issues prescriptive recommendations; it does not issue purchase orders or execute payments autonomously.
* **Audit Immutability**: All decisions, overrides, and operator rationale must be recorded into an append-only ledger protected by database-level triggers.
