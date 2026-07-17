-- ===============================================
-- OVERVIEW
-- ===============================================
-- This dataset contains 8,149 policyholders, each with demographic, behavioural and vehicle-related attributes.
-- This project analyses these policyholder characteristics
-- The results can be used to change pricing decisions by adjusting premiums to reflect differences in claim behaviour between groups.

-- ===============================================
-- OBJECTIVES
-- ===============================================
-- For each characteristic, highlight:
	-- Policyholder share
    -- Claim share
    -- Claim Frequency
    -- Relative risk
-- Create a high-risk summary table to show the most impactful factors

-- ===============================================
-- GUIDE
-- ===============================================
-- Analysis of characteristics is in their respective section.
-- Executuing the whole SQL script generates all characteristic tables and the final summary.
-- If you wish to view an individual result, execute the drop table, create table and the code positioned under the CTE.

-- We first need to specify the dataset we want to use:
USE insurance_project;


-- ===============================================
-- AGE ANALYSIS
-- ===============================================

DROP TABLE IF EXISTS Policyholder_Age_Groups;

CREATE TABLE Policyholder_Age_Groups AS (

-- 1. Find the number of claims made by each age group
WITH claims_by_age AS (
    SELECT 
        age,
        COUNT(*) AS claims
    FROM car_insurance_claim
    WHERE outcome = 1
    GROUP BY age
),
-- 2. Find the number of policyholders in each group
policyholder_age AS (
    SELECT
        age,
        COUNT(*) AS policyholders
    FROM car_insurance_claim
    GROUP BY age
),
-- 3. Finding the frequency of claims and erasing nulls from data
freq AS (
    SELECT
        pha.age,
        pha.policyholders,
        COALESCE(cba.claims, 0) AS claims,
        COALESCE(cba.claims, 0) * 1.0 / pha.policyholders AS frequency
    FROM policyholder_age pha
    LEFT JOIN claims_by_age cba
        ON pha.age = cba.age
)
-- 4. Finding the policyholder share, claim share, claim frequency and relative risk ratio (using the group with the lowest frequency as the baseline)
SELECT
	f.age,
    f.policyholders,
    f.claims,
    ROUND(100 * f.policyholders * 1.0 / SUM(f.policyholders) OVER(), 2) AS policyholder_share_pct,
    ROUND(100 * f.claims * 1.0 / SUM(f.claims) OVER(), 2) AS claim_share_pct,
    ROUND(100 * f.frequency, 2) AS claim_frequency_pct,
    ROUND(f.frequency / MIN(frequency) OVER(), 2) AS relative_risk_ratio
FROM freq f
ORDER BY relative_risk_ratio DESC
);

-- 5. Table results
SELECT *
FROM Policyholder_Age_Groups
;

-- 16-25 represent the smallest share of policyholders, yet they account for the largest proportion of claims.
-- Their claim frequency is 71.44%, which is substantially higher than the other age bands.
-- Relative to the baseline group (65+), the 16-25 age group has a relative risk of 7.10, indicating they are 7x more likely to make a claim.
-- This suggests that policyholders in this band present significantly higher risk, therefore premium rates for this group should be increased to reflect this.


-- ===============================================
-- GENDER ANALYSIS
-- ===============================================

DROP TABLE IF EXISTS Policyholder_Gender;
CREATE TABLE Policyholder_Gender AS (
WITH claims_by_gender AS (
    SELECT 
        gender,
        COUNT(*) AS claims
    FROM car_insurance_claim
    WHERE outcome = 1
    GROUP BY gender
),
policyholder_gender AS (
    SELECT
        gender,
        COUNT(*) AS policyholders
    FROM car_insurance_claim
    GROUP BY gender
),
freq AS (
    SELECT
        phg.gender,
        phg.policyholders,
        COALESCE(cbg.claims, 0) AS claims,
        COALESCE(cbg.claims, 0) * 1.0 / phg.policyholders AS frequency
    FROM policyholder_gender phg
    LEFT JOIN claims_by_gender cbg
        ON phg.gender = cbg.gender
)
SELECT
	f.gender,
    f.policyholders,
    f.claims,
    ROUND(100 * f.policyholders * 1.0 / SUM(f.policyholders) OVER(), 2) AS policyholder_share_pct,
    ROUND(100 * f.claims * 1.0 / SUM(f.claims) OVER(), 2) AS claim_share_pct,
    ROUND(100 * f.frequency, 2) AS claim_frequency_pct,
    ROUND(f.frequency / MIN(frequency) OVER(), 2) AS relative_risk_ratio
FROM freq f
ORDER BY relative_risk_ratio DESC
);

