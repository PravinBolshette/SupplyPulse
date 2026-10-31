# SupplyPulse: Project Plan (Simple Version)

**An AI system that warns a company early when a supplier problem is about to hurt them, and tells them roughly when.**

| Quick facts | |
|---|---|
| Guide | Prof. Vanita Babbane |
| Team | Pradymna Adhari, Omkar Akhade, Vishal Amrutkar, Pravin Bolshette |
| Portfolio | Fujitsu Data & AI Portfolio, rank #8, score 9.1/10 |
| Focus | Forecasting, Risk Analytics, NLP |
| Official tools | Python, PostgreSQL, APIs, ML, NLP, Streamlit |
| Extra tools we add | FastAPI, scikit-learn, NetworkX, spaCy, Docker, pytest |
| Length | 22 weeks, 5 reviews |

> **Please check one thing.** The review names, the 22 weeks and the six required documents come from our brief. The exact week of each review (Section 8) is **our own suggestion**. We have not seen the official Fujitsu guideline text. Compare it with the guideline and change the weeks if they differ.

---

## 0. The Project in 30 Seconds

Imagine a car company. One of its chip suppliers has a flood. Normal software says: "Supplier A is risky." That does not help much.

SupplyPulse does three things:

1. **Detect:** notice that a supplier is behaving strangely (for example, deliveries suddenly get late).
2. **Spread:** find out which parts, factories and products depend on that supplier.
3. **Predict:** estimate *when* the company will feel it (stock gets low, parts run out, production stops) and suggest what to do.

Short version: **Detect the problem, trace who it hits, estimate when it hits.**

---

## 1. The Problem and Background

**Background.** A product is made from many parts, and those parts come from many suppliers. Those suppliers have their own suppliers. A problem at a small supplier far down the chain (a flood, a strike, a port closure, a fire) can take days or weeks to reach the final company.

**The problem.** Most tools only say "this supplier is risky." They do not say:
- When will our stock run out?
- Which of our products will be affected?
- What should we do, and by what date?

On top of that, the useful clues (supplier delivery data, shipping delays, weather, news) live in different places, and nobody puts them together with stock levels.

**What is new in our project**

| Normal tools | SupplyPulse |
|---|---|
| Say something is wrong | Say what is wrong, who it hits, and when |
| One risk score | A timeline with a time range |
| One data source | Several: delivery data, logistics, weather, news |

**Our goals**
1. Spot unusual supplier behaviour early.
2. Combine different data sources in one place.
3. Show how a problem spreads from supplier to supplier.
4. Estimate when each stage (stock, parts, production) will be hit, as a range.
5. Find out which clues help most in catching problems early.

**How we will know we succeeded** (these are our own targets; we can adjust them with our guide)

| What | How we measure | Target |
|---|---|---|
| Detecting problems | Precision, recall and F1 on data from a later time period | Better than a very simple rule. Always show all three numbers |
| Spread | Does it list the right affected parts and products? | Fully correct on our test cases |
| Timing | Average error in days, and whether the range really contains the answer | The range is right about as often as it says it is |
| News reading (NLP) | Correct event type on about 100 headlines we label ourselves | At least 80% |
| Speed | Time to show results for the demo suppliers | Under 3 seconds |
| Code quality | Automated tests pass | About 70% of core code tested |

What the words mean:
- **Precision:** of all the alarms we raised, how many were real problems?
- **Recall:** of all the real problems, how many did we catch?
- **F1:** one number that balances the two.

Our early prototype (on made-up data) got precision 0.41 and recall 0.66. In plain words: about 4 in 10 alarms were real, and about 2 in 3 real problems were caught. We must always say this was on made-up data.

> **Why this problem and this approach, and not something else?**
> - **Why "when", not just "whether"?** Many tools already say whether a supplier is risky. The gap is timing. A planner needs a deadline to act, so that is where we add something new.
> - **Why a range, not one exact date?** Nobody can know the exact day. A range is honest and still useful.
> - **Why measure on a later time period?** In real use we predict the future, so we test on data that comes *after* the training data. Mixing time periods would be cheating without noticing.

