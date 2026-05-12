# Sample Questions for Dash (TPC-DS Retail Domain)

Here are some example questions you can ask the Dash agent in the Streamlit UI to test its capabilities across different dimensions of the TPC-DS retail dataset.

## 📊 Analyst Queries (Data Retrieval & Insights)

### Revenue & Sales
* *"What is our total store revenue for 2001?"*
* *"Compare total revenue across store, catalog, and web channels for 2001."*
* *"Which store had the highest net profit in 2001?"*
* *"Show me the top 10 best-selling items by total revenue in 2001."*

### Returns & Profitability
* *"What is the overall return rate for store sales in 2001?"*
* *"Which product category has the highest return rate?"*           
* *"Show me items where the return rate is more than 3x the category average."*
* *"What is the net loss from returns broken down by sales channel?"*

### Customers & Demographics
* *"Break down store sales revenue by customer income band for 2001."*
* *"Which customer education level drives the most catalog sales?"*
* *"Show me revenue from preferred customers vs. non-preferred customers."*
* *"Who are our top 20 highest-value customers by total spend?"*

### Promotions & Inventory
* *"Which promotions generated the highest incremental revenue in 2001?"*
* *"Show me items with critically low inventory across all warehouses."*
* *"What is the average inventory level by category for Q4 2001?"*

---

## 🛠️ Engineer Queries (Building Infrastructure)

* *"Create a view called `dash.monthly_store_revenue` that shows total revenue, net paid, and net profit per store per month."*
* *"Build a view `dash.channel_revenue_comparison` that compares total revenue and profit margin across store, catalog, and web channels by year."*
* *"Create a view `dash.top_items_by_category` ranking items by total store sales revenue within each product category."*
* *"Build a `dash.store_performance_ranking` view that ranks stores by revenue, return rate, and profit margin."*
* *"Create a `dash.low_inventory_items` view that flags any item/warehouse combination where current quantity is below 10."*

---

## 🧠 Self-Learning Tests

1. **Hit the knowledge base:** *"What is our total store revenue for 2001?"* — Dash will find the pre-loaded `monthly_store_sales_revenue.sql` pattern in ChromaDB and answer without starting from scratch.
2. **Force an error:** Ask a complex cross-channel question (e.g. *"What is the combined return rate across all three channels for 2001?"*). If Dash writes a query that errors, watch it fix the SQL and save the fix to `dash_learnings`.
3. **Ask again:** Repeat the same question. Dash will use its saved learning and answer correctly on the first try.
