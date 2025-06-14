# Harmonie-Medical-Center
Healthcare Analytics — Harmonie Medical Center A real-world healthcare analytics project using SQL Server and Power BI to identify high-risk patients, analyse readmission trends, and evaluate clinical responsiveness. Includes optimised SQL scripts, KPIs, and insights to support operational decision-making in hospital settings.


# Harmonie-Medical-Center - Healthcare Analytics Project

## Project Overview
This project presents a comprehensive analysis of healthcare data performed at Harmonie Medical Centre — a mid-sized, multi-speciality hospital. The goal is to leverage real-world data to identify high-risk patients, optimise departmental efficiency, and evaluate staff responsiveness using SQL and Power BI.

## Objectives
- Detect patients with abnormal vitals in real-time (last 48 hours)
- Identify departments with high readmission rates
- Monitor average doctor response times
- Highlight peak operation hours and patient trends

## Tools & Technologies
- SQL Server 
- Microsoft SQL Server Management Studio (SSMS)
- Power BI (for optional visualization)

## Datasets
The analysis uses four structured datasets:
- `patients.csv` — Patient demographics
- `vitals.csv` — Vital sign measurements
- `admissions.csv` — Admission and discharge logs
- `doctor_visits.csv` — Clinical visit timings

## Key Insights
- 1,466 out of 3,000 patients (49%) had abnormal vitals in the last 48 hours.
- Cardiology had the highest 30-day readmission rate at 24.5%.
- 30 doctors had average response times > 10 minutes.
- Peak consultation hours: 13:00 and 16:00.

## File Structure
```
📦 Harmonie-Medical-Center
├── Harmonie Medical Center – Report.docx          # Executive summary & project insights
├── README.md                                      # This README file
├── harmonie_sql_queries_linkedin.sql              # Optimized SQL scripts used in analysis
├── admissions.csv                                 # Patient admission/discharge data
├── doctor_visits.csv                              # Doctor visit logs with timestamps
├── patients.csv                                   # Demographic data for patients
├── vitals.csv                                     # Patient vital signs (heart rate, BP, temp)
```

## Getting Started
1. Open SQL scripts in SQL Server Management Studio.
3. Load datasets into your SQL database.
4. Run the queries to replicate insights or build visualizations in Power BI.

## Sample SQL Query: Abnormal Vitals in Last 48 Hours
```sql
SELECT patient_id, timestamp, heart_rate, temperature, systolic_bp, diastolic_bp
FROM vitals
WHERE timestamp >= DATEADD(HOUR, -48, (SELECT MAX(timestamp) FROM vitals))
  AND (
    heart_rate < 60 OR heart_rate > 100 OR
    temperature < 36 OR temperature > 38 OR
    systolic_bp < 90 OR systolic_bp > 140 OR
    diastolic_bp < 60 OR diastolic_bp > 90
  );
```

## Acknowledgements
Thanks to the internship team at Harmonie Medical Center and Amdari for providing real-world project exposure in healthcare operations and analytics.

## Contact
For questions, collaborations, or feedback:
- LinkedIn: www.linkedin.com/in/oluwatosin-mayowa-david

- GitHub: (https://github.com/Tosin1303)

---

Empowering patient-first care through data-driven decisions.