SELECT *
FROM Policyholder_Gender
;
-- Policyholder shares are very similar, but male policyholders make up 14.44% more in claim shares.
-- Male policyholders have a claim frequency of 35.69%, which is 9.12% higher than female policyholders.
-- The relative risk ratio suggests male policyholders are 1.34x more likely to make a claim than female policyholders
-- Therefore, male policyholders are at a higher risk of making a claim, but not by a significant amount.


-- ===============================================
-- DRIVING EXPERIENCE ANALYSIS
-- ===============================================

DROP TABLE IF EXISTS Policyholder_Driving_Experience;
CREATE TABLE Policyholder_Driving_Experience AS (
WITH claims_by_de AS ( -- driving_experience AS de
    SELECT 
        driving_experience,
        COUNT(*) AS claims
    FROM car_insurance_claim
    WHERE outcome = 1
    GROUP BY driving_experience
),
policyholder_de AS (
    SELECT
        driving_experience,
        COUNT(*) AS policyholders
    FROM car_insurance_claim
    GROUP BY driving_experience
),
freq AS (
    SELECT
        phd.driving_experience,
        phd.policyholders,
        COALESCE(cbd.claims, 0) AS claims,
        COALESCE(cbd.claims, 0) * 1.0 / phd.policyholders AS frequency
    FROM policyholder_de phd
    LEFT JOIN claims_by_de cbd
        ON phd.driving_experience = cbd.driving_experience
)
SELECT
	f.driving_experience,
    f.policyholders,
    f.claims,
    ROUND(100 * f.policyholders * 1.0 / SUM(f.policyholders) OVER(), 2) AS policyholder_share_pct,
    ROUND(100 * f.claims * 1.0 / SUM(f.claims) OVER(), 2) AS claim_share_pct,
    ROUND(100 * f.frequency, 2) AS claim_frequency_pct,
    ROUND(f.frequency / MIN(frequency) OVER(), 2) AS relative_risk_ratio
FROM freq f
ORDER BY relative_risk_ratio DESC
);

SELECT *
FROM Policyholder_Driving_Experience
;

-- The 0-9y band has the highest share of policyholders, closely followed by the 10-19y band.
-- However, the 0-9y band has a claim share of 70.82%, which is approximately 2.86x the claim share of the 10-19 band.
-- The 0-9y also exhibits a claim frequency of 62.71%, which will be a drain on the company's resources.
-- Relative to the baseline group, 30+ years, the 0-9y band are 34x more likely to claim.
-- So 0-9y of driving experience is the higher risk group, and premiums should be increased to reflect this
 
 
-- ===============================================
-- EDUCATION ANALYSIS
-- ===============================================

DROP TABLE IF EXISTS Policyholder_Education;
CREATE TABLE Policyholder_Education AS (
WITH claims_by_ed AS (
    SELECT 
        education,
        COUNT(*) AS claims
    FROM car_insurance_claim
    WHERE outcome = 1
    GROUP BY education
),
policyholder_ed AS (
    SELECT
        education,
        COUNT(*) AS policyholders
    FROM car_insurance_claim
    GROUP BY education
),
freq AS (
    SELECT
        phe.education,
        phe.policyholders,
        COALESCE(cbe.claims, 0) AS claims,
        COALESCE(cbe.claims, 0) * 1.0 / phe.policyholders AS frequency
    FROM policyholder_ed phe
    LEFT JOIN claims_by_ed cbe
        ON phe.education = cbe.education
)
SELECT
	f.education,
    f.policyholders,
    f.claims,
    ROUND(100 * f.policyholders * 1.0 / SUM(f.policyholders) OVER(), 2) AS policyholder_share_pct,
    ROUND(100 * f.claims * 1.0 / SUM(f.claims) OVER(), 2) AS claim_share_pct,
    ROUND(100 * f.frequency, 2) AS claim_frequency_pct,
    ROUND(f.frequency / MIN(frequency) OVER(), 2) AS relative_risk_ratio
FROM freq f
ORDER BY relative_risk_ratio DESC
);

SELECT *
FROM Policyholder_Education
;

-- Policyholders with high school education has the largest share of policyholders at 41.77%, followed closely by university level education, 39.48%.
-- High school education has a higher claim share than that of university education, but the groups claim share is proportional to their share of policyholders.
-- Policyholders with no education have the smallest share of policyholders at 18.75%, but make up x1.5 that of claim shares.
-- Policyholders with no education have a claim frequency of 46.27%, meaning nearly half of policyholders in this group will make a claim.
-- Finally, compared to the baseline group (univerisity), the relative risk ratio of policyholders with no education are 2x more likely to claim.
-- Therefore, policyholders with no education are the highest risk of making a claim in this group, followed by high school, then university.


