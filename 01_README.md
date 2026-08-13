# Why Revenue Declined by 43%? Root-Cause Analysis, Financial Impact & Recovery Plan

## 📌 Project Overview

Revenue dropped by **43% over a seven month period**. This project investigates the root causes of the decline using a structured drill-down analysis across **time, product, and geography**.

The analysis identifies the primary drivers of the decline, measures the financial impact, examines segments that showed signs of recovery during the decline, and translates the findings into actionable business recommendations.

> **Dataset Limitation:** The dataset does not contain data for January, February, March, November, or December. Therefore, the analysis focuses only on the available months, **April through October**.

---

## 📁 Project Deliverables

- [Dashboard](https://github.com/Ayeshah123/Revenue_Decline_Root_Cause_Analysis/blob/main/02_Power_BI/Revenue%20Decline%20Dashboard.pdf)
- [Analytical Workflow](https://github.com/Ayeshah123/Revenue_Decline_Root_Cause_Analysis/blob/main/05_Documentation/Analytical_Workflow.pdf)
- [ERD](https://github.com/Ayeshah123/Revenue_Decline_Root_Cause_Analysis/blob/main/05_Documentation/ERD.pdf)
- [SQL Scripts](https://github.com/Ayeshah123/Revenue_Decline_Root_Cause_Analysis/tree/main/03_SQL)
- [Project Workflow](./05_Documentation/Project_Workflow.pdf)
- [Data Dictionary](https://github.com/Ayeshah123/Revenue_Decline_Root_Cause_Analysis/blob/main/05_Documentation/Data_Dictionary.pdf)

---

## Main KPIs

| KPI | YoY Change |
|---|---:|
| Revenue | **-43.0%** |
| Quantity Sold | **-41.9%** |
| Average Selling Price (ASP) | **-4.4%** |
| Gross Profit | **-43.7%** |
| Cost | **-42.4%** |

## 🔍 Key Findings


### 1. Root-Cause Analysis

**Quantity Sold was the primary driver of the revenue decline, decreasing by 41.9%.**

The analysis followed a drill-down approach across Product Class - Category - Subcategory - Manufacturer - Continent - Country to trace the decline to its source.

The sharpest declines occurred in April, May, June, July, and October.

**Regular class** accounted for **103%** of the Quantity Sold decline.** This exceeds 100% because **Economy class** was growing at the same time.

**Regular Class Decline Concentration:**

- **5 Product Categories:** Cameras & Camcorders, Cell Phones, Computers, TV & Video, Music, Movies & Audio Books
- **9 Product Subcategories:** Digital Cameras, Digital SLR Cameras, Printers, Scanners & Fax, Projectors & Screens, Movie DVD, Touch Screen Phones, Home & Office Phones, Smart Phones & PDAs, Home Theater System
- **4 Manufacturers:** Contoso, A Datum Corporation, The Phone Company, Proseware
- **1 Continent:** North America
- **1 Country:** USA

---

### 2. Financial Impact

- Gross Profit declined by **43.7%**, closely matching the decline in Revenue.
- Cost declined by **42.4%**, which was lower than the decline in Revenue and Gross Profit.
- This indicates that **cost was not the primary driver of the decline**.
- The same product and geographic segments that drove the Revenue decline also drove the Gross Profit decline.

**Conclusion:** Quantity Sold is the main driver affecting both Revenue and Gross Profit, making it the top priority for recovery.

---

### 3. Recovery Analysis

Several product and geographic segments showed positive Quantity Sold trends during the declining period.

**ASP decreased by 4.4%, which supported growth in Economy class.**

The positive Quantity Sold trends were concentrated in:

- **1 Product Class:** Economy
- **4 Product Categories:** Computers, TV & Video, Cell Phones, Camcorders
- **5 Product Subcategories:** Monitors, Projectors & Screens, Computer Accessories, Home Theater System, Digital Cameras
- **5 Manufacturers:** Contoso, Southridge, Proseware, Fabrikam Inc, Adventure Works
- **1 Continent:** Asia
- **4 Countries:** China, Japan, Pakistan, Armenia

**Recovery Insight:** A lower price point combined with the right product and geographic mix can increase Quantity Sold even during an overall period of decline.

---

## 💡 Recommendations

### Immediate | 0–3 Months

1. **Review Regular Class Pricing & Demand**
   - Regular class drove the majority of the Quantity Sold decline.
   - Review pricing, demand, availability, and customer behavior before the next seasonal cycle.

2. **Investigate Key Manufacturers & Geography**
   - Investigate the 4 manufacturers and 1 country that contributed significantly to the decline.
   - Focus on stock, distribution, quality, and demand issues.

3. **Avoid Broad Discounting**
   - Cost is not the primary problem.
   - Discounting alone is unlikely to solve the Quantity Sold decline.

4. **Investigate External Factors**
   - Competitor activity
   - Inflation
   - Customer behavior
   - Market conditions

### Short-Term | 3–6 Months

1. **Test Economy Class Pricing Strategy**
   - Economy class experienced Quantity Sold growth while ASP decreased by 4.4%.
   - Test similar pricing strategies in Regular class.

2. **Scale What Is Working**
   - Prioritize product categories and countries already showing positive Quantity Sold trends.

3. **Establish Monthly Monitoring**
   - Track Quantity Sold by Product Class and Geography to identify early signs of decline.

### Long-Term | 6–12 Months

1. **Reduce Concentration Risk**
   - Reduce dependency on a small number of manufacturers and a single continent.

2. **Develop Class-Specific Pricing Strategies**
   - Regular and Economy classes behaved differently.
   - A single pricing strategy across all product classes may not be effective.

3. **Document Recovery Drivers**
   - Track ASP changes, category performance, and geographic performance to build a repeatable recovery framework.

---

## 👩‍💼 Analyst View

This analysis helps the business understand where the revenue decline was concentrated and which areas had the greatest impact on overall performance. It provides a starting point for identifying where attention is needed rather than treating the decline as a single company-wide issue.

The dataset allowed me to investigate sales, cost, and profitability trends across the available dimensions, but it did not provide enough information to investigate every possible reason behind the decline. Factors such as changes in inventory, product availability, customer behavior, promotions, or competitive activity could not be explored in the same depth because the required data was outside the scope of the dataset.

There was also less direction around the problem because this was a project dataset rather than a real business case. If I were given this problem within a company, I would expect some initial context from stakeholders before starting the analysis. For example, the inventory or operations team might highlight changes in product availability over the previous year, the sales or customer team might have noticed a change in purchasing behavior, or the research team might have identified increased competitive pressure in a particular market. These observations would not be treated as the answer, but they could help form more targeted questions, decide where to investigate first, and use the data to confirm or challenge those assumptions.

From a business prioritization perspective, I would not focus only on the products with the largest decline in quantity or revenue. I would look for the overlap between products experiencing a significant decline and products generating stronger profit margins or profit contribution. Recovering sales in these areas could have a greater impact on overall profitability, making them stronger candidates for further investigation and potential business action.

---

## 🛠️ Tools & Skills

- **Power BI:** DAX, semantic modeling, data modeling, interactive dashboards
- **SQL Server:** CTEs, views, trend analysis, root-cause analysis
- **Excel:** Data analysis, validation
- **Power Query:** Data cleaning, transformation

### Analytical Skills

- Root-cause analysis
- Revenue decomposition
- YoY analysis
- Contribution analysis
- Product & geographic drill-down
- Financial impact analysis
- Recovery analysis
- Business recommendations

---

# 🤝 Let's Connect

- [LinkedIn](https://www.linkedin.com/in/ayesha-analyst/)
- [Email](mailto:ayeshabatool160@gmail.com)

