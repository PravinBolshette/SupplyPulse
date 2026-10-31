# SupplyPulse: Detailed Problem Statement

**AI-Driven Supply Chain Disruption Early-Warning Platform**

| | |
|---|---|
| Team | Pradymna Adhari, Omkar Akhade, Vishal Amrutkar, Pravin Bolshette |
| Guide | Prof. Vanita Babbane |
| Domain | Supply Chain |
| Focus areas | Forecasting, Risk Analytics, NLP |
| Version | Draft 1 |

> **Before submission:** the real-world examples in Section 2 and the references in Section 14 are written from general knowledge. Look each one up and add proper citations (author, year, link) before this goes to the guide.

---

## 1. Summary (in simple words)

When a supplier has a problem, the company that depends on it usually finds out **late**, and even then does not know **when the damage will arrive**. Today's tools mostly say "this supplier looks risky." They do not say which of our products will be hit, how many days we have, or what we should do in that time.

SupplyPulse is an AI system that:
1. **Detects** unusual supplier behaviour early, using several data sources.
2. **Traces** how the problem spreads through the supply network.
3. **Estimates** a time range for when stock, parts and production will be affected, and suggests an action.

---

## 2. Background

### 2.1 How a supply chain works
A finished product is built from many parts. Each part comes from a supplier. Those suppliers buy from their own suppliers. We call these levels **tiers**:
- **Tier-1:** the companies that sell directly to the manufacturer.
- **Tier-2 and Tier-3:** the suppliers of those suppliers, further and further back.

```
Raw material -> Tier-3 -> Tier-2 -> Tier-1 -> Manufacturer -> Customer
```

### 2.2 Why disruptions are serious
A disruption is anything that stops or slows supply: a flood, a strike, a port closure, a fire, a machine failure, a trade restriction. Because the chain is linked, one failure can stop a whole factory. Some well-known public examples (add references before submission):
- **Suez Canal blockage, March 2021:** one grounded ship blocked a major shipping route for about six days, delaying cargo worldwide.
- **Automotive chip shortage, 2020 to 2022:** car makers cut production because a small component was not available.
- **Thailand floods, 2011:** flooded factories disrupted the supply of hard disk drives to computer makers.

### 2.3 What makes today's supply chains fragile
- **Many levels:** most companies can see only their Tier-1 suppliers.
- **Single points of failure:** one supplier or one port may serve many products.
- **Lean stock:** companies keep little spare stock to save money, so there is little time to react.
- **Information is spread out:** delivery records, shipping data, weather alerts and news all live in different systems.

---

## 3. The Problem

### 3.1 Core problem
Companies cannot answer this question early enough:

> **"A disruption has started somewhere upstream. When exactly will it affect *our* inventory and production, and what should we do before then?"**

### 3.2 The problem broken into parts

| # | Sub-problem | What goes wrong | Why it matters |
|---|---|---|---|
| P1 | **Late detection** | Warning signs (rising delays, falling shipments) are noticed only after stock is already low | Less time to react |
| P2 | **Hidden tiers** | Problems at Tier-2 or Tier-3 suppliers are invisible to the manufacturer | The first sign is a missing delivery |
| P3 | **Scattered signals** | Operations data, logistics, weather and news are not combined | Each signal alone is weak or confusing |
| P4 | **No timing** | Tools give a risk score, not a timeline | A manager cannot tell if it is urgent today or next month |
| P5 | **Company-blind alerts** | General risk scores ignore *our* stock, demand and lead times | The same disruption hurts different companies at different times |
| P6 | **False alarms** | Too many wrong alerts make people ignore the system | Real problems get missed |
| P7 | **No guidance** | Even a good alert does not suggest an action | The user is left to work it out alone |

### 3.3 A worked example
A car company buys a chip. The chip's supplier (Tier-1) depends on a factory (Tier-2) near a river.

| Day | What happens | What today's tools show | What SupplyPulse should show |
|---|---|---|---|
| 0 | Flood cuts the Tier-2 factory's output by 60% | Nothing, or a general news headline | Detects the event and unusual supplier behaviour |
| 1 | Tier-1 supplier starts shipping less | Maybe a late-delivery note | Traces the link: Tier-2 factory -> Tier-1 supplier -> our chip -> our product |
| 1 | We hold 12 days of chip stock | Nothing | Estimates: stock gets critical in about 4 to 6 days, parts run out in about 8 to 11 days |
| 1 | A backup supplier exists | Nothing | Suggests: shift part of the order to the backup within 3 days |