-- ===============================================
-- INCOME ANALYSIS
-- ===============================================

DROP TABLE IF EXISTS Policyholder_Income;
CREATE TABLE Policyholder_Income AS (
WITH claims_by_inc AS (
    SELECT 
        income,
        COUNT(*) AS claims
    FROM car_insurance_claim
    WHERE outcome = 1
    GROUP BY income
),
policyholder_inc AS (
    SELECT
        income,
        COUNT(*) AS policyholders
    FROM car_insurance_claim
    GROUP BY income
),
freq AS (
    SELECT
        phi.income,
        phi.policyholders,
        COALESCE(cbi.claims, 0) AS claims,
        COALESCE(cbi.claims, 0) * 1.0 / phi.policyholders AS frequency
    FROM policyholder_inc phi
    LEFT JOIN claims_by_inc cbi
        ON phi.income = cbi.income
)
SELECT
	f.income,
    f.policyholders,
    f.claims,
    ROUND(100 * f.policyholders * 1.0 / SUM(f.policyholders) OVER(), 2) AS policyholder_share_pct,
    ROUND(100 * f.claims * 1.0 / SUM(f.claims) OVER(), 2) AS claim_share_pct,
    ROUND(100 * f.frequency, 2) AS claim_frequency_pct,
    ROUND(f.frequency / MIN(frequency) OVER(), 2) AS relative_risk_ratio
FROM freq f
ORDER BY relative_risk_ratio DESC
);

SELECT *
FROM Policyholder_Income
;

-- The upper class band have the largest share of policyholders at 44.03%, and the lowest shares being the poverty and working class; 17.90% and 16.78% respectfully.
-- Lower working class and poverty class policyholders have the greatest claim shares, 36.99% and 24.92%, which is larger than their respective shares of policyholders.
-- Their claim frequency is 45.96% and 64.29%, which is substantially higher than the other income bands.
-- Relative to the baseline group (upper class), the lower working and poverty class have a relative risk of 3.39 and 4.47, indicating they are 3-5x more likely to make a claim.
-- Therefore, premiums for policyholders in the lower working and poverty class should be increased to reflect this higher risk.


-- ===============================================
-- CREDIT SCORE ANALYSIS
-- ===============================================

-- Notice: MIN(credit_score) = 0.05..., MAX(credit_score) = 0.96; Assume credit score ranges from 0 to 1000
-- I will use 25%, 50%, 75% and 75+% as the band boundaries
DROP TABLE IF EXISTS Policyholder_Credit_Score;
CREATE TABLE Policyholder_Credit_Score AS (
WITH claims_by_cred AS
(
SELECT
	CASE
		WHEN credit_score <= 0.25 THEN 'Poor'
        WHEN credit_score <= 0.50 THEN 'Fair'
        WHEN credit_score <= 0.75 THEN 'Good'
        ELSE 'Excellent'
	END Credit_Score,
    COUNT(*) Claims
FROM car_insurance_claim
WHERE outcome = 1
GROUP BY CASE
	WHEN credit_score <= 0.25 THEN 'Poor'
	WHEN credit_score <= 0.50 THEN 'Fair'
	WHEN credit_score <= 0.75 THEN 'Good'
	ELSE 'Excellent'
END
)
,
policyholder_cred AS
(
SELECT
	CASE
		WHEN credit_score <= 0.25 THEN 'Poor'
        WHEN credit_score <= 0.50 THEN 'Fair'
        WHEN credit_score <= 0.75 THEN 'Good'
        ELSE 'Excellent'
	END Credit_Score,
    COUNT(*) Policyholders
FROM car_insurance_claim
GROUP BY CASE
	WHEN credit_score <= 0.25 THEN 'Poor'
	WHEN credit_score <= 0.50 THEN 'Fair'
	WHEN credit_score <= 0.75 THEN 'Good'
	ELSE 'Excellent'
END
),
freq AS (
    SELECT
        phc.Credit_Score,
        phc.policyholders,
        COALESCE(cbc.claims, 0) AS claims,
        COALESCE(cbc.claims, 0) * 1.0 / phc.policyholders AS frequency
    FROM policyholder_cred phc
    LEFT JOIN claims_by_cred cbc
        ON phc.Credit_Score = cbc.Credit_Score
)
SELECT
	f.Credit_Score,
    f.policyholders,
    f.claims,
    ROUND(100 * f.policyholders * 1.0 / SUM(f.policyholders) OVER(), 2) AS policyholder_share_pct,
    ROUND(100 * f.claims * 1.0 / SUM(f.claims) OVER(), 2) AS claim_share_pct,
    ROUND(100 * f.frequency, 2) AS claim_frequency_pct,
    ROUND(f.frequency / MIN(frequency) OVER(), 2) AS relative_risk_ratio
FROM freq f
ORDER BY relative_risk_ratio DESC
);

