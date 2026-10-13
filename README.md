# Complete SSMS SQL Server Portfolio Projects

This pack contains five runnable, SQL-only portfolio projects for Microsoft SQL Server Management Studio (SSMS). Each project has its own database, synthetic sample data, constraints, indexes, views, stored procedures, analysis queries, and basic data-quality checks.

## Projects
1. **Retail Sales & Inventory Management** — sales KPIs, monthly trends, top products, customer value, low-stock alerts.
2. **HR Employee Analytics** — headcount, payroll, salary comparisons, tenure, performance review analysis.
3. **Hospital Appointment Operations** — appointment status, no-show rate, doctor workload, fees and repeat visits. Uses synthetic patient labels only.
4. **Bank Transactions & Fraud-Risk Review** — transaction trends, flagged-transaction review queue, channel risk rates and customer activity. Flags are illustrative rules, not a production fraud model.
5. **E-commerce Orders, Returns & Customer Retention** — revenue, gross profit, acquisition channels, return reasons and repeat customers.

## Run in SSMS
1. Install/open SQL Server Management Studio and connect to a SQL Server instance.
2. Open one `.sql` file.
3. Select **Execute** (or press **F5**) and allow the script to finish.
4. Review the **Messages** tab for errors and the **Results** tabs for outputs.
5. Each script creates its own database if it does not exist. It then drops and rebuilds only the tables/views/procedure belonging to that project. **Re-running a script resets that project's sample tables and data.** Do not run it against a production database.
6. To explore, run the analysis queries at the bottom of the script individually or together. Stored procedure examples are included.

## Portfolio notes
- These are complete, executable learning projects using synthetic sample data; they do not require Excel, Power BI, Python, or external datasets.
- The data is deliberately small so that you can inspect the joins and results. For a strong GitHub submission, add your own screenshots of SSMS result grids, a short findings section based on the actual query results, and a project-specific README.
- Never claim the sample data represents a real company or real patients/customers.
- Before publishing, run each script in your own SQL Server environment and verify successful execution. SQL Server versions that support `DROP VIEW IF EXISTS` and `DROP PROCEDURE IF EXISTS` are recommended (SQL Server 2016+).

## SQL skills demonstrated
Relational schema design, primary/foreign keys, `CHECK`/`UNIQUE` constraints, identity columns, indexing, multi-table joins, aggregations, `CASE`, CTEs, date functions, views, stored procedures, validation with `THROW`, and data-quality checks.
