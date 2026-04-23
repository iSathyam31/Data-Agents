

Here are sample questions organized by which agent handles them:

### Leader responds directly (no delegation)
- "Hey, what can you do?"
- "Thanks!"
- "Who are you?"

### Analyst questions (data/SQL)

**Revenue & Orders**
- "What's our total revenue?"
- "Show me monthly revenue trends"
- "What's our average order value?"
- "How many orders were cancelled?"

**Products & Categories**
- "Which category generates the most revenue?"
- "What are our top 10 best-selling products?"
- "Which products have the lowest ratings?"
- "Show me revenue breakdown by category"

**Customers**
- "Who are our top 5 customers by total spend?"
- "How many customers do we have?"
- "Which city has the most customers?"

**Payments**
- "What's the payment success rate by method?"
- "How much revenue came through PayPal?"
- "How many payments are still pending?"

**Shipping**
- "Which carrier has the best delivery rate?"
- "How many shipments are currently in transit?"
- "What's the average estimated delivery time by carrier?"

**Multi-step / Insights**
- "Give me a full business health overview"
- "Are there any products with high sales but low ratings?"
- "Compare revenue this month vs last month"

### Engineer questions (create dash schema objects)
- "Create a view for monthly revenue by category"
- "Build a summary table of customer lifetime values"
- "Create a view that shows product performance with revenue and ratings combined"

Start with **"What's our total revenue?"** — it's the simplest end-to-end test of the Leader → Analyst → postgres-mcp → response flow.