---

## 2. What We Will Build (MVP Scope)

MVP means "Minimum Viable Product": the smallest version that really works from start to end.

| Priority | We will build |
|---|---|
| **Must** | A PostgreSQL database for suppliers, parts, stock, network, events and daily supplier data |
| **Must** | Phase 1: detect unusual suppliers, give a 0-100 risk score, a severity level, and a reason |
| **Must** | Phase 2: a map of who supplies whom, and a list of everything downstream of a problem supplier |
| **Must** | Phase 3: estimate time until stock is low, parts run out and production is hit, as ranges, plus a suggested action |
| **Must** | News reading: pull event type, place and seriousness out of headlines |
| **Must** | An API and a Streamlit dashboard that show all of this |
| **Must** | Tests, and the six required documents |
| **Should** | A "what if" tool: pretend a supplier fails and watch the whole chain react |
| **Should** | A simple login/register page and tabs in the dashboard |
| **Should** | One real public dataset, clearly kept apart from made-up data |
| **Could** | Automatic weekly retraining, a check for model getting stale, PDF/CSV export |

**We will not build (this semester)**
- A live link to a real company's systems, or any secret company data.
- Anything that places orders on its own. A human always decides.
- Deep-learning or chatbot-style text understanding. Our news reading is rule-based with help from a language library, and we will say exactly that.
- A big production setup (many companies, single sign-on, live streaming).
- Any claim that it works in the real world beyond what our tests show.

**Things we accept up front**
- Real multi-level supplier data is not public, so we test mostly on made-up (synthetic) data and say so everywhere.
- Before using any real dataset, we confirm we can download it and that its licence allows it.
- We keep **one** code repository and **one** detection pipeline. Earlier side experiments get merged or dropped in Week 4.

> **Why this scope and not a bigger one?**
> - Four students and 22 weeks is not enough for a "perfect" product. A smaller system that works end to end is better than a big one that half works.
> - The Must items are exactly the three phases plus data, news and screen. Without any one of them the story "detect, spread, predict" breaks.
> - Out-of-scope items are things that cost a lot of time but would not change the main idea.

---

## 3. Who Uses It and How

**People who would use it**

| Person | What they want | Problem today |
|---|---|---|
| **Supply chain risk analyst** (main user) | Find troubled suppliers early and know why | Too many separate signals, many false alarms, no explanation |
| **Procurement / planning manager** | Decide whether to switch supplier or rush an order, and by when | Knows a supplier is risky, but not the deadline |
| **Operations head** | See which products and factories are at risk | Gets scores with no time or impact |
| **Evaluator / guide** | Judge if our work is correct and honest | Needs to see data, method and limits clearly |

**What they can do**

| ID | Use case | What they should see |
|---|---|---|
| UC1 | Check supplier status | A list: "Flagged as Unusual" or "Normal", with a 0-100 score |
| UC2 | Look into one flagged supplier | The reason in plain words and a recent trend |
| UC3 | See how a problem spreads | Parts, factories and products that depend on it |
| UC4 | See timing and advice | When stock, parts and production are hit, as ranges, and what to do |
| UC5 | Read news events | Each headline with its event type, place and seriousness |
| UC6 | Try a "what if" | Pretend a failure and see all three phases react |
| UC7 | Refresh the model (admin) | Retrain and record the new version and its scores |
| UC8 | Register and log in | Passwords stored safely (hashed); dashboard hidden until login |

> **Why these users and these use cases?**
> - They follow the real decision chain: *notice* (UC1, UC2), *understand impact* (UC3, UC4), *use outside information* (UC5), *practise* (UC6).
> - The evaluator is included on purpose. For a college project, the demo must also be easy to judge.

---

## 4. How the System Works

```
Outside signals (APIs, news, weather)       Our company data (suppliers, stock, network)
              |                                          |
              +-----------> PostgreSQL database <--------+
                                   |
         News reader: headline -> event type / place / seriousness
                                   |
     Phase 1 DETECT  ->  Phase 2 SPREAD  ->  Phase 3 PREDICT
     (odd supplier?)     (who is hit?)       (when? what to do?)
                                   |
                            API (FastAPI)
                                   |
                        Dashboard (Streamlit)
```

