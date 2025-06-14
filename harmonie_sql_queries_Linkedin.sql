-- SQL Queries for Harmonie Medical Center Operational Analytics

-- 1. Total Patients Count
SELECT COUNT(DISTINCT patient_id) AS total_patients FROM patients;

-- 2. Abnormal Vitals (Threshold-Based)
SELECT patient_id, timestamp, heart_rate, temperature, systolic_bp, diastolic_bp
FROM vitals
WHERE heart_rate < 60 OR heart_rate > 100
   OR temperature < 36 OR temperature > 38
   OR systolic_bp < 90 OR systolic_bp > 140
   OR diastolic_bp < 60 OR diastolic_bp > 90;

-- 3. Abnormal Vitals in the Last 48 Hours
DECLARE @reference_time DATETIME = (SELECT MAX(timestamp) FROM vitals);
SELECT DISTINCT patient_id, timestamp, heart_rate, temperature, systolic_bp, diastolic_bp
FROM vitals
WHERE timestamp >= DATEADD(HOUR, -48, @reference_time)
  AND (
    heart_rate < 60 OR heart_rate > 100 OR
    temperature < 36 OR temperature > 38 OR
    systolic_bp < 90 OR systolic_bp > 140 OR
    diastolic_bp < 60 OR diastolic_bp > 90
  );

-- 4. Percentage of Abnormal Vitals in Last 48 Hours
WITH recent_vitals AS (
    SELECT *
    FROM vitals
    WHERE timestamp >= DATEADD(HOUR, -48, (SELECT MAX(timestamp) FROM vitals))
),
abnormal_vitals AS (
    SELECT *
    FROM recent_vitals
    WHERE heart_rate < 60 OR heart_rate > 100
       OR temperature < 36 OR temperature > 38
       OR systolic_bp < 90 OR systolic_bp > 140
       OR diastolic_bp < 60 OR diastolic_bp > 90
)
SELECT 
    COUNT(*) AS total_abnormal_vitals,
    (SELECT COUNT(*) FROM recent_vitals) AS total_vitals_last_48h,
    ROUND(COUNT(*) * 1.0 / NULLIF((SELECT COUNT(*) FROM recent_vitals), 0) * 100, 2) AS abnormal_vital_percentage
FROM abnormal_vitals;

-- 5. Top 10 Patients with Most Abnormal Vitals This Month
SELECT TOP 10 v.patient_id, p.full_name, COUNT(*) AS abnormal_count
FROM vitals v
JOIN patients p ON v.patient_id = p.patient_id
WHERE MONTH(v.timestamp) = MONTH(GETDATE())
  AND (
    heart_rate < 60 OR heart_rate > 100 OR
    temperature < 36 OR temperature > 38 OR
    systolic_bp < 90 OR systolic_bp > 140 OR
    diastolic_bp < 60 OR diastolic_bp > 90
  )
GROUP BY v.patient_id, p.full_name
ORDER BY abnormal_count DESC;

-- 6. Readmission Rate (Within 30 Days)
WITH Readmissions AS (
  SELECT a1.patient_id, a1.admission_date, a2.discharge_date,
         DATEDIFF(DAY, a2.discharge_date, a1.admission_date) AS days_between
  FROM admissions a1
  JOIN admissions a2
    ON a1.patient_id = a2.patient_id
   AND a1.admission_date > a2.discharge_date
)
SELECT 
  COUNT(DISTINCT patient_id) * 1.0 /
  (SELECT COUNT(DISTINCT patient_id) FROM admissions) AS readmission_rate
FROM Readmissions
WHERE days_between <= 30;

-- 7. Readmission Rate by Department
WITH ranked_admissions AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY admission_date) AS rn
  FROM admissions
),
readmissions AS (
  SELECT a1.patient_id, a1.department, a1.discharge_date, a2.admission_date
  FROM ranked_admissions a1
  JOIN ranked_admissions a2 
    ON a1.patient_id = a2.patient_id
   AND a2.rn = a1.rn + 1
   AND a2.admission_date > a1.discharge_date
),
total_discharges AS (
  SELECT department, COUNT(*) AS total_discharges
  FROM admissions
  WHERE discharge_date IS NOT NULL
  GROUP BY department
),
readmission_counts AS (
  SELECT department, COUNT(*) AS total_readmissions
  FROM readmissions
  GROUP BY department
)
SELECT 
  td.department,
  td.total_discharges,
  ISNULL(rc.total_readmissions, 0) AS total_readmissions,
  ROUND(ISNULL(rc.total_readmissions, 0) * 1.0 / td.total_discharges * 100, 2) AS readmission_rate_percent
FROM total_discharges td
LEFT JOIN readmission_counts rc 
  ON td.department = rc.department
ORDER BY readmission_rate_percent DESC;

-- 8. Average Doctor Response Time (Last 7 Days)
WITH RecentVisits AS (
  SELECT department,
         DATEDIFF(MINUTE, visit_start_time, visit_end_time) AS response_time
  FROM doctor_visits
  WHERE visit_start_time >= DATEADD(DAY, -7, (SELECT MAX(visit_start_time) FROM doctor_visits))
)
SELECT department, ROUND(AVG(response_time), 2) AS avg_response_time_minutes
FROM RecentVisits
GROUP BY department;

-- 9. Doctors with Avg Response Time > 10 Min (Last 14 Days)
SELECT doctor_id,     
AVG(DATEDIFF(MINUTE, visit_start_time, visit_end_time)) AS avg_response_time_min
FROM doctor_visits
WHERE visit_start_time >= DATEADD(DAY, -14, GETDATE())
GROUP BY doctor_id
HAVING AVG(DATEDIFF(MINUTE, visit_start_time, visit_end_time)) > 10;