SELECT *
FROM Policyholder_Credit_Score
;

-- The lower the credit score, the higher the claim frequency, increasing the relative risk ratio based on 'Excellent' credit score
-- Policyholders with poor credit score have the highest claim frequency at 56.80%, and their relative risk ratio highlights that they are 4.39x more likely to claim than a policyholder with an excellent credit score.
-- However, we see that for poor and excellent credit score groups represent a much smaller share of policyholders, 3.07% and 2.85% respectfully. This means that it is more susceptible to random variation, and the inference should be treated with caution.

-- ===============================================
-- VEHICLE YEAR ANALYSIS
-- ===============================================

DROP TABLE IF EXISTS Policyholder_Vehicle_Year;
CREATE TABLE Policyholder_Vehicle_Year AS (
WITH claims_by_vy AS (
    SELECT 
        vehicle_year,
        COUNT(*) AS claims
    FROM car_insurance_claim
    WHERE outcome = 1
    GROUP BY vehicle_year
),
policyholder_vy AS (
    SELECT
        vehicle_year,
        COUNT(*) AS policyholders
    FROM car_insurance_claim
    GROUP BY vehicle_year
),
freq AS (
    SELECT
        phv.vehicle_year,
        phv.policyholders,
        COALESCE(cbv.claims, 0) AS claims,
        COALESCE(cbv.claims, 0) * 1.0 / phv.policyholders AS frequency
    FROM policyholder_vy phv
    LEFT JOIN claims_by_vy cbv
        ON phv.vehicle_year = cbv.vehicle_year
)
SELECT
	f.vehicle_year,
    f.policyholders,
    f.claims,
    ROUND(100 * f.policyholders * 1.0 / SUM(f.policyholders) OVER(), 2) AS policyholder_share_pct,
    ROUND(100 * f.claims * 1.0 / SUM(f.claims) OVER(), 2) AS claim_share_pct,
    ROUND(100 * f.frequency, 2) AS claim_frequency_pct,
    ROUND(f.frequency / MIN(frequency) OVER(), 2) AS relative_risk_ratio
FROM freq f
ORDER BY relative_risk_ratio DESC
);

SELECT *
FROM Policyholder_Vehicle_Year
;

-- Majority of policyholders have vehicles manufactured before 2015, more than 2x than that of after 2015.
-- Claim shares are disproportional, with vehicle years before 2015 make up 89.16% of claims, and vehicle years after 2015 make up 10.84% of claims.
-- Claim frequency of vehicles manufactured before 2015 are 4x that of vehicles manufactured after 2015.
-- Policyholders with vehicles manufactured before 2015 are 3.65x more likely to make a claim than those with vehicles manufactured after 2015.
-- Therefore, policyholders with vehicles made before 2015 are the higher risk group, and premium rates should be increased to reflect this.


-- ===============================================
-- ANNUAL MILEAGE ANALYSIS
-- ===============================================

-- In the following data, some groups have made no claims, leading to frequencies = 0. Trying to find the relative risk ratio leads to divison b 0, which needs rectifying.
-- I will now use NULLIF(MIN(NULLIF(frequency, 0)) OVER(), 0), which replaces the zeros in frequency with null, and then we find the minimum frequency of the non-nulls.
-- The outer NULLIF protects from the case where all frequencies = 0

