# SupplyPulse Risk Methodology & Early-Warning Framework

## 1. Executive Summary
The SupplyPulse Risk Methodology defines how raw telemetry signals from internal operations and external risk streams are fused into actionable disruption risk scores, anomaly detections, and physical Time-to-Impact (TTI) predictions.

---

## 2. Multi-Signal Fusion Architecture

Disruption risk is computed across four intelligence pillars:
1. **Internal Inventory Depletion Velocity**: Ratio of current on-hand warehouse inventory to the daily average consumption velocity:
   $$\text{Runway (Days)} = \frac{\text{Current Stock Units}}{\text{Daily Consumption Rate}}$$
2. **Supplier Lead Time & Historical Reliability**: Contracted delivery lead times and supplier reliability indices ($0.0 \le \text{Reliability} \le 1.0$).
3. **Maritime Logistics Congestion**: Port dwell time anomaly and congestion delays (in days) logged at key entry ports.
4. **Geopolitical & Weather Disruptions**: NLP extraction of severity scores ($0.0$ to $10.0$) from disaster alerts and news feeds.

---

## 3. Anomaly Detection Engine (Phase 1)

* **Algorithm**: Unsupervised Isolation Forest (`scikit-learn`).
* **Feature Vector**:
  * Normalized stock runway (days)
  * Supplier delivery delay variance
  * Port congestion index
  * External event severity weight
* **Contamination Rate**: Configured to $0.05$ (top 5% most anomalous states).
* **Scoring**: Negative anomaly score mapped to percentile risk metric $[0, 100]$.

---

## 4. Alert Lifecycle & State Management

To avoid alert fatigue and spurious triggers, the alerting state machine follows strict hysteresis thresholds:

| Parameter | Configuration Key | Default Value | Description |
| :--- | :--- | :--- | :--- |
| **Raise Score** | `ALERT_RAISE_SCORE` | `70` | Anomaly score threshold required to trigger an active alert |
| **Clear Score** | `ALERT_CLEAR_SCORE` | `50` | Score below which an active alert is resolved |
| **Persistence Window** | `ALERT_PERSISTENCE_DAYS` | `2` | Days condition must hold continuously before alert is raised |
| **Cooldown Period** | `ALERT_COOLDOWN_DAYS` | `5` | Suppresses repeated alert fires for the same supplier |
| **Minimum Signals** | `ALERT_MIN_SIGNALS` | `2` | Minimum concurrent risk signals required to escalate alert |

---

## 5. Physical Time-to-Impact (TTI) Engine (Phase 2)

Once an anomaly is flagged with persistent risk, the deterministic physics engine calculates the Time-to-Impact:

$$\text{TTI} = \max\left(0, \left\lfloor \frac{\text{Current Stock Units}}{\text{Daily Consumption Rate}} \right\rfloor - \text{Estimated Inbound Delay Days}\right)$$

### Action Recommendations Based on TTI:
* **$\text{TTI} \le 3 \text{ days}$ (CRITICAL)**: Activate emergency spot buy and expedite rerouting to primary backup supplier.
* **$3 < \text{TTI} \le 7 \text{ days}$ (WARNING)**: Pre-book backup supplier capacity and adjust production run schedule.
* **$\text{TTI} > 7 \text{ days}$ (WATCH)**: Continue automated monitoring, flag for analyst review.

---

## 6. Human-in-the-Loop (HITL) Guardrails
AI recommendations are never executed automatically without human confirmation. Every alert mitigation recommendation (approve, override, reject) is logged to an immutable PostgreSQL audit ledger (`audit_logs`) enforcing Responsible AI compliance.