Step by step:
1. Data comes in and goes into one database.
2. The news reader turns headlines into clean fields.
3. Phase 1 scores each supplier and flags unusual ones.
4. Phase 2 follows the supply map to find everything downstream.
5. Phase 3 estimates timing and suggests an action.
6. The API hands results to the dashboard, which shows them in plain language.

> **Why this design and not something else?**
> - **Three separate phases:** each one answers one question. Each can be built, tested and explained alone. If one is weak, the others still work.
> - **One database in the middle:** every part reads the same facts, so numbers never disagree between screens.
> - **An API between the logic and the screen:** the screen can change (or be replaced) without touching the AI code.
> - **Why not one big model that does everything?** It would need real, labelled disruption data that we do not have, and it would be very hard to explain to a guide.

---

## 5. Our Tools and Why We Chose Them

| Tool | What it does here (simple) | Why we chose it | What else we could have used, and why not |
|---|---|---|---|
| **Python** | The language for everything | Official stack. Best libraries for data and AI. The whole team knows it | Java or JavaScript: fewer data/ML libraries, slower for us |
| **PostgreSQL** | Stores all tables (suppliers, parts, stock, events) | Official stack. Free, reliable, great at linked tables (supplier -> part -> factory) | MongoDB: our data is neat tables with links, so SQL fits better. CSV files or SQLite: fine for a quick test, but weak when several parts of the system read and write together |
| **APIs** | How parts talk to each other and how we fetch outside data | Official stack. One clear way for the dashboard and outside data to connect | Having the dashboard read the database directly: ties the screen to the database and mixes up the logic |
| **FastAPI** (our extra) | Builds our own API | Python, quick to write, checks inputs automatically, makes a test page by itself | Flask: also fine, but no automatic checks or docs. Django: heavier than we need |
| **ML (scikit-learn)** | The machine-learning library | Has Isolation Forest ready and well tested; simple to use and save | PyTorch / TensorFlow: made for deep learning; too heavy for our amount of data |
| **NLP (spaCy)** | Finds names and places in headlines | Official stack (NLP). Ready-made, quick, free, works offline | BERT or a large language model: may be more accurate, but heavy, slower, harder to control and explain. Plain keyword search: cannot find places or organisations, so it would not honestly count as NLP |
| **NetworkX** | Builds and searches the supply map | Pure Python, simple functions like "everything downstream of X" | Neo4j (graph database): powerful, but another server to run and learn; not needed for our size |
| **Streamlit** | The dashboard | Official stack. Python only, so we can build screens fast and focus on the AI | React: prettier and more flexible, but needs JavaScript skills and much more time. Power BI / Tableau: hard to connect to our own model |
| **Docker Compose** | Starts the whole system with one command | Same setup on every laptop, fewer "works on my machine" problems | Manual installs: easy to get wrong. Note: some Windows laptops need virtualization switched on for Docker, so we keep a fallback with a normal local PostgreSQL |
| **pytest** | Runs our automated tests | Simple, standard in Python | unittest: works, but more code for the same result |

> **Why this stack overall?**
> - Four of the six main items are required by the portfolio, so we use them as given.
> - The extra tools (FastAPI, scikit-learn, NetworkX, spaCy, Docker, pytest) were picked because they are free, common, well documented and keep everything in Python. That means any teammate can read and explain any part.
> - We did not pick fancy tools just to look advanced. We chose tools we can finish and defend.

---

## 6. The AI Parts, One by One

### 6.1 Phase 1: Detecting Unusual Suppliers

**What we do.**
- For each supplier, we track delivery delay, stock-outs, how often they ship, and how much of the expected restock arrives.
- We smooth the numbers over the last 7 days so one bad day does not cause a false alarm.
- We compare each supplier with its own normal behaviour.
- An **Isolation Forest** then gives a risk score from 0 to 100.

