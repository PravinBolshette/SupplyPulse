# SupplyPulse — Detailed Implementation & Execution Plan

**Project Title:** SupplyPulse: AI-Driven Supply Chain Disruption Early-Warning Platform  
**Academic Context:** Mid-Semester & Final Review under Prof. Vanita Babbane (Vishwakarma Institute of Technology, Pune)  
**Portfolio Rank:** Rank #8 in Fujitsu Data & AI Portfolio (Score: 9.1 / 10)  
**Team Members:** Pradymna Adhari, Omkar Akhade, Vishal Amrutkar, and Pravin Bolshette  

---

## Group 1: Data & AI Engine

### Step 1: Database Setup & Schema Provisioning
* **Objective:** Establish a persistent, containerized PostgreSQL 15 database instance using Docker Compose to handle raw ingestion, processed feature tables, and AI alert outputs.
* **Detailed Workflow:**
  1. Create a `docker-compose.yml` file configuring an official `postgres:15-alpine` service with a persistent volume mapping (`postgres_data:/var/lib/postgresql/data`) and environment variables for credentials (`POSTGRES_DB=supplypulse`, `POSTGRES_USER=admin`, `POSTGRES_PASSWORD=secret`).
  2. Write a comprehensive migration script (`init_schema.sql`) that enforces clean separation between raw ingestion tables (`raw_*`) and processed analytical tables (`proc_*`).
  3. Implement the 5 core relational tables with strict foreign keys and constraints:
     * `suppliers`: Stores direct Tier-1 supplier master details and backup mappings.
     * `inventory_levels`: Tracks daily warehouse stock units, consumption rates, and stockout status flags.
     * `port_activities`: Ingests container port congestion delays and vessel counts.
     * `external_disruptions`: Logs weather and natural disaster alerts with regional severity scores.
     * `disruption_alerts`: Stores model inferences, Isolation Forest anomaly scores, and time-to-impact countdowns.
* **Verification Check:** Run `docker compose up -d` followed by `psql -U admin -d supplypulse -c "\dt"` to confirm all relational tables are correctly created.

### Step 2: ETL Pipeline & Data Ingestion
* **Objective:** Build reproducible Python/Pandas scripts to ingest raw external CSV dumps (IMF PortWatch, GDACS) and internal inventory logs, clean missing values, normalize timestamps, and load them into PostgreSQL.
* **Detailed Workflow:**
  1. Structure an `etl/` directory containing modular extraction (`extract.py`), transformation (`transform.py`), and loading (`load.py`) scripts.
  2. **Extraction:** Read raw CSV data dumps from the `data/raw/` directory.
  3. **Transformation:** Clean missing data points, standardize date formats (`YYYY-MM-DD`), handle numerical outliers, and join port/disaster metrics with regional supplier identifiers using Pandas.
  4. **Loading:** Write transformed data frames into the respective `raw_*` and `proc_*` tables in PostgreSQL using `psycopg2` or `SQLAlchemy`.
* **Verification Check:** Execute `python etl/run_pipeline.py` and query PostgreSQL to verify row counts match the ingested source files without null anomalies.

### Step 3: Phase 1 — Isolation Forest Anomaly Detection
* **Objective:** Implement and validate an unsupervised machine learning model using Scikit-learn's `IsolationForest` to detect abnormal supplier behavior based on delivery variance, shipping delays, and order volume drops.
* **Detailed Workflow:**
  1. Build `phase1_detection/train_model.py` to extract engineered feature matrices (e.g., rolling average delivery delays, port congestion correlation, and order fulfillment drops) from processed PostgreSQL tables.
  2. Train the Isolation Forest model with optimized hyperparameters (`contamination=0.05`, `random_state=42`) and serialize the trained model artifact using `joblib` (`isolation_forest_model.pkl`).
  3. Create `detect.py` to score incoming daily supplier records, generating continuous anomaly scores ranging from `-1.0` (highly anomalous) to `1.0` (normal).
  4. Automatically write records breaching the anomaly threshold to the `disruption_alerts` table with `is_flagged = true`.
* **Verification Check:** Run `python phase1_detection/detect.py` against a test batch and verify that known anomalous suppliers are correctly flagged with negative anomaly scores.