DROP TABLE IF EXISTS Policyholder_Annual_Mileage;
CREATE TABLE Policyholder_Annual_Mileage AS (
WITH claims_by_am AS (
    SELECT 
        CASE 
			WHEN Annual_Mileage <= 5000 THEN '<5'
            WHEN Annual_Mileage <= 10000 THEN '5k-10k'
            WHEN Annual_Mileage <= 15000 THEN '10k-15k'
            WHEN Annual_Mileage <= 20000 THEN '15k-20k'
            ELSE '20k+'
		END Annual_Mileage,
        COUNT(*) AS claims
    FROM car_insurance_claim
    WHERE outcome = 1
    GROUP BY CASE 
				WHEN Annual_Mileage <= 5000 THEN '<5'
				WHEN Annual_Mileage <= 10000 THEN '5k-10k'
				WHEN Annual_Mileage <= 15000 THEN '10k-15k'
				WHEN Annual_Mileage <= 20000 THEN '15k-20k'
				ELSE '20k+'
		END
),
policyholder_am AS (
    SELECT
        CASE 
			WHEN Annual_Mileage <= 5000 THEN '<5'
            WHEN Annual_Mileage <= 10000 THEN '5k-10k'
            WHEN Annual_Mileage <= 15000 THEN '10k-15k'
            WHEN Annual_Mileage <= 20000 THEN '15k-20k'
            ELSE '20k+'
		END Annual_Mileage,
        COUNT(*) AS policyholders
    FROM car_insurance_claim
    GROUP BY CASE 
			WHEN Annual_Mileage <= 5000 THEN '<5'
            WHEN Annual_Mileage <= 10000 THEN '5k-10k'
            WHEN Annual_Mileage <= 15000 THEN '10k-15k'
            WHEN Annual_Mileage <= 20000 THEN '15k-20k'
            ELSE '20k+'
		END
),
freq AS (
    SELECT
        pha.annual_mileage,
        pha.policyholders,
        COALESCE(cba.claims, 0) AS claims,
        COALESCE(cba.claims, 0) * 1.0 / pha.policyholders AS frequency
    FROM policyholder_am pha
    LEFT JOIN claims_by_am cba
        ON pha.annual_mileage = cba.annual_mileage
)
SELECT
	f.annual_mileage,
    f.policyholders,
    f.claims,
    ROUND(100 * f.policyholders * 1.0 / SUM(f.policyholders) OVER(), 2) AS policyholder_share_pct,
    ROUND(100 * f.claims * 1.0 / SUM(f.claims) OVER(), 2) AS claim_share_pct,
    ROUND(100 * f.frequency, 2) AS claim_frequency_pct,
    ROUND(f.frequency / NULLIF(MIN(NULLIF(frequency, 0)) OVER(), 0), 2) AS relative_risk_ratio
FROM freq f
ORDER BY relative_risk_ratio DESC
);

SELECT *
FROM Policyholder_Annual_Mileage
;

--  Policyholders with annual mileage between 10k-15k miles have the largest share of policyholders at 56.45%, with the largest, relatively proportional claim share.
-- We see that the 15k-20k band has the highest claim frequency of 100%, and relative risk ratio of 4.55, indicating that policyholders in this band are 4.55x more likely to make a claim than the baseline group (<5k).
-- From the raw data, Policyholders with annual mileage of 20k+ are the highest risk group, but with such a small sample size, the results hold very little statistical significance.


-- ===============================================
-- VEHICLE TYPE ANALYSIS
-- ===============================================

DROP TABLE IF EXISTS Policyholder_Vehicle_Type;
CREATE TABLE Policyholder_Vehicle_Type AS (
WITH claims_by_vt AS (
    SELECT 
        vehicle_type,
        COUNT(*) AS claims
    FROM car_insurance_claim
    WHERE outcome = 1
    GROUP BY vehicle_type
),
policyholder_vt AS (
    SELECT
        vehicle_type,
        COUNT(*) AS policyholders
    FROM car_insurance_claim
    GROUP BY vehicle_type
),
freq AS (
    SELECT
        phv.vehicle_type,
        phv.policyholders,
        COALESCE(cbv.claims, 0) AS claims,
        COALESCE(cbv.claims, 0) * 1.0 / phv.policyholders AS frequency
    FROM policyholder_vt phv
    LEFT JOIN claims_by_vt cbv
        ON phv.vehicle_type = cbv.vehicle_type
)
SELECT
	f.vehicle_type,
    f.policyholders,
    f.claims,
    ROUND(100 * f.policyholders * 1.0 / SUM(f.policyholders) OVER(), 2) AS policyholder_share_pct,
    ROUND(100 * f.claims * 1.0 / SUM(f.claims) OVER(), 2) AS claim_share_pct,
    ROUND(100 * f.frequency, 2) AS claim_frequency_pct,
    ROUND(f.frequency / MIN(frequency) OVER(), 2) AS relative_risk_ratio
FROM freq f
ORDER BY relative_risk_ratio DESC
);

SELECT *
FROM Policyholder_Vehicle_Type
;

-- Policyholders that have a sedan have the highest share of policyholders at 95.24% and the highest share of claims at 95.15%.
-- Both groups have very similar claim frequencies, with a difference of 0.61%, and a relative risk ratio difference of 0.02.
-- Preferably, we could increase the data for sport car owners, but with the current data we can conclude that there is no significant difference in risk between the two groups, and therefore premiums should be similar.

-- ===============================================
-- SPEEDING VIOLATIONS ANALYSIS
-- ===============================================