**How Isolation Forest works in one picture.** Imagine a crowd of people and one person in a bright costume. It takes very few questions to single out the costume person, but many to single out an ordinary person. The model splits the data randomly again and again. Points that get separated quickly are "odd", so they get a high risk score.

**Honest limit.** The model can miss a case where *only one* number goes crazy while all the others stay normal. So we add a simple safety rule: if any single measure is extremely far from that supplier's normal, we raise an alert anyway and name that measure.

We also keep a very simple rule-based detector as a **baseline**. We must beat it, or we say honestly that we did not.

> **Why Isolation Forest and not something else?**
> | Other option | Why we did not choose it |
> |---|---|
> | Simple rules (threshold on one number) | Look at one measure at a time. We keep it as the baseline and as the safety rule above |
> | Supervised classifiers (Random Forest, XGBoost) | Need many examples labelled "this was a disruption". Real companies rarely have them. With made-up labels they would only learn our own generator, not the real world |
> | Autoencoder / LSTM (deep learning) | Need more data and tuning, and are hard to explain to a guide |
> | One-Class SVM | Very sensitive to scaling and settings, slow on bigger data |
> | Local Outlier Factor | Similar idea, but slow as data grows and depends a lot on the "neighbour count" setting |
>
> **Why Isolation Forest wins for us:** it needs no labels, it is fast, it handles many numbers at once, and it is easy to explain with the costume picture. It is not proven best. That is why we compare it with the baseline in Weeks 8 and 9.

### 6.2 Phase 2: Finding Who Is Hit

**What we do.** We draw the supply map as a network: supplier -> part -> factory -> product. If a supplier is flagged, we walk forward along the arrows and list everything that depends on it. We also use stock levels, lead times and backup suppliers to see who is most exposed.

> **Why a graph (network) and not something else?**
> - A supply chain *is* a network, so a graph matches the real thing and is easy to draw and explain.
> - **Why not a plain table with joins?** It works for one step but gets messy for many levels.
> - **Why not machine learning here?** Following dependencies is a fact-finding job, not a guessing job. Rules give exact, checkable answers.
> - **Why NetworkX and not a graph database?** Our network is small, and a database server would add work without adding value.

### 6.3 Phase 3: When Will It Hit Us?

**What we do.**
1. **Basic maths first:** days until trouble = (stock we have above the safety level) ÷ (stock we lose each day because supply dropped).
2. **Then machine learning:** a model learns from many simulated disruption scenarios to turn that number into a realistic **range** (for example "between 5 and 9 days").
3. **Then advice:** simple rules check for a backup supplier and suggest an action, such as "switch part of the order to Supplier B within 3 days".

> **Why this and not something else?**
> - **Why start with the formula?** It is easy to explain and gives a sanity check for the model.
> - **Why a range?** The future is uncertain. A range tells the planner how much to trust it.
> - **Why a tree-based model that can give ranges (gradient boosting) and not LSTM or Prophet?** Our inputs are a few clear numbers (stock, demand, lead time, supplier drop). That suits tree models well. Deep learning needs a lot more data, and plain time-series tools do not use our network and inventory information.
> - **Why rule-based advice?** A human must be able to read and approve the reason behind any suggestion.

### 6.4 News Reading (NLP)

**What we do.** Take a headline such as "Dockworkers begin 48-hour strike at port" and fill in: event type (strike), place or organisation, and how serious it is. We use spaCy to find names and places, then simple rules to pick the event type. We label about 100 headlines ourselves to measure how often we are right.

We will describe this honestly as **rule-assisted NLP with spaCy**, not as deep learning.

> **Why this and not a big language model?**
> - Headlines are short and the event types are few, so rules plus spaCy can do the job well.
> - It runs on a normal laptop, offline and free.
> - We can explain every decision it makes.
> - A large model might do better, but it costs more, is harder to control and is harder to defend in a review.

### 6.5 Data: Made-up and Real