The numbers are only an illustration, not real data.

---

## 4. Who Is Affected

| Group | How the problem hurts them |
|---|---|
| Supply chain risk analysts | Too many separate signals, no clear priority, no explanation |
| Procurement and planning managers | Cannot decide when to switch supplier or rush an order |
| Operations and production heads | Learn about shortages only when the line is about to stop |
| Finance and the business | Lost production, rush shipping costs, missed customer deliveries |
| Customers | Late or missing products |

---

## 5. Impact of the Problem
These are general consequences, not numbers from our own data:
- **Production stops** or runs below capacity when a part runs out.
- **Higher costs** from emergency orders, air freight and overtime.
- **Lost sales and customer trust** because of late deliveries.
- **Slow, reactive decisions** because nobody knows how much time is left.

A warning that arrives early and includes a time range turns these from "surprises" into "planned responses."

---

## 6. Existing Approaches and Their Limits

| Approach | What it does well | What is missing |
|---|---|---|
| **Risk scoring tools** (supplier ratings) | Give a quick picture of supplier risk | Static. No timing, no link to our stock |
| **Disruption monitoring** (news and event alerts) | Tell you that something happened | Do not say whether *we* are affected or when |
| **Supply chain mapping** (including knowledge-graph methods) | Reveal hidden suppliers and links | Usually a static picture; they do not model how things change over time |
| **Time-to-survive analysis** (a planning method used in industry) | Estimates how long a company can keep producing if a supplier fails | Usually done as a manual, one-off study, not updated automatically from live signals |
| **Forecasting models** (demand and inventory) | Predict normal behaviour | Not built to react to a disruption starting upstream |

One paper we studied (AlMahri, Xu and Brintrup, on knowledge graphs and language models for supply chain visibility) builds a map of hidden multi-tier relationships from public text. Its own conclusion says the map is static and does not yet follow real-time changes. That is a clear opening for our work.

---

## 7. Research Gap

> Existing work either **detects** disruptions, **maps** supply networks, or **analyses** survival time in manual studies. There is no simple, integrated system that **links live external signals, the multi-tier network and a company's own inventory state to produce an updating time-to-impact estimate with a range and a recommended action.**

We are **not** claiming that nobody has ever thought about time-to-survive. We claim that connecting detection, spreading and timing into one automated, explainable pipeline, and showing it with honest evaluation, is the gap we address.

---

## 8. Formal Problem Statement

> *Supply chains are multi-tier and interconnected, so a disruption at an upstream supplier can reach a manufacturer days or weeks later. Existing tools mostly detect disruptions or give static risk scores, and they do not estimate when a disruption will affect a specific company's inventory and production. This project designs and builds an AI-based early-warning platform that (1) detects unusual supplier behaviour from multiple data sources, (2) traces how the disruption spreads through the supply network, and (3) estimates the time range in which downstream impact is likely, together with a recommended action, so that planners can act before shortages occur.*

### 8.1 Research questions
1. **RQ1:** Can unusual supplier behaviour be detected early from operational, logistics, weather and news signals, and how well compared with a simple baseline?
2. **RQ2:** Can the supply network be used to correctly identify which parts, factories and products a disruption reaches?
3. **RQ3:** Can the time until inventory, parts and production are affected be estimated as a range that is right about as often as it claims to be?
4. **RQ4:** Which signals contribute most to catching a disruption early?

---

## 9. Objectives

| # | Objective | How we will check it |
|---|---|---|
| O1 | Detect unusual supplier behaviour early | Precision, recall and F1 on a later time period, compared with a simple baseline |
| O2 | Combine multiple data sources | Database holds operations, logistics, weather and news data, with a data dictionary |
| O3 | Show how a disruption spreads across tiers | Correct downstream list on all defined test networks |
| O4 | Estimate time-to-impact as a range | Average error in days, and how often the true value falls inside the stated range |
| O5 | Read news into structured events | Accuracy on about 100 headlines we label ourselves |
| O6 | Explain every alert and suggest an action | Each alert names the measures behind it; recommendation shown in the dashboard |
| O7 | Find which signals help most | Comparison of results with and without each data source |

---

## 10. Scope

**In scope (MVP)**
- PostgreSQL database for suppliers, parts, stock, network, events and daily supplier data.
- Phase 1: detect unusual suppliers, risk score 0 to 100, severity level, reason.
- Phase 2: supply network and downstream impact search.
- Phase 3: time-to-impact range and rule-based recommendation.
- News reading with spaCy plus rules.
- API and Streamlit dashboard; tests; the six required documents.