DROP TABLE IF EXISTS Policyholder_Speeding_Violations;
CREATE TABLE Policyholder_Speeding_Violations AS (
WITH claims_by_sv AS (
    SELECT 
        CASE
			WHEN Speeding_Violations = 0 THEN 0
            WHEN Speeding_Violations <= 3 THEN '1-3'
            WHEN Speeding_Violations <= 7 THEN '4-7'
            ELSE '8+'
		END Speeding_Violations,
        COUNT(*) AS claims
    FROM car_insurance_claim
    WHERE outcome = 1
    GROUP BY 
		CASE
				WHEN Speeding_Violations = 0 THEN 0
				WHEN Speeding_Violations <= 3 THEN '1-3'
				WHEN Speeding_Violations <= 7 THEN '4-7'
				ELSE '8+'
			END
),
policyholder_sv AS (
    SELECT
        CASE
			WHEN Speeding_Violations = 0 THEN 0
            WHEN Speeding_Violations <= 3 THEN '1-3'
            WHEN Speeding_Violations <= 7 THEN '4-7'
            ELSE '8+'
		END Speeding_Violations,
        COUNT(*) AS policyholders
    FROM car_insurance_claim
    GROUP BY
		CASE
				WHEN Speeding_Violations = 0 THEN 0
				WHEN Speeding_Violations <= 3 THEN '1-3'
				WHEN Speeding_Violations <= 7 THEN '4-7'
				ELSE '8+'
			END
),
freq AS (
    SELECT
        ph.Speeding_Violations,
        ph.policyholders,
        COALESCE(cb.claims, 0) AS claims,
        COALESCE(cb.claims, 0) * 1.0 / ph.policyholders AS frequency
    FROM policyholder_sv ph
    LEFT JOIN claims_by_sv cb
        ON ph.speeding_violations = cb.speeding_violations
)
SELECT
	f.Speeding_Violations,
    f.policyholders,
    f.claims,
    ROUND(100 * f.policyholders * 1.0 / SUM(f.policyholders) OVER(), 2) AS policyholder_share_pct,
    ROUND(100 * f.claims * 1.0 / SUM(f.claims) OVER(), 2) AS claim_share_pct,
    ROUND(100 * f.frequency, 2) AS claim_frequency_pct,
    ROUND(f.frequency / NULLIF(MIN(NULLIF(frequency, 0)) OVER(), 0), 2) AS relative_risk_ratio
FROM freq f
ORDER BY relative_risk_ratio DESC
);

SELECT *
FROM Policyholder_Speeding_Violations
;

-- Policyholders with 0 speeding violations take up the largest share of policyholders at 50.34%.
-- Whereas the other bands lower claim share than policyholder share, the 0 speeding violations group have a claim share of 79.06%.
-- This is reflected in the claim frequency, 48.88%, and relative ratio, 5.61 relative to the baseline group (8+ speeding violations).
-- Therefore, policyholders with 0 speeding violations are the highest risk group. However, we see that for 4-7 and 8+ speeding violations groups represent a much smaller share of policyholders, 2.68%. Therefore, we have to treat this inference with caution.


-- ===============================================
-- DUI ANALYSIS
-- ===============================================

DROP TABLE IF EXISTS Policyholder_DUIs;
CREATE TABLE Policyholder_DUIs AS (
WITH claims_by_dui AS (
    SELECT
		DUIs,
        COUNT(*) AS claims
    FROM car_insurance_claim
    WHERE outcome = 1
    GROUP BY DUIs
),
policyholder_dui AS (
    SELECT
        DUIs,
        COUNT(*) AS policyholders
    FROM car_insurance_claim
    GROUP BY DUIs
),
freq AS (
    SELECT
        ph.DUIs,
        ph.policyholders,
        COALESCE(cb.claims, 0) AS claims,
        COALESCE(cb.claims, 0) * 1.0 / ph.policyholders AS frequency
    FROM policyholder_dui ph
    LEFT JOIN claims_by_dui cb
        ON ph.DUIs = cb.DUIs
)
SELECT
	f.DUIs,
    f.policyholders,
    f.claims,
    ROUND(100 * f.policyholders * 1.0 / SUM(f.policyholders) OVER(), 2) AS policyholder_share_pct,
    ROUND(100 * f.claims * 1.0 / SUM(f.claims) OVER(), 2) AS claim_share_pct,
    ROUND(100 * f.frequency, 2) AS claim_frequency_pct,
    ROUND(f.frequency / NULLIF(MIN(NULLIF(frequency, 0)) OVER(), 0), 2) AS relative_risk_ratio
FROM freq f
ORDER BY relative_risk_ratio DESC
);

SELECT *
FROM Policyholder_DUIs
;

