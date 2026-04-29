# Sample Questions for Dash (Healthcare Domain)

Here are some example questions you can ask the Dash agent in the Streamlit UI to test its capabilities across different domains of the hospital.

## 📊 Analyst Queries (Data Retrieval & Insights)

### Patient & Admissions Tracking
* *"How many patients are currently admitted in the hospital?"*
* *"What is our overall bed occupancy rate right now?"*
* *"What is the average length of stay for patients in the ICU?"*
* *"Show me a breakdown of our patients by age group."*

### Clinical & Medical
* *"What are the top 10 most prescribed medications this month?"*
* *"Which lab test has the highest percentage of abnormal results?"*
* *"Who are the doctors with the most scheduled appointments next week?"*
* *"How many appointments were marked as 'No Show' last month?"*

### Billing & Revenue
* *"What is our total recognized revenue (paid bills) grouped by department?"*
* *"Which insurance provider pays out the most to our hospital?"*
* *"Show me the top 5 patients with the highest unpaid out-of-pocket balances."*
* *"What percentage of our revenue comes from insurance versus patient out-of-pocket?"*

---

## 🛠️ Engineer Queries (Building Infrastructure)

* *"Create a view in the dash schema called `daily_admissions_summary` that shows the number of admissions per day for the last 30 days."*
* *"Build a summary table in the dash schema that lists every doctor and their total number of completed appointments."*
* *"Create a view named `dash.unpaid_invoices` that joins the billing table with patient names and phones so our collections team can call them."*
* *"Can you build a view that calculates the current bed availability for every ward?"*

---

## 🧠 Self-Learning Tests

1. **Ask a hard question:** *"What's the average length of stay?"* (Dash will find the pre-loaded validated query in ChromaDB and answer instantly).
2. **Force an error:** Ask a highly complex, slightly vague question. If the Analyst writes bad SQL and hits a Snowflake syntax error, watch the logs! It will fix the error, and then save the fix to the `dash_learnings` collection.
3. **Ask again:** Ask the exact same hard question again. It will use its previous learning to answer perfectly on the first try.