**Out of scope**
- Live connection to any real company's systems or confidential data.
- Automatic ordering or any action without a human decision.
- Deep-learning or chatbot-style text understanding.
- Large-scale production hosting.
- Claims of real-world accuracy beyond what our test data supports.

---

## 11. Assumptions and Constraints

**Assumptions**
- A company can provide its own stock levels, demand and supplier-part links to the system.
- Early signs of a disruption show up in at least some of our data sources.

**Constraints**
- **Data:** real multi-tier supplier and inventory data is confidential, so most testing uses synthetic data. Any real public dataset must be checked for access and licence first.
- **Time:** one semester, four students, 22 weeks.
- **Tools:** the portfolio lists Python, PostgreSQL, APIs, ML, NLP and Streamlit. We add FastAPI, scikit-learn, NetworkX, spaCy, Docker and pytest.
- **Ground truth:** there is no real record of "disruption started here, stock ran out on this day" for a whole chain, so timing is validated on simulated scenarios.

---

## 12. Proposed Solution in Brief

```
Outside signals + company data  ->  PostgreSQL
        News reader (headline -> event type, place, seriousness)
   Phase 1 DETECT  ->  Phase 2 SPREAD  ->  Phase 3 PREDICT
                      API  ->  Dashboard
```

- **Detect:** an Isolation Forest scores each supplier against its own normal behaviour, backed by a simple safety rule for sudden single-measure jumps.
- **Spread:** a network (graph) of supplier -> part -> factory -> product is searched downstream from the flagged supplier.
- **Predict:** a basic stock formula first, then a machine-learning model that gives a time range, then rules that suggest an action.

---

## 13. Expected Outcomes and Evaluation

**Outcomes**
- A working MVP that runs end to end from a fresh copy of the repository.
- An evaluation report with honest numbers and a comparison to a baseline.
- The six required documents: Problem Statement, Architecture, Data Dictionary, Test Cases, Responsible AI, User Guide.

**How we evaluate**
- Train on older data, validate on the next period, test on the latest period. Time is never shuffled.
- Report precision, recall and F1 together, never only one.
- Check for leakage of answers into the inputs.
- Test timing on simulated scenarios and report the error and range coverage.

**Where we stand now (early prototype):** precision about 0.41 and recall about 0.66 on a labelled synthetic test set. In plain words, around 4 in 10 alarms were real and about 2 in 3 real problems were caught. This is a starting point on made-up data, not a real-world result.

---

## 14. Limitations and What We Do Not Claim
- We do **not** predict exact dates, only ranges.
- We do **not** predict that a disruption will happen. We detect early signs and estimate impact once signs appear.
- We do **not** claim real-world accuracy from synthetic data.
- Our news reading is rule-assisted and will miss some events.
- A single measure that jumps alone can be missed by the main model, which is why the safety rule exists.
- The system suggests actions. A human decides.

---

## 15. Key Terms

| Term | Simple meaning |
|---|---|
| Tier | A level of suppliers (Tier-1 sells directly to the manufacturer) |
| Disruption | Anything that stops or slows supply |
| Anomaly | Behaviour that looks very different from normal |
| Time-to-impact | How long until a disruption affects stock, parts or production |
| Isolation Forest | A model that finds odd data points because they are easy to separate from the rest |
| Baseline | A very simple method our model must beat |
| Synthetic data | Data we generate ourselves for testing |
| Precision | Of the alarms raised, the share that were real |
| Recall | Of the real problems, the share that were caught |
| NLP | Computers reading human language |

---

## 16. References to Add (check each before citing)
1. AlMahri, S., Xu, L., Brintrup, A. *Enhancing supply chain visibility with knowledge graphs and large language models* (the paper summarised in our project notes).
2. Liu, F. T., Ting, K. M., Zhou, Z.-H. *Isolation Forest.* IEEE International Conference on Data Mining, 2008.
3. Simchi-Levi, D., et al. *Identifying risks and mitigating disruptions in the automotive supply chain.* Interfaces, 2015. (Time-to-survive and time-to-recover ideas.)
4. Ivanov, D. *Predicting the impacts of epidemic outbreaks on global supply chains.* Transportation Research Part E, 2020. (Ripple effect in supply chains.)
5. Sources for the three real-world examples in Section 2.2 (news or industry reports).
6. Dataset pages and licences for any real public datasets we adopt.