-- For higher numbers of DUIs, the policyholder shares for these groups are very small, which means that the results are not statistically significant.
-- From raw data, we see that policyholders with 4 DUIs have the highest claim frequency, 37.50%, and relative risk ratio, 6.33, followed closely by 0 DUIs.
-- However, the 4 DUIs group only has 8 policyholders, which is a very small sample size.
-- We can look at 0 DUIs, and see that they make up the majority of policyholder shares and claim shares.
-- Therefore, due to the lack of data the rate of premiums for all groups should remain the same.



-- ===============================================
-- PAST ACCIDENTS ANALYSIS
-- ===============================================

DROP TABLE IF EXISTS Policyholder_Past_Accidents;
CREATE TABLE Policyholder_Past_Accidents AS (
WITH claims_by_pa AS (
    SELECT 
        past_accidents,
        COUNT(*) AS claims
    FROM car_insurance_claim
    WHERE outcome = 1
    GROUP BY past_accidents
),
policyholder_pa AS (
    SELECT
        past_accidents,
        COUNT(*) AS policyholders
    FROM car_insurance_claim
    GROUP BY past_accidents
),
freq AS (
    SELECT
        ph.past_accidents,
        ph.policyholders,
        COALESCE(cb.claims, 0) AS claims,
        COALESCE(cb.claims, 0) * 1.0 / ph.policyholders AS frequency
    FROM policyholder_pa ph
    LEFT JOIN claims_by_pa cb
        ON ph.past_accidents = cb.past_accidents
)
SELECT
	f.past_accidents,
    f.policyholders,
    f.claims,
    ROUND(100 * f.policyholders * 1.0 / SUM(f.policyholders) OVER(), 2) AS policyholder_share_pct,
    ROUND(100 * f.claims * 1.0 / SUM(f.claims) OVER(), 2) AS claim_share_pct,
    ROUND(100 * f.frequency, 2) AS claim_frequency_pct,
    ROUND(f.frequency / NULLIF(MIN(NULLIF(frequency, 0)) OVER(), 0), 2) AS relative_risk_ratio
FROM freq f
ORDER BY relative_risk_ratio DESC
);

SELECT *
FROM Policyholder_Past_Accidents
;

-- Once again, the same issue arises with the small sample sizes for higher numbers of past accidents.
-- From the raw data, we see the trend that as the number of past accidents increases, the claim frequency and relative risk ratio decreases.
-- Policyholders with 0 past accidents have the highest policyholder share and claim share, 55.71% and 83.87% respectfully.
-- The claim frequency is 46.85% meaning almost half of policyholders with 0 past accidents will make a claim.
-- The relative risk ratio is 23.43, which is significantly higher than the other groups, indicating that policyholders with 0 past accidents are 23x more likely to make a claim.
-- However this is compared to a group that has 50 policyholders, which is a small sample size, and therefore the inference should be treated with caution.


-- ===============================================
-- HIGH RISK TABLE
-- ===============================================

DROP TABLE IF EXISTS high_risk_characteristics;

CREATE TABLE high_risk_characteristics AS
SELECT *
FROM (
	SELECT
		'Age' Characteristic,
		CAST(age AS CHAR) AS High_Risk_Group,
		Policyholder_Share_Pct,
        Claim_Share_Pct,
		Claim_Frequency_Pct,
		Relative_Risk_Ratio
	FROM Policyholder_Age_Groups
	ORDER BY Relative_Risk_Ratio DESC
	LIMIT 1 ) age
UNION ALL
SELECT *
FROM (
	SELECT
		'Gender' Characteristic,
		CAST(gender AS CHAR) AS High_Risk_Group,
		Policyholder_Share_Pct,
		Claim_Share_Pct,
		Claim_Frequency_Pct,
		Relative_Risk_Ratio
	FROM Policyholder_Gender
	ORDER BY Relative_Risk_Ratio DESC
	LIMIT 1) gender
UNION ALL
SELECT *
FROM (
	SELECT
		'Driving Experience' Characteristic,
		CAST(Driving_experience AS CHAR) AS High_Risk_Group,
		Policyholder_Share_Pct,
		Claim_Share_Pct,
		Claim_Frequency_Pct,
		Relative_Risk_Ratio
	FROM Policyholder_Driving_Experience
	ORDER BY Relative_Risk_Ratio DESC
	LIMIT 1) de
UNION ALL
SELECT *
FROM (
	SELECT
		'Education' Characteristic,
		CAST(education AS CHAR) AS High_Risk_Group,
		Policyholder_Share_Pct,
        Claim_Share_Pct,
		Claim_Frequency_Pct,
		Relative_Risk_Ratio
	FROM Policyholder_Education
	ORDER BY Relative_Risk_Ratio DESC
	LIMIT 1) education