**What we do.**
- **Made-up (synthetic) data** lets us create disruptions on purpose, so we know the right answers and can test properly.
- **At least one real public source** (to be checked for access and licence) shows the idea also works outside our own generator. Candidates we found: IMF PortWatch (port activity), GDACS (disaster alerts), SupplyGraph (a real company's supply network), FreshRetailNet-50K (real stock-out data). We do not have to use all of them.
- Every dataset in our data dictionary is marked **real, partly synthetic, or synthetic**.

> **Why both and not only one kind?**
> - **Only real data:** real companies keep supplier and stock data secret, and no public dataset has "this disruption happened, and here is when stock ran out" for a whole chain.
> - **Only synthetic data:** it can only prove our code works, not that it matches reality.
> - **Using both** gives controlled tests and a reality check, and we are honest about which is which.

### 6.6 How We Test the AI Fairly

- Train on older data, validate on the next period, and test on the latest period. Never shuffle time.
- Report precision, recall and F1 together, and compare against the simple baseline.
- Check that none of the answer columns accidentally leaks into the inputs.

> **Why test this way?**
> - Shuffling time lets the model "see the future", which makes scores look better than they are.
> - Reporting only accuracy or F1 can hide the fact that, say, half the alarms are false.

---

## 7. The 22-Week Schedule

Who: **PL** Project Lead, **DE** Data Engineer, **ML** AI/ML Engineer, **BF** Backend/Frontend Engineer, **All** everyone. Add calendar dates once the start week is fixed.

| Week | Stage | What we do | Who | What we get |
|---|---|---|---|---|
| 1 | Problem | Finish the problem statement, read 4-5 papers, confirm expectations with the guide | PL, All | Problem statement draft |
| 2 | Requirements | Users, use cases, priorities (Must/Should/Could), success targets | PL, All | Requirements list |
| 3 | Scope and setup | Lock the scope, risk list, task list (WBS), repo rules | PL, BF | Scope document. **Review 1** |
| 4 | Architecture | Draw components and data flow; decide: one pipeline, PostgreSQL, spaCy | PL, ML, BF | Architecture draft, decision log |
| 5 | Data planning | Choose data sources, check licences, design tables, start the database with Docker | DE | Data dictionary draft, working database |
| 6 | Data work | Load data into PostgreSQL, fetch data from APIs, clean and check it, set the time-based split | DE | Filled database, data-quality report |
| 7 | Data quality | Explore the data, define what counts as a disruption, finish dictionary and architecture | DE, PL | Data dictionary, architecture. **Review 2** |
| 8 | AI: detection basics | Build features, build the simple baseline detector | ML | Feature code, baseline scores |
| 9 | AI: detection model | Tune Isolation Forest, save the model, add safety rule, severity levels, reasons | ML | Saved model, metrics report |
| 10 | AI: news reading | Build spaCy plus rules, label about 100 headlines, measure | ML, DE | News module, accuracy table |
| 11 | AI: spread | Build the supply network and downstream search | ML, DE | Spread module, test cases |
| 12 | AI: timing | Basic formula, then ML with ranges, then advice rules | ML | Timing module, error report |
| 13 | Evaluation | Compare which signals help most, study the errors, draft the model card | ML, PL | Evaluation report. **Review 3** |
| 14 | Backend | Build API routes (detect, spread, predict, events, train) with clear errors | BF | API with auto-docs |
| 15 | Backend polish | Database-backed queries, logging, tests for the services | BF, DE | Service tests |
| 16 | Frontend | Streamlit tabs in plain language, optional login | BF | Working dashboard |
| 17 | Joining it all | End-to-end run, "what if" tool, full Docker setup | All | One-command start |
| 18 | MVP polish | Fix bugs, write the demo script (extra time here) | All | Demo rehearsal. **Review 4** |
| 19 | Testing | Run all test cases, bug hunt, try with 3-5 classmates | BF, PL, All | Test report |
| 20 | Responsible AI | Limits, fairness and coverage, explainability, privacy and security checks | ML, PL | Responsible AI document |
| 21 | Deploy and docs | Final setup, README, user guide, final dictionary and architecture (extra time here) | BF, DE, PL | Release candidate |
| 22 | Final | Two full practice runs, final report, tag version 1.0, back up data and model | All | Final package. **Review 5** |

Weeks 18 and 21 are kept lighter on purpose. Work that slipped earlier goes there first.

> **Why this order?**
> - **Data before models:** bad or missing data ruins every later step, so we spend Weeks 4 to 7 on it.
> - **Detect -> Spread -> Predict:** each phase feeds the next, so we build them in that order.
> - **Join things in Week 17, not at the end:** late joining is where student projects usually fail.
> - **Documents drafted early, finished late:** this avoids a last-week rush of writing.
> - **Buffer weeks:** something always slips.

---

## 8. Review Plan: What Must Be Ready

| Review | When (our suggestion) | Theme | Documents and work ready | What we show |
|---|---|---|---|---|
| 1 | End of Week 3 | Problem and Scope | Problem statement, requirements, users, scope, risks, task list | Guide agrees on scope |
| 2 | End of Week 7 | Architecture and Data | Architecture, data dictionary, tables, data-quality report | Running database with data; data-flow explanation |
| 3 | End of Week 13 | AI and Analytics | Detection, spread, timing and news modules, evaluation report, draft model card | Scores on later-period data vs the baseline, honest error analysis |
| 4 | End of Week 18 | Integrated MVP | Working API and dashboard, test cases, how to deploy | Live end-to-end demo of UC1 to UC6 |
| 5 | End of Week 22 | Final Readiness | All six documents, final report, tagged release | Full demo, test report, Responsible AI statement |

**If the college mid-semester review comes earlier than Review 3:** show only Phase 1. That means detection results with their scores, the reason given for each alert, and the dashboard. Say clearly that Phases 2 and 3 are planned.

> **Why five reviews with these themes?**
> - They follow the natural order of building anything: understand the problem, design it, build the intelligence, join it together, finish it.
> - Each review has a clear proof, so we cannot hide behind "almost done".

---

## 9. Team Roles

| Role | Main job | Also helps with | Name |
|---|---|---|---|
| Project Lead | Plan, risks, reviews, talking to the guide, document quality, final decisions | Back-up for any role | ____ |
| Data Engineer | Database, loading data, data dictionary, data quality, data splits | Data checks in every test | ____ |
| AI/ML Engineer | Features, models, news reading, evaluation, model card | Making sure explanations show on screen | ____ |
| Backend/Frontend Engineer | API, dashboard, Docker, automated tests | Screenshots and steps for the user guide | ____ |

**Rules so that all four of us understand everything**
- **Second owner:** every module has a second person who has read it and run it.
- **Friday teach-back (30 minutes):** the owner explains one part and someone else repeats it in their own words.
- **Cross review:** someone other than the author reviews each change. The `main` branch must always run.
- **Rotating presenter:** at each review, everyone presents a part they did not build.
- **Clean-clone check:** before each review, each member runs the system from scratch and explains one result.

**Weekly rhythm:** Monday 15-minute plan, mid-week check-in, Friday demo and teach-back, a short written update to the guide.

> **Why four roles with a second owner?**
> - Four roles match four people, so each has a clear area and nobody is waiting for someone else to decide.
> - Reviews often ask any member any question. Second owners and teach-backs mean one absence cannot block us, and nobody can answer only about their own part.

---

## 10. Required Documents Checklist

| Done | Document | What must be inside | Draft | Final |
|---|---|---|---|---|
| [ ] | **Problem Statement** | Background, problem, gap, goals, scope, success targets | Wk 1 | Wk 3 |
| [ ] | **Architecture** | Parts, data flow, API list, tool choices with reasons, deployment | Wk 4 | Wk 7 (update Wk 21) |
| [ ] | **Data Dictionary** | Every table and column: type, meaning, source, units, real or synthetic, quality rules | Wk 5 | Wk 7 (update Wk 21) |
| [ ] | **Test Cases** | Test plan, cases with input and expected result, data and model tests, results | Wk 8 | Wk 19 |
| [ ] | **Responsible AI** | Where data came from, limits, cost of false alarms, bias, explanations, privacy, human control | Wk 13 | Wk 20 |
| [ ] | **User Guide** | How to install and run, screens, how to read an alert, FAQs, fixes | Wk 16 | Wk 21 |

Nice to have: README with one-command setup, model card, task list, risk list, evaluation report, final report, demo script, tagged release.

> **Why these six?** Each answers one question a reviewer will ask: *What problem?* (Problem Statement) *How is it built?* (Architecture) *What data?* (Data Dictionary) *Does it work?* (Test Cases) *Is it safe and honest?* (Responsible AI) *Can someone else use it?* (User Guide).

---

## 11. Responsible AI in Simple Words

| Topic | Our promise |
|---|---|
| Honest about data | Every dataset is marked real, partly synthetic or synthetic. We never present synthetic results as real-world accuracy |
| Cost of mistakes | We show false alarms and missed problems side by side, and explain what each one costs |
| Explainable | Every alert names the measures that caused it, with plain-word severity levels |
| Humans decide | The system suggests; a person approves. No automatic actions |
| Fair coverage | We note which regions and languages our news and tracking sources cover poorly |
| Privacy and security | No confidential company data. Passwords hashed. Secrets kept out of the code repository |
| Known weak spots | We write them down (for example, one measure jumping alone, and how our safety rule handles it) |
| Keeping watch | We record model version, training date and scores, and plan a simple check for the model going stale |

> **Why do this?** An early-warning system that sounds sure but is often wrong is worse than none, because people may act on it. Being open about limits builds trust and is also what reviewers look for.

---

## 12. Testing Plan

| Level | What we check | When |
|---|---|---|
| Data | Right columns, no missing values, sensible ranges, no duplicates, dates in order | From Wk 6, on every load |
| Unit | Small functions: features, scoring, graph search, timing formula, news rules | From Wk 8 |
| Model | No leakage, time order respected, known planted disruptions are caught on later data | Wk 9 and 12 |
| API | Correct replies and errors, including "no trained model yet" | Wk 14-15 |
| Integration | Database -> model -> API -> dashboard | Wk 17 |
| System and user | UC1 to UC8 walkthroughs with 3-5 classmates | Wk 19 |

> **Why several levels?** Small tests find bugs quickly where they start. Bigger tests find problems that only show when parts meet. Model and data tests catch the silent mistakes that make results look better than they are.

---

## 13. Risks and What We Will Do

| Risk | Why it matters | What we do |
|---|---|---|
| Our test data is made up | Weak claim about the real world | Label it clearly, add one real source, state limits in the Responsible AI document |
| Too many side experiments | Wasted time, confusing demo | Lock scope in Week 3, one pipeline in Week 4, changes go through the Project Lead |
| No real "ground truth" for timing | Hard to prove the timing is right | Test on simulated scenarios; report ranges and how often they are right |
| News reading makes mistakes | Visible errors in the demo | Keep it rule-based, measure on a labelled set, show how sure it is |
| One person knows a part alone | One absence blocks a review | Second owners, teach-backs, clean-clone checks |
| Docker or setup problems | Lost days | Keep a fallback with local PostgreSQL |
| Joining things too late | Broken demo | Join by Week 17, build from `main` every week |

---

## 14. When Is a Task "Done"?
- The code is on `main` after review and runs from a fresh copy.
- Tests exist and pass, and any change to data or model is noted in the documents.
- The owner has shown it working, and the second owner can explain it.
- Any claim about how well it works says which data, which split and which measure.

---

## Small Glossary

| Word | Simple meaning |
|---|---|
| Supply chain | All the steps and companies that bring parts and products to the customer |
| Tier-1, Tier-2 | Direct suppliers, and the suppliers of those suppliers |
| Anomaly | Something that looks very different from normal |
| Isolation Forest | A model that finds odd data points because they are easy to separate from the rest |
| Baseline | A very simple method we must beat to prove our model adds value |
| Synthetic data | Data we generate ourselves for testing |
| Graph / network | Dots (suppliers, parts, factories) connected by arrows (who supplies whom) |
| NLP | Computers reading human language |
| NER | Finding names, places and organisations in text |
| API | A doorway that lets one program ask another for information |
| MVP | The smallest version that really works from start to end |
| Leakage | When answers sneak into the inputs, making scores look better than they are |