### Step 4: Phase 2 — Time-to-Impact (TTI) & Countdown Logic
* **Objective:** Calculate exact stockout countdown timelines and generate plain-language mitigation recommendations when a supplier is flagged.
* **Detailed Workflow:**
  1. Build `phase2_prediction/tti_calculator.py` to fetch flagged supplier alerts alongside current warehouse inventory metrics.
  2. Apply the deterministic inventory depletion formula:
     $$\text{Predicted TTI (Days)} = \frac{\text{Current Stock Units}}{\text{Daily Consumption Rate}}$$
  3. Evaluate the calculated TTI against pre-configured lead times of alternative pre-mapped backup suppliers stored in the database.
  4. Dynamically generate actionable, plain-language recommendations for the Procurement Manager (e.g., *"Stock critical in 4 days. Activate backup contract with Supplier B in Malaysia"*).
  5. Update the `disruption_alerts` table with `predicted_tti_days` and `recommended_action`.
* **Verification Check:** Run the TTI calculation script and verify that output countdown integers and recommendation strings are accurately written to PostgreSQL.

---

## Group 2: Backend & Frontend Dashboard

### Step 1: FastAPI Backend Skeleton & Endpoints
* **Objective:** Expose database records and machine learning inferences through a robust, asynchronous FastAPI REST service.
* **Detailed Workflow:**
  1. Structure the backend into clean directories (`routers/`, `schemas/`, `services/`, `database.py`).
  2. Implement Pydantic data validation models (`SupplierResponse`, `AlertResponse`, `DisruptionCreate`) to ensure strict JSON request/response validation.
  3. Build core REST endpoints:
     * `GET /health`: Service health check.
     * `GET /suppliers`: Fetch direct supplier master records.
     * `GET /anomalies`: Retrieve active Isolation Forest anomaly scores.
     * `GET /alerts`: Fetch live disruption alerts paired with TTI countdowns and recommendations.
  4. Implement global exception handlers and basic audit logging middleware to track API query traffic.
* **Verification Check:** Run `uvicorn main:app --reload` and test endpoints via Swagger UI (`http://localhost:8000/docs`).

### Step 2: Streamlit Operator Dashboard
* **Objective:** Construct an intuitive, multi-tab interactive operator frontend tailored for the primary user persona (Supply Chain Risk Analyst & Procurement Manager).
* **Detailed Workflow:**
  1. Structure the Streamlit app into an intuitive multi-tab layout (`app.py`):
     * **Tab 1: Live Disruption Alerts & Executive Summary:** High-level overview of flagged suppliers and critical stockout warnings.
     * **Tab 2: Supplier Risk Inspector:** Deep dive into individual supplier anomaly scores, delivery history, and port congestion metrics.
     * **Tab 3: Inventory & TTI Countdown View:** Visualizing warehouse stock levels versus depletion timelines.
     * **Tab 4: Scenario Simulation Sandbox:** Interactive sliders allowing operators to simulate severe weather shocks or shipping delays to test system resilience.
  2. Connect Streamlit frontend components asynchronously to the FastAPI backend REST endpoints using `requests`.
* **Verification Check:** Run `streamlit run app.py` and verify that data flows seamlessly from PostgreSQL $\rightarrow$ FastAPI $\rightarrow$ Streamlit UI.

### Step 3: Responsible AI Guardrails & Human-in-the-Loop
* **Objective:** Ensure full compliance with academic safety standards and Responsible AI guidelines by enforcing human oversight on high-impact operational actions.
* **Detailed Workflow:**
  1. Implement explicit confirmation UI dialogs in Streamlit whenever an operator attempts to trigger a mitigation action or acknowledge a high-severity alert.
  2. Ensure the system never executes automated financial transactions or supplier contract switches on its own—the AI acts strictly as an advisory early-warning and recommendation engine.
  3. Log all operator acknowledgments and manual override decisions into an immutable audit table in PostgreSQL for post-review auditing.
* **Verification Check:** Test the dashboard action buttons and verify that warning prompts require manual confirmation before recording actions.

### Step 4: Dockerization & Final Documentation
* **Objective:** Containerize the entire application stack for seamless local deployment and prepare complete academic documentation.
* **Detailed Workflow:**
  1. Write a production-ready `Dockerfile` for the FastAPI backend and a corresponding Dockerfile for the Streamlit frontend.
  2. Update `docker-compose.yml` to orchestrate three container services concurrently: `postgres`, `backend` (FastAPI), and `frontend` (Streamlit).
  3. Compile required project documentation:
     * `README.md`: Setup, installation, and run instructions (`docker compose up --build`).
     * `Data_Dictionary.md`: Detailed field descriptions for all database tables.
     * `User_Guide.md`: Step-by-step instructions walking evaluators through the Streamlit dashboard during the mid-semester and final reviews.
* **Verification Check:** Run `docker compose down -v` followed by `docker compose up --build` from a clean terminal and verify the entire stack boots up and runs successfully with a single command.