UNION ALL
SELECT *
FROM (
	SELECT
		'Income' Characteristic,
		CAST(Income AS CHAR) AS High_Risk_Group,
		Policyholder_Share_Pct,
        Claim_Share_Pct,
		Claim_Frequency_Pct,
		Relative_Risk_Ratio
	FROM Policyholder_Income
	ORDER BY Relative_Risk_Ratio DESC
	LIMIT 1) inc
UNION ALL
SELECT *
FROM (
	SELECT
		'Credit Score' Characteristic,
		CAST(credit_score AS CHAR) AS High_Risk_Group,
		Policyholder_Share_Pct,
        Claim_Share_Pct,
		Claim_Frequency_Pct,
		Relative_Risk_Ratio
	FROM Policyholder_Credit_Score
	ORDER BY Relative_Risk_Ratio DESC
	LIMIT 1) cred
UNION ALL
SELECT *
FROM (
	SELECT
		'Vehicle Year' Characteristic,
		CAST(vehicle_year AS CHAR) AS High_Risk_Group,
		Policyholder_Share_Pct,
        Claim_Share_Pct,
		Claim_Frequency_Pct,
		Relative_Risk_Ratio
	FROM Policyholder_Vehicle_Year
	ORDER BY Relative_Risk_Ratio DESC
	LIMIT 1) vy
UNION ALL
SELECT *
FROM (
	SELECT
		'Annual Mileage' Characteristic,
		CAST(Annual_Mileage AS CHAR) AS High_Risk_Group,
		Policyholder_Share_Pct,
        Claim_Share_Pct,
		Claim_Frequency_Pct,
		Relative_Risk_Ratio
	FROM Policyholder_Annual_Mileage
	ORDER BY Relative_Risk_Ratio DESC
	LIMIT 1) am
UNION ALL
SELECT *
FROM (
	SELECT
		'Vehicle Type' Characteristic,
		CAST(Vehicle_Type AS CHAR) AS High_Risk_Group,
		Policyholder_Share_Pct,
        Claim_Share_Pct,
		Claim_Frequency_Pct,
		Relative_Risk_Ratio
	FROM Policyholder_Vehicle_Type
	ORDER BY Relative_Risk_Ratio DESC
	LIMIT 1) vt
UNION ALL
SELECT *
FROM (
	SELECT
		'Speeding Violations' Characteristic,
		CAST(Speeding_Violations AS CHAR) AS High_Risk_Group,
		Policyholder_Share_Pct,
        Claim_Share_Pct,
		Claim_Frequency_Pct,
		Relative_Risk_Ratio
	FROM Policyholder_Speeding_Violations
	ORDER BY Relative_Risk_Ratio DESC
	LIMIT 1) sv
UNION ALL
SELECT *
FROM (
	SELECT
		'DUIs' Characteristic,
		CAST(DUIs AS CHAR) AS High_Risk_Group,
		Policyholder_Share_Pct,
        Claim_Share_Pct,
		Claim_Frequency_Pct,
		Relative_Risk_Ratio
	FROM Policyholder_DUIs
	ORDER BY Relative_Risk_Ratio DESC
	LIMIT 1) dui
UNION ALL
SELECT *
FROM (
	SELECT
		'Past Accidents' Characteristic,
		CAST(Past_Accidents AS CHAR) AS High_Risk_Group,
		Policyholder_Share_Pct,
        Claim_Share_Pct,
		Claim_Frequency_Pct,
		Relative_Risk_Ratio
	FROM Policyholder_Past_Accidents
	ORDER BY Relative_Risk_Ratio DESC
	LIMIT 1) pa
;

SELECT *
FROM high_risk_characteristics
ORDER BY Relative_Risk_Ratio DESC
;

-- The summary table highlights the highest-risk group as policyholders with 0-9 years of driving experience, holding a significant relative risk ratio of 34.
-- There is a large sample of policyholders in each group of driving experience, indicating that this is a stable conclusion.
-- We also see that policyholders with 0 past-accidents also hold a high relative risk ratio of 23.43, but the distribution of policyholders is skewed, so we cannot confidently display clear inference.
-- Alternatively, we can see that other groups, such as policyholders in the age band 16-25 and poverty class band, have a very high claim frequency, large sample sizes, but have a much lower relative risk ratio.
-- On the same note, we see annual mileage of 20k+ miles has a claim frequency of 100%, but the policyholder share for this group is so small, we cannot compare this against the other groups.
-- Therefore, premium rates should be increased for policyholders with 0-9 years of driving experience, as they are the highest risk group, and have a large sample size to support this conclusion.
-- Additionally, premium rates should be increased for policyholders in the 16-25 age band and poverty class, as they have a high claim frequency, and a large sample size.


