# SupplyPulse Service & Schema Contracts

## 1. Scope
This document outlines the interface agreements, database column guarantees, and REST API payload contracts for SupplyPulse services.

---

## 2. Relational Database Interface Contracts

### 2.1 Table: `suppliers`
* `supplier_id` (`TEXT`, PK): Non-null unique identifier formatted as `SUP-XXX`.
* `supplier_name` (`TEXT`): Legal company name.
* `tier_level` (`INT`): 1, 2, or 3.
* `country` (`TEXT`): Standard ISO country name or 3-letter code.
* `backup_supplier_name` (`TEXT`): Designated failover entity.

### 2.2 Table: `inventory_levels`
* `record_id` (`SERIAL`, PK).
* `facility_id` (`TEXT`): Non-null warehouse code (e.g. `FAC-01`).
* `sku_id` (`TEXT`): Material SKU identifier.
* `current_stock_units` (`INT`): Non-negative integer.
* `daily_consumption_rate` (`FLOAT`): Units consumed per day (> 0.0).
* `stockout_flag` (`BOOLEAN`): True when stock drops to 0.

### 2.3 Table: `external_disruptions`
* `event_id` (`TEXT`, PK): UUID or feed-provided ID.
* `event_type` (`TEXT`): Categorical (`weather`, `port_congestion`, `geopolitical`).
* `affected_region` (`TEXT`): Geographical region or port identifier.
* `severity_score` (`FLOAT`): Constrained $0.0 \le \text{severity} \le 10.0$.
* `event_date` (`DATE`): Date of event occurrence.

### 2.4 Table: `disruption_alerts`
* `alert_id` (`SERIAL`, PK).
* `supplier_id` (`TEXT`, FK -> `suppliers.supplier_id`).
* `anomaly_score` (`FLOAT`): Machine learning model score.
* `is_flagged` (`BOOLEAN`): True if alert meets threshold & persistence.
* `predicted_tti_days` (`INT`): Estimated days to production stockout.
* `recommended_action` (`TEXT`): Prescriptive mitigation guidance.

---

## 3. REST API Contracts (FastAPI)

### 3.1 GET `/api/v1/alerts`
* **Response `200 OK`**:
  ```json
  [
    {
      "alert_id": 101,
      "supplier_id": "SUP-012",
      "supplier_name": "Foxconn Shenzhen",
      "anomaly_score": 84.5,
      "predicted_tti_days": 4,
      "risk_level": "CRITICAL",
      "recommended_action": "Reroute to Pegatron Taoyuan",
      "created_at": "2026-10-31T18:00:00Z"
    }
  ]
  ```

### 3.2 POST `/api/v1/mitigation/confirm`
* **Request Body**:
  ```json
  {
    "alert_id": "101",
    "operator_id": "analyst_42",
    "action_taken": "APPROVED",
    "operator_notes": "Spot buy confirmed with backup supplier.",
    "mitigation_target": "Pegatron Taoyuan",
    "cost_exposure_usd": 150000.00
  }
  ```
* **Response `201 Created`**:
  ```json
  {
    "status": "success",
    "log_id": "550e8400-e29b-41d4-a716-446655440000",
    "recorded_at": "2026-10-31T18:05:00Z"
  }
  ```
