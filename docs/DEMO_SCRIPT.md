# SupplyPulse End-to-End Live Demonstration Script

## 1. Objective
Demonstrate SupplyPulse's capabilities in detecting upstream supply chain risks, evaluating Time-to-Impact, and orchestrating operator approval under Responsible AI guardrails.

---

## 2. Pre-Requisites
1. Clone repo and create environment:
   ```bash
   cp .env.example .env
   pip install -r requirements/base.txt -r requirements/dev.txt
   ```
2. Start PostgreSQL container:
   ```bash
   docker-compose up -d
   ```

---

## 3. Step-by-Step Demonstration Walkthrough

### Step 1: Database Initialization & Synthetic Baseline
* Verify PostgreSQL is healthy:
  ```bash
  docker-compose ps
  ```
* Seed initial synthetic supplier and inventory state:
  ```bash
  python src/supplypulse/data_gen/generate_data.py
  ```
* **Talking Point**: Point out the 5 core tables populated with realistic supplier hierarchies and baseline inventory runway.

### Step 2: Inject Disruption Event (Weather / Port Congestion)
* Run NLP ingestion pipeline on live RSS feeds or simulated GDACS headline:
  ```bash
  python src/supplypulse/ingestion/nlp_ingest.py
  ```
* **Talking Point**: Emphasize how raw text headlines ("Typhoon Gaemi halts operations at Kaohsiung Port") are translated into structured database records with geographical region and severity scores.

### Step 3: Anomaly Detection & Time-to-Impact Engine
* Execute the detection engine:
  ```bash
  python src/supplypulse/models/detect.py
  ```
* Run TTI forecasting:
  ```bash
  python src/supplypulse/risk/tti_calculator.py
  ```
* **Talking Point**: Explain how Isolation Forest flags anomalous operational risk states, and physics forecasting derives a countdown clock (e.g. 4 days until stockout).

### Step 4: Interactive Operator Dashboard (Streamlit & FastAPI)
* Start the backend API service:
  ```bash
  uvicorn src.supplypulse.api.main:app --port 8000 --reload
  ```
* Start the frontend dashboard:
  ```bash
  streamlit run src/supplypulse/dashboard/app.py --server.port 8050
  ```
* Open `http://localhost:8050` in browser.
* Review the active disruption card for affected Tier-1 supplier.
* Review proposed mitigation: "Expedite reroute to secondary supplier".

### Step 5: Responsible AI Human-in-the-Loop Confirmation
* Click **Approve Mitigation** button.
* Verify audit trail:
  ```bash
  psql -U supplypulse -d supplypulse -c "SELECT * FROM audit_logs ORDER BY timestamp DESC LIMIT 1;"
  ```
* Highlight that audit records are cryptographically tagged and cannot be altered or deleted